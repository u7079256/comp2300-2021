.syntax unified

@ --------------------- Module Interface --------------------
.global joystick_init

.include "src/libcomp2300/macros.S"

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
  GPIOx_clock_enable A

  @ enable SYSCFG clock (RCC_APB2ENR, Section 6.4.21 p233)
  RCC_APB2ENR_set 0

  mov r0, 5
  bl delay

  GPIO_configure_input_pin_it A, 0
  EXTI_set_rising_edge_trigger 0

  @ enable EXTI0 (interrupt #6) in NVIC (NVIC_ISER0, Section B3.4.4 in ARM reference manual)
  NVIC_set ISER 6

  pop {lr}
  bx lr
.size joystick_init, .-joystick_init
