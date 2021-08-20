.include "src/libcomp2300/macros.S"
.syntax unified
.global main, EXTI1_IRQHandler, EXTI2_IRQHandler,EXTI9_5_IRQHandler, EXTI15_10_IRQHandler

.type main, %function
main:

  @ Reminder:
  @ PD0 -> output; PB7 input (board left PA1)
  @ PE13 -> output; PB14 input (board right PA2)
  
  @ PortE and H
  GPIOx_clock_enable A
  GPIOx_clock_enable B
  GPIOx_clock_enable D
  GPIOx_clock_enable E

  @ enable SYSCFG clock
  RCC_APB2ENR_set 0

  @ set the pin to input/output
  GPIO_configure_output_pin E, 8
  GPIO_configure_output_pin B, 2
  GPIO_configure_output_pin D, 0
  GPIO_configure_output_pin E, 13
  GPIO_configure_input_pin_it A, 1
  GPIO_configure_input_pin_it A, 2
  GPIO_configure_input_pin_it B, 7
  GPIO_configure_input_pin_it E, 14

  @ set EXTI and NVIC for interrupt
  EXTI_set_rising_edge_trigger 1
  EXTI_set_rising_edge_trigger 2
  EXTI_set_rising_edge_trigger 7
  EXTI_set_falling_edge_trigger 7
  EXTI_set_rising_edge_trigger 14
  EXTI_set_falling_edge_trigger 14
  NVIC_set ISER 7
  NVIC_set ISER 23
  NVIC_set ISER 40

  @ intially the left's turn
  GPIOx_ODR_toggle B, 2

  @ infinite loop
  loop:
    nop
    b loop

.size main, .-main


@ the interrupt handler for left button
.type EXTI1_IRQHandler, %function
EXTI1_IRQHandler:

  push {lr}

  @ toggle the red led
  GPIOx_ODR_toggle B, 2

  @ toggle the PD0
  GPIOx_ODR_toggle D, 0

  @ clear the pending bit
  EXTI_PR_clear_pending 1

  NVIC_set ICER 7

  pop {lr}

  bx lr
.size EXTI1_IRQHandler, .-EXTI1_IRQHandler


@ the interrupt handler for the right button
.type EXTI2_IRQHandler, %function
EXTI2_IRQHandler:

  push {lr}

  @ toggle the green led
  GPIOx_ODR_toggle E, 8

  @ toggle the PE13
  GPIOx_ODR_toggle E, 13

  @ clear the pending bit
  EXTI_PR_clear_pending 2

  @ disable the interrupt handler for the right button
  NVIC_set ICER 8

  pop {lr}

  bx lr
.size EXTI2_IRQHandler, .-EXTI2_IRQHandler


.type EXTI9_5_IRQHandler, %function
EXTI9_5_IRQHandler:

  push {lr}

  @ clear the left button pending bit and enable the interrupt handler for LHS
  EXTI_PR_clear_pending 1
  NVIC_set ICPR 7
  NVIC_set ISER 7

  @ toggle the red led
  GPIOx_ODR_toggle B, 2

  @ clear the pending bit
  EXTI_PR_clear_pending 7

  pop {lr}

  bx lr
.size EXTI9_5_IRQHandler, .-EXTI9_5_IRQHandler

.type EXTI15_10_IRQHandler, %function
EXTI15_10_IRQHandler:

  push {lr}

  @ clear the pending bit for the right button and enable the interrupt handler for RHS
  EXTI_PR_clear_pending 2
  NVIC_set ICPR 8
  NVIC_set ISER 8

  @ toggle the green led
  GPIOx_ODR_toggle E, 8

  @ clear the pending bit
  EXTI_PR_clear_pending 14

  pop {lr}

  bx lr
.size EXTI15_10_IRQHandler, .-EXTI15_10_IRQHandler