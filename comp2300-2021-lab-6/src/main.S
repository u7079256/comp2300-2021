.syntax unified
.global main

.type main, %function
main:
  ldr r0, =0xcafe0000
  ldr r1, =0xffff

  @ your code goes here
  @ 1. 0xcafeffff into r3
  orr r3, r0, r1
  @ 2. 0xcafe into r4
  lsr r4, r0, 16
  @ 3. 0xcaff0000 into r5
  orr r5, r0, 0x000f0000
  @ 4. 0xc0fe0000 into r6
  bic r6, r0, 0x0f000000

  ldr r0, =main

  instruction1:
    movs r3, 1
  instruction2:
    ldr r0, =instruction2
    ldr r1, =instruction1
    sub r0, r1

  @ Exercise 2
  ldr r1, =storage
  ldr r0, [r1, #12]
  orr r0, #1
  str r0, [r1, #12]

  @ Exercise 4
  ldr r0, =0x40021000
  movs r1, 0x4c
  movs r2, #2
  bl set_bit

  ldr r0, =0x40021000
  movs r1, 0x4c
  movs r2, #5
  bl set_bit

  ldr r0, =0x48000400
  movs r1, #0
  movs r2, #6
  bl clear_bit

  ldr r0, =0x48000400
  movs r1, #0
  movs r2, #5
  bl set_bit

  ldr r0, =0x48001000
  movs r1, #0
  movs r2, #18
  bl clear_bit

  ldr r0, =0x48001000
  movs r1, #0
  movs r2, #17
  bl set_bit

  for_init:
    mov r4, 0
    mov r5, 101
  for_loop:
    mov r0, r4
    bl divisible
    bl selection_fizz
    add r4, 1
    cmp r4, r5
    beq for_end
    b for_loop
  for_end:
    b for_init
@ when it's all done, spin in an infinite loop
  loop:
    nop
    b loop
.size main, .-main

.type set_bit, %function
set_bit:
  push {r4, r5}
  @ r4 is loaded value
  ldr r4, [r0, r1]
  @ r5 store the desired bit
  movs r5, 1
  loop1:
    subs r2, 1
    lsl r5, 1
    cmp r2, 1
    bne loop1
  orr r4, r5
  str r4, [r0, r1]
  pop {r4, r5}
  bx lr
.size set_bit, .-set_bit

.type clear_bit, %function
clear_bit:
  push {r4, r5}
  @ r4 is loaded value
  ldr r4, [r0, r1]
  @ r5 store the desired bit
  movs r5, 1
  loop2:
    subs r2, 1
    lsl r5, 1
    cmp r2, 1
    bne loop2
  bic r4, r5
  str r4, [r0, r1]
  pop {r4, r5}
  bx lr
.size clear_bit, .-clear_bit

.type delay, %function
delay:
  loop3:
    subs r0, 1
    bne loop3
  bx lr
.size delay, .-delay

.type divisible, %function
divisible:
  push {r0}
  @ check whether divisible by 3
  sub_loop3:
    subs r0, #3
    beq case_3_2
    bmi case_3_1
    b sub_loop3
  case_3_1:
    mov r1, 0
    b check_5
  case_3_2:
    mov r1, 1
  check_5:
  pop {r0}
  @ check whether divisible by 5
  sub_loop5:
    subs r0, #5
    beq case_5
    bmi return
    b sub_loop5
  case_5:
    add r1, #2
  return:
    bx lr

@ blink red once
.type blink_red, %function
blink_red:
  push {lr}
  @ turn on
  ldr r0, =0x48000400
  movs r1, 0x14
  movs r2, #3
  bl set_bit
  @ delay
  ldr r0, =0x50000
  bl delay
  @ turn off
  ldr r0, =0x48000400
  movs r1, 0x14
  movs r2, #3
  bl clear_bit
  @ return
  pop {lr}
  bx lr
.size blink_red, .-blink_red

@ blink green once
.type blink_green, %function
blink_green:
  push {lr}
  @ turn on
  ldr r0, =0x48001000
  movs r1, 0x14
  movs r2, #9
  bl set_bit
  @ delay
  ldr r0, =0x50000
  bl delay
  @ turn off
  ldr r0, =0x48001000
  movs r1, 0x14
  movs r2, #9
  bl clear_bit
  @ return
  pop {lr}
  bx lr
.size blink_green, .-blink_green

@ blink both LED
.type blink_both, %function
blink_both:
  push {lr}
  @ turn on
  ldr r0, =0x48000400
  movs r1, 0x14
  movs r2, #3
  bl set_bit
  
  ldr r0, =0x48001000
  movs r1, 0x14
  movs r2, #9
  bl set_bit
  @ delay
  ldr r0, =0x50000
  bl delay
  @ turn off
  ldr r0, =0x48000400
  movs r1, 0x14
  movs r2, #3
  bl clear_bit
    
  ldr r0, =0x48001000
  movs r1, 0x14
  movs r2, #9
  bl clear_bit
  @ return
  pop {lr}
  bx lr
.size blink_both, .-blink_both


.type selection_fizz, %function
selection_fizz:
  push {lr}
  if_1:
    cmp r1, 0
    beq return_statement
  else_1:
    if_2:
      cmp r1, 1
      beq then_2
    else_2:
      if_3:
        cmp r1, 2
        beq then_3
      @ blink both
      else_3:
        bl blink_both
        b return_statement
      @ blink green
      then_3:
        bl blink_green
      b return_statement
    @ blink red
    then_2:
      bl blink_red
  return_statement:
    ldr r0, =0x50000
    bl delay
    pop {lr}
    bx lr
.size selection_fizz, .-selection_fizz

.data
storage:
  .word 2, 3, 0, 0 @ don't change this line