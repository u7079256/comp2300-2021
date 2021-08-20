.syntax unified
.global main
.global SysTick_Handler, EXTI0_IRQHandler

.type main, %function
main:
  
  @ initialize
  bl green_led_init
  bl red_led_init
  bl joystick_init

  @ disable EXTI0 (interrupt #6) in NVIC (NVIC_ICER0)
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ICER0
  mov r2, 6
  bl set_bit

  @ SYST_CSR preparation
  ldr r0, =ADR_SYST_CSR
  mov r1, 0
  mov r2, 0
  bl set_bit  @ SYSTICK Enable

  ldr r0, =ADR_SYST_CSR
  mov r1, 0
  mov r2, 1
  bl set_bit  @ TICKINT Set

  ldr r0, =ADR_SYST_CSR
  mov r1, 0
  mov r2, 2
  bl set_bit  @ CLKSOURCE -> CPU

  ldr r0, =ADR_SYST_RVR
  ldr r1, =#4000000
  mov r2, 0
  mov r3, 24
  bl copy_bits

  ldr r0, =ADR_SCB_SHPR3
  mov r1, #1
  mov r2, #28
  mov r3, #1
  bl copy_bits

  finished:
    nop
    b finished
    
.size main, .-main


.type SysTick_Handler, %function
SysTick_Handler:

  @ to ensure that the red led blink every 5 seconds
  ldr r0, =loop_counter
  ldr r1, [r0]
  sub r1, 1
  str r1, [r0]
  cmp r1, 0
  bne return

  push {lr}

  @ clear EXTI pending bit
  ldr r0, =ADR_EXTI
  ldr r1, =OFS_EXTI_PR1
  mov r2, #0
  bl set_bit

  @ clear NVIC pending bit
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ICPR0
  mov r2, #6
  bl set_bit

  @ enable EXTI0 (interrupt #6) in NVIC (NVIC_ISER0)
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ISER0
  mov r2, 6
  bl set_bit

  @ turn on the red led and delay
  bl red_led_on
  ldr r1, =duration
  ldr r0, [r1]
  bl delay
  bl red_led_off

  @ disable EXTI0 (interrupt #6) in NVIC (NVIC_ICER0)
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ICER0
  mov r2, 6
  bl set_bit

  @ pop the lr and reload loop counter r41
  pop {lr}
  ldr r0, =loop_counter
  mov r1, #5
  str r1, [r0]

  return:
    bx lr
.size SysTick_Handler, .-SysTick_Handler


.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  push {lr}

  @ turn on the green led and delay
  bl green_led_on
  mov r0, 0xf0000
  bl delay
  bl green_led_off

  @ half the duration of red led
  ldr r1, =duration
  ldr r0, [r1]
  lsr r0, 1
  str r0, [r1]

  @ clear the EXTI pending register, line 6
  ldr r0, =ADR_EXTI
  ldr r1, =OFS_EXTI_PR1
  mov r2, 0
  bl set_bit  

  pop {lr}
  bx lr
.size EXTI0_IRQHandler, .-EXTI0_IRQHandler

.data
loop_counter:
  .word 5
duration:
  .word 0xf0000