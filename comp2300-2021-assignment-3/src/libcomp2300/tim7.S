.syntax unified

@ ------------------------ TIM7 ------------------------
@ Timer 7 features a 16-bit prescaler and a 16-bit counter.
@ The prescaler divides the main clock (which runs at 80MHz according to definition in HAL),
@ and the counter counts up according to the divided clock.
@ When the counter counts up to the reload value,
@ an update event is triggered and an interrupt is fired.

@ --------------------- Module Interface --------------------
.global tim7_init, TIM7_IRQHandler

@ --------------------- Implementation --------------------
.include "src/libcomp2300/macros.S"

.set CK_PSC, 80000000

.type tim7_init, %function
@ tim7_init takes two parameters, clock divisor and count (in each case, only the lower 16-bits will be used)
@
@ the clock divisor determines how many CPU cycles per TIM7 tick
@ the count determines how many TIM7 ticks between the TIM7 interrupts firing
@
@ Remember that in the assignment template, the main clock is at 80MHz
@ so, for example, clock divisor = 10000 and count = 8000 will give a 1Hz interrupt
@
@ In short, (seconds between interrupts) = (clock divisor * count) / 80000000
@
@ --parameters--
@ r0: clock divisor (prescaler + 1)
@ r1: count
tim7_init:
  push {r4-r5, lr}
  mov r4, r0
  mov r5, r1

  @ enable peripheral clock
  @ RCC_APB1ENR_set 5
  ldr r0, =ADR_RCC
  ldr r1, =OFS_RCC_APB1ENR
  ldr r2, =5
  bl set_bit

  @ Set prescaler
  @ the counter clock frequency f(CK_CNT) = f(CK_PSC) / (prescaler + 1)
  @ since clock divisor = prescaler + 1,
  @ subtract 1 here to get the prescaler
  @ See Section 29.4.7
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_PSC
  sub r4, 1
  strh r4, [r0, r1]

  @ set counter reload value (Section 29.4.8)
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_ARR
  strh r5, [r0, r1]

  @ TIM7_EGR (Section 29.4.5)
  ldr r0, =ADR_TIM7
  ldr r1, =0x14
  ldr r2, [r0, r1]
  orr r2, 0b1
  str r2, [r0, r1]

  @ clear interrupt (Section 29.4.4)
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_SR
  mov r2, 0
  bl clear_bit

  @ enable timer 7  (Section 29.4.1s)
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_CR1
  mov r2, 0
  bl set_bit

  @ enable TIM7 DMA/interrupt (Section 29.4.3)
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_DIER
  mov r2, 0
  bl set_bit

  @ enable TIM7 interrupt in NVIC
  NVIC_set ISER 55  @ TIM7 is at position 55

  @ set debug freeze (Section 44.16.4)
  ldr r0, =ADR_DBGMCU_APB1FZR1
  mov r1, 0
  mov r2, 5
  bl set_bit

  @ NOTE: you MAY want to configure the priority of TIM7.
  @ put your code here if that's the case

  @ adjust the interrupt priority of tim7 interrupt
  mov r0, 55
  mov r1, 0b1111
  bl NVIC_IPR_set_priority

  bl sync
  pop {r4-r5, lr}
  bx lr
.size tim7_init, .-tim7_init

.type TIM7_IRQHandler, %function
@ --parameters--
@ none
TIM7_IRQHandler:
  push {lr}

  @ Your interrupt handler code goes here

  @ check whether it's 0.25s/0.5s
  if_6:
  ldr r0, =tim7_counter
  ldr r1, [r0]
  cmp r1, 1
  beq then_6

  else_6:
    
    @ 0.25 second passed
    add r1, 1
    str r1, [r0]
    b remaining_6

  then_6:

    @ 0.5 second passed
    mov r1, 0
    str r1, [r0]

    @ 0.5 seconds passed, ready to send next pitch info
    ldr r0, =pitch_index
    ldr r1, [r0]
    add r1, #1

    @ check whether exceeds 19
    if_4:
      cmp r1, 19
      beq then_4
    else_4:
      b remaining_4
    then_4:
      mov r1, 0
    remaining_4:
      str r1, [r0]


  remaining_6:

    @ let PE12 send signals to turn on/off sounds every 0.25s
    GPIOx_ODR_toggle E, 12
    @ wait for the memory synchronization
    bl sync

    @ let PE13 send signals to update the correct index every 0.25s to tell the receiver to change pitch
    bl calculate_diff
    for_init:
      mov r1, 0
    for_body:
      cmp r0, r1
      beq for_end
      push {r0, r1}
      GPIOx_ODR_set E, 13
      @ wait for the memory synchronization
      bl sync
      GPIOx_ODR_clear E, 13
      @ wait for the memory synchronization
      bl sync
      pop {r0, r1}
      add r1, 1
      b for_body
    for_end:
      @ update the sequence_index in sender
      ldr r0, =sequence_index_sender
      ldr r2, [r0]
      add r2, r1
      @ check whether exceeds 8
      if_7:
        cmp r2, 7
        bhi then_7
      else_7:
        b remaining_7
      then_7:
        sub r2, 8
      remaining_7:
        str r2, [r0]

  @ Clear interrupt (Section 29.4.4)
  ldr r0, =ADR_TIM7
  ldr r1, =OFS_TIMx_SR
  mov r2, 0
  bl clear_bit

  bl sync

  pop {lr}
  bx lr
.size TIM7_IRQHandler, .-TIM7_IRQHandler

@ calculate number of signals needed to send to change the pitch
.type calculate_diff, %function
calculate_diff:

  ldr r0, =pitch_index
  ldr r1, [r0]  @ r1 -> current index of pitch
  ldr r0, =sound_data
  ldr r1, [r0, r1, lsl 2]  @ r1 -> the required sequence of pitch
  ldr r0, =sequence_index_sender
  ldr r2, [r0]    @ r2 -> the current sequence index

  if_5:
    cmp r1, r2
    bhi then_5
  
  else_5:
    @ go to sequence before
    sub r0, r2, r1
    mov r1, 8
    sub r0, r1, r0
    b remaining_5

  then_5:
    @ go to sequence after
    sub r0, r1, r2

  remaining_5:
  bx lr
.size calculate_diff, .-calculate_diff

.data

  @ the counter for tim7 interrupt, for certain operations happen at 0.5s
  tim7_counter:
  .word 0

  @ current pitch table index
  pitch_index:
    .word 0

  @ the index of pitch in the sequence of pitches
  sequence_index_sender:
    .word 0

  @ the sound indices
  sound_data:
    .word 0
    .word 2
    .word 1
    .word 3
    .word 2
    .word 4
    .word 3
    .word 5
    .word 4
    .word 6
    .word 5
    .word 7
    .word 6
    .word 5
    .word 4
    .word 3
    .word 2
    .word 1
    .word 0