.syntax unified
.global main

.include "src/libcomp2300/macros.S"

.type main, %function
main:
  @ enable SYSCFG clock so that our changes to the SysTick control registers
  @ take effect
  RCC_APB2ENR_set 0

  @ enable SysTick, set interrupt trigger, and set processor as clock source
  @ by setting the three least-significant bits in the SysTick Control and Status
  @ Register (SYST_CSR), Section B3.3.3 on p677 of the ARMv7-M reference manual
  
  @ <your code goes here>

  @ configure red led
  GPIOx_clock_enable B
  GPIOx_clock_enable E
  GPIO_configure_output_pin B, 2
  GPIO_configure_output_pin E, 8
  
  @ setup the Systick
  ldr r0, =ADR_SYST_CSR
  mov r1, #0
  mov r2, #0
  bl set_bit
  ldr r0, =ADR_SYST_CSR
  mov r1, #0
  mov r2, #1
  bl set_bit
  ldr r0, =ADR_SYST_CSR
  mov r1, #0
  mov r2, #2
  bl set_bit

  ldr r0, =ADR_SYST_RVR
  ldr r1, =#400000
  str r1, [r0]

  @ manually creat two stacks
  bl create_process

@ and here's an infinite loop
loop:
  nop
  b loop
.size main, .-main

.global SysTick_Handler
.type SysTick_Handler, %function
SysTick_Handler:
  nop
  @ <your code goes here>

  ldr r1, =process_table
  ldr r0, [r1]

  if:
    @ which stack was executing
    cmp r0, 0
    beq then
  else:
    ldr sp, [r1, #4]
    mov r0, 0
    str r0, [r1]
    b remaining
  then:
    ldr sp, [r1, #8]
    mov r0, 1
    str r0, [r1]
  remaining:

  bx lr
.size SysTick_Handler, .-SysTick_Handler


.type create_process, %function
create_process:

  @ create a new stack pointer 1 and move it downwards
  ldr r1, =process_table
  ldr r0, [r1, #8]
  mov sp, r0
  sub sp, #32

  @ status register
  ldr r0, =0x01000000
  str r0, [sp, #28]
  @ pc
  ldr r0, =greenblink
  str r0, [sp, #24]
  @ lr
  ldr r0, =0x00000000
  str r0, [sp, #20]
  @ r12, r3-r0
  str r0, [sp, #16]
  str r0, [sp, #12]
  str r0, [sp, #8]
  str r0, [sp, #4]
  str r0, [sp]
  str sp, [r1, #8]

  @ create a new stack pointer 2 and move it downwards
  ldr r1, =process_table
  ldr r0, [r1, #4]
  mov sp, r0
  sub sp, #32

  @ status register
  ldr r0, =0x01000000
  str r0, [sp, #28]
  @ pc
  ldr r0, =redblink
  str r0, [sp, #24]
  @ lr
  ldr r0, =0x00000000
  str r0, [sp, #20]
  @ r12, r3-r0
  str r0, [sp, #16]
  str r0, [sp, #12]
  str r0, [sp, #8]
  str r0, [sp, #4]
  str r0, [sp]
  str sp, [r1, #4]

  bx lr
.size create_process, .-create_process


.type redblink, %function
redblink:

  redblink_loop:
    GPIOx_ODR_toggle B, 2
    mov r0, 0x80000
    bl delay
    b redblink_loop

.size redblink, .-redblink


.type greenblink, %function
greenblink:

  greenblink_loop:
    GPIOx_ODR_toggle E, 8
    mov r0, 0x40000
    bl delay
    b greenblink_loop

.size greenblink, .-greenblink

.data
process_table:
.word 0 @ index of currently-operating process
.word 0x20008000 @ stack pointer 1
.word 0x20007000 @ stack pointer 2