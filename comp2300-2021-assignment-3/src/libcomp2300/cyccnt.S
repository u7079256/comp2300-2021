@ A simple library for interacting with the Cycle count register for
@ performance measuring
.global CYCCNT_init, CYCCNT_read, CYCCNT_reset

@ Usage Instructions:
@ First initialise the cycle count register (CYCCNT) by calling CYCCNT_init
@ Then when you want to measure how many clock cycles a piece of code takes
@ to execute, call the CYCCNT_reset function just before the code you want
@ to run. then after the code is done run CYCCNT_read to return the number
@ of clock cycles into r0. for more information refer to pages 797 - 801
@ of the ARMv7-m Architecture Reference Manual

@ A function to initialise the cycle count register
.type CYCCNT_init, %function
CYCCNT_init: @ sets up the Cycle Count Register
  ldr r0, =#0xE0001000 @ address to the DWT_CTRL register
  ldr r1, [r0]
  mov r2, #0b1
  orr r1, r2
  str r1, [r0]
  bx lr
.size CYCCNT_init, .-CYCCNT_init

@ A function to reset the cycle count register back to 0
.type CYCCNT_reset, %function
CYCCNT_reset:
  ldr r0, =#0xE0001004 @ address to the DWT_CYCCNT register
  mov r1, #0
  str r1, [r0]
  bx lr
.size CYCCNT_reset, .-CYCCNT_reset

@ A function to read the current value of the cycle count register
@ returns the current value in r0
.type CYCCNT_read, %function
CYCCNT_read:
  ldr r0, =#0xE0001004
  ldr r0, [r0]
  bx lr
.size CYCCNT_read, .-CYCCNT_read
