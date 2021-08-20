.syntax unified
.global main, EXTI0_IRQHandler, EXTI1_IRQHandler, calculate_diff
.include "src/libcomp2300/macros.S"

.type main, %function
main:

  @ initialize the audio jack
  bl init

  @ initialize the tim7, interrupt happens every 0.25 seconds
  mov r0, #10000
  mov r1, #2000
  bl tim7_init

  @ Reminder: PE12(sender) -> PH0(receiver); PE13(sender) -> PH1(receiver)

  @ initialize ports E & H clocks
  GPIOx_clock_enable E
  GPIOx_clock_enable H 
  
  @ initialize SYSCFG clock
  RCC_APB2ENR_set 0

  @ set sender pins to output mode
  GPIO_configure_output_pin E, 12
  GPIO_configure_output_pin E, 13

  @ set reveiver pins to input mode with interrupt handlers
  GPIO_configure_input_pin_it H, 0
  GPIO_configure_input_pin_it H, 1

  @ set PH0 & PH1 to rising & falling mode
  EXTI_set_rising_edge_trigger 0
  EXTI_set_falling_edge_trigger 0
  EXTI_set_rising_edge_trigger 1

  @ set the NVIC ISER properly (PH0 & PH1)
  NVIC_set ISER 6
  NVIC_set ISER 7

  loop:
    
    @ check whether we are in the mute/unmute status
    ldr r0, =mute
    ldr r1, [r0]
    cmp r1, 0
    beq then_3

    @ mute
    else_3:

      b remaining_3

    @ unmute
    then_3:
      @ play sound
      bl wave_play_next_sample

    @ loop forever
    remaining_3:
      b loop

.size main, .-main


@ the interrupt handler for PH0 pin (ON/OFF)
.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  push {lr}

  @ check whether it's rising/falling edge
  GPIOx_IDR_read H, 0

  if_1:
    cmp r0, 0
    beq then_1

  @ rising edge
  else_1:

    @ clear the mute word to 0
    ldr r0, =mute
    mov r1, #0
    str r1, [r0]

    @ load the next pitch sequence and produce the wave pattern
    ldr r0, =sequence_index_receiver
    ldr r1, [r0]
    ldr r0, =sequence_table
    ldr r0, [r0, r1, lsl 2]
    mov r1, 0x7fff
    bl wave_change

    b remaining_1

  @ falling edge
  then_1:

    @ set the mute word to 1
    ldr r0, =mute
    mov r1, #1
    str r1, [r0]

  remaining_1:
  
  @ clear the pending bit 
  EXTI_PR_clear_pending 0

  pop {lr}
  bx lr
.size EXTI0_IRQHandler, .-EXTI0_IRQHandler


@ the interrupy handler for PH1 pin
.type EXTI1_IRQHandler, %function
EXTI1_IRQHandler:

  push {lr}

  @ increment the pitch index
  ldr r0, =sequence_index_receiver
  ldr r1, [r0]
  add r1, 1

  @ check whether exceeds 8
  if_2:
    cmp r1, 8
    beq then_2
  else_2:
    b remaining_2
  then_2:
    mov r1, 0
  remaining_2:
    str r1, [r0]

  @ clear the pending bit
  EXTI_PR_clear_pending 1

  pop {lr}
  bx lr
.size EXTI1_IRQHandler, .-EXTI1_IRQHandler


.data

  @ whether play the sound (0 -> not mute), (1 -> mute)
  mute:
    .word 1

  @ the index of pitch in the sequence of pitches
  sequence_index_receiver:
    .word 0

  @ store data about all the pitches with index
  sequence_table:
    .word 22000
    .word 24694
    .word 26163
    .word 29366
    .word 32963
    .word 36999
    .word 39200
    .word 44000