@ Simple LED library
@ NOTE: This module depends on utils.S
.syntax unified

@ --------------------- Module Interface --------------------
@ declare all labels corresponding to functions designed to be called from elsewhere
@ as global - this is the public API of the library
@ Function exports:
.global red_led_init, red_led_on, red_led_off, red_led_toggle
.global green_led_init, green_led_on, green_led_off, green_led_toggle

@ --------------------- Implementation --------------------

@ ----------
@ red led

.type red_led_init, %function
@ --parameters--
@ none
red_led_init:
  push {lr}
  @ load r0 with the base address of RCC, see manual pg. 69
  @ enable GPIOB by setting bit 2 high
  @ GPIOx_clock_enable B
  ldr r0, =ADR_RCC
  ldr r1, =OFS_RCC_AHB2ENR
  ldr r2, =IDX_RCC_GPIOB
  bl set_bit

  @ load r0 with base address of GPIOB, see manual pg. 68
  @ set PB2 to output by setting bit 4 high , and bit 5 low
  @ GPIOx_MODER_write B 2 0x1
  ldr r0, =ADR_GPIOB
  ldr r1, =OFS_GPIOx_MODER
  add r0, r1
  ldr r1, =0x1
  ldr r2, =2
  lsl r2, 1
  ldr r3, =2
  bl copy_bits

  pop {lr}
  bx lr
.size red_led_init, .-red_led_init

.type red_led_on, %function
@ --parameters--
@ none
red_led_on:
  @ save lr to stack
  push {lr}
  @ prepare parameters, call set_bit
  @ GPIOx_ODR_set B 2
  ldr r0, =ADR_GPIOB
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =2
  bl set_bit
  
  @ restore lr from stack
  pop {lr}
  bx lr
.size red_led_on, .-red_led_on
.type red_led_on, %function

.type red_led_off, %function
@ --parameters--
@ none
red_led_off:
  push {lr}
  @ prepare parameters, call clear_bit
  @ GPIOx_ODR_clear B 2
  ldr r0, =ADR_GPIOB
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =2
  bl clear_bit
  
  pop {lr}
  bx lr
.size red_led_off, .-red_led_off


.type red_led_toggle, %function
@ --parameters--
@ none
red_led_toggle:
  push {lr}
  @ prepare parameters, call toggle_bit
  @ GPIOx_ODR_toggle B 2
  ldr r0, =ADR_GPIOB
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =2
  bl toggle_bit
  
  pop {lr}
  bx lr
.size red_led_toggle, .-red_led_toggle

@ ----------
@ green led

.type green_led_init, %function
@ --parameters--
@ none
green_led_init:
  push {lr}
  @ load r0 with the base address of RCC, see manual pg. 69
  @ enable GPIOB by setting bit 2 high
  @ GPIOx_clock_enable E
  ldr r0, =ADR_RCC
  ldr r1, =OFS_RCC_AHB2ENR
  ldr r2, =IDX_RCC_GPIOE
  bl set_bit

  @ load r0 with base address of GPIOB, see manual pg. 68
  @ set PB2 to output by setting bit 4 high , and bit 5 low
  @ GPIOx_MODER_write E 8 0x1
  ldr r0, =ADR_GPIOE
  ldr r1, =OFS_GPIOx_MODER
  add r0, r1
  ldr r1, =0x1
  ldr r2, =8
  lsl r2, 1
  ldr r3, =2
  bl copy_bits

  pop {lr}
  bx lr
.size green_led_init, .-green_led_init

.type green_led_on, %function
@ --parameters--
@ none
green_led_on:
  @ save lr to stack
  push {lr}
  @ prepare parameters, call set_bit
  @ GPIOx_ODR_set E 8
  ldr r0, =ADR_GPIOE
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =8
  bl set_bit
  
  @ restore lr from stack
  pop {lr}
  bx lr
.size green_led_on, .-green_led_on
.type green_led_on, %function

.type green_led_off, %function
@ --parameters--
@ none
green_led_off:
  push {lr}
  @ prepare parameters, call clear_bit
  @ GPIOx_ODR_clear E 8
  ldr r0, =ADR_GPIOE
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =8
  bl clear_bit
  
  pop {lr}
  bx lr
.size green_led_off, .-green_led_off


.type green_led_toggle, %function
@ --parameters--
@ none
green_led_toggle:
  push {lr}
  @ prepare parameters, call toggle_bit
  @ GPIOx_ODR_toggle E 8
  ldr r0, =ADR_GPIOE
  ldr r1, =OFS_GPIOx_ODR
  ldr r2, =8
  bl toggle_bit
  
  pop {lr}
  bx lr
.size green_led_toggle, .-green_led_toggle
