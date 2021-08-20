.syntax unified

@ --------------------- Module Interface --------------------
.global joystick_init

@ --------------------- Implementation --------------------
.type joystick_init, %function
@ --parameters--
@ none
joystick_init:
  push {lr}

  @ unless otherwise indicated, all references to "Section x.x.x" are from the
  @ STM32L476G Discovery Reference Manual
  @ https://cs.anu.edu.au/courses/comp2300/assets/manuals/stm32-L476G-discovery-reference-manual.pdf

  @ where indicated, references are to the ARM v7-M Architecture Reference Manual
  @ https://cs.anu.edu.au/courses/comp2300/assets/manuals/ARMv7-M-architecture-reference-manual.pdf

  @ enable GPIOA clock (RCC_AHB2ENR, Section 6.4.17 p225)
  @ GPIOx_clock_enable A
  ldr r0, =ADR_RCC  @ 0x40021000
  ldr r1, =OFS_RCC_AHB2ENR
  ldr r2, =IDX_GPIOA
  bl set_bit

  @ enable SYSCFG clock (RCC_APB2ENR, Section 6.4.21 p233)
  @ RCC_APB2ENR_set 0
  ldr r0, =ADR_RCC  @ 0x40021000
  ldr r1, =OFS_RCC_APB2ENR
  ldr r2, =0
  bl set_bit

  mov r0, #5
  bl delay

  @ Set PA0 (central joystick button) to input (GPIOA_MODER, Section 7.4.1 p265)
  @ GPIOx_MODER_write A 0 0b00
  ldr r0, =(ADR_GPIOA + 0x0)  @ 0x48000000
  ldr r1, =0b00 @ bits to copy
  mov r2, 0     @ bit index
  mov r3, 2     @ length
  bl copy_bits

  @ Set PA0 to pull-down (GPIOx_PUPDR, Section 7.4.4 p266)
  @ GPIOx_PUPDR_write A 0 0b10
  ldr r0, =(ADR_GPIOA + 0xC)  @ 0x4800000C
  ldr r1, =0b10
  mov r2, 0
  mov r3, 2
  bl copy_bits

  @ select pin PA0 as source for EXTI0 interrupt (SYSCFG_EXTICR1, Section 8.2.3 p277)
  @ clear bits 0, 1, 2 at 0x40010008
  ldr r0, =(ADR_SYSCFG + 0x8) @ 0x40010008
  ldr r1, =0b000
  mov r2, 0
  mov r3, 3
  bl copy_bits

  @ turn on EXTI0 interrupts (EXTI_IMR1, Section 12.5.1 p330)
  @ EXTI_IMR_enable 0
  ldr r0, =ADR_EXTI @ 0x40010400
  ldr r1, =OFS_EXTI_IMR1  @ 0x0
  mov r2, 0
  bl set_bit

  @ set EXT0 to rising edge trigger (EXTI_RTSR1, Section 12.5.3 p331)
  @ EXTI_set_rising_edge_trigger 0
  ldr r0, =ADR_EXTI @ 0x40010400
  ldr r1, =OFS_EXTI_RTSR1 @ 0x8
  mov r2, 0
  bl set_bit

  @ enable EXTI0 (interrupt #6) in NVIC (NVIC_ISER0, Section B3.4.4 in ARM reference manual)
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ISER0
  mov r2, 6
  bl set_bit

  pop {lr}
  bx lr
.size joystick_init, .-joystick_init
