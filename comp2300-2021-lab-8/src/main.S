.syntax unified
.global main

.type main, %function
main:
  bl green_led_init

  ldr r4, =input_string
  ldr r5, =morse_table

  while:
    ldrb r1, [r4], #1
    if_2:
      cmp r1, 0
      beq loop
    if_3:
      cmp r1, 90
      bgt then_3
    else_3:
      if_4:
        cmp r1, 57
        bgt then_4
      else_4:
        sub r1, 22
        b remaining_4
      then_4:
        sub r1, 65
      remaining_4:
      b remaining_3
    then_3:
      sub r1, 97
    remaining_3:
      mov r2, 24
      mul r1, r2
      add r0, r5, r1
      bl blink_codepoint
      b while

  loop:
    nop
    b loop

  b main
.size main, .-main


.type blink_dot, %function
blink_dot:
  push {lr}
  
  @ turn on the green_led and delay then turn off (1 dot length)
  bl green_led_on
  mov r0, 0x20000
  bl delay
  bl green_led_off

  @ delay before returning
  mov r0, 0x20000
  bl delay

  pop {lr}
  bx lr
.size blink_dot, .-blink_dot


.type blink_dash, %function
blink_dash:
  push {lr}

  @ turn on the green_led and delay then turn off (3 dot length)
  bl green_led_on
  mov r0, 0x60000
  bl delay
  bl green_led_off

  @ delay before returning
  mov r0, 0x20000
  bl delay

  pop {lr}
  bx lr
.size blink_dash, .-blink_dash


.type blink_space, %function
blink_space:
  push {lr}

  @ delay for 7 dot length
  mov r0, 0x20000
  mov r1, 7
  mul r0, r1
  bl delay

  pop {lr}
  bx lr
.size blink_space, .-blink_space

.type blink_codepoint, %function
blink_codepoint:
  push {lr}

  ldr r1, [r0], #4  @ number of dot/dash
  mov r2, 0

  while_condition:
    cmp r2, r1  @ whether finished
    beq return

  while_loop:
    ldr r3, [r0], #4  @ dash/dot
    push {r0, r1, r2, r3}

    if_1:
      cmp r3, 0
      beq then_1
    else_1:
      bl blink_dash
      b remaining_1
    then_1:
      bl blink_dot
    remaining_1:
      pop {r0, r1, r2, r3}
      add r2, 1
      b while_condition
  
  return:
    bl blink_space  @ delay before return
    pop {lr}
    bx lr
.size blink_codepoint, .-blink_codepoint

.data
input_string:
.asciz "31415926"

@ to make sure our table starts on a word boundary
.align 2

@ Each entry in the table is 6 words long
@ - The first word is the number of dots and dashes for this entry
@ - The next 5 words are 0 for a dot, 1 for a dash, or padding (value doesn't matter)
@
@ E.g., 'G' is dash-dash-dot. There are 2 extra words to pad the entry size to 6 words
morse_table:
  .word 2, 0, 1, 0, 0, 0 @ A
  .word 4, 1, 0, 0, 0, 0 @ B
  .word 4, 1, 0, 1, 0, 0 @ C
  .word 3, 1, 0, 0, 0, 0 @ D
  .word 1, 0, 0, 0, 0, 0 @ E
  .word 4, 0, 0, 1, 0, 0 @ F
  .word 3, 1, 1, 0, 0, 0 @ G
  .word 4, 0, 0, 0, 0, 0 @ H
  .word 2, 0, 0, 0, 0, 0 @ I
  .word 4, 0, 1, 1, 1, 0 @ J
  .word 3, 1, 0, 1, 0, 0 @ K
  .word 4, 0, 1, 0, 0, 0 @ L
  .word 2, 1, 1, 0, 0, 0 @ M
  .word 2, 1, 0, 0, 0, 0 @ N
  .word 3, 1, 1, 1, 0, 0 @ O
  .word 4, 0, 1, 1, 0, 0 @ P
  .word 4, 1, 1, 0, 1, 0 @ Q
  .word 3, 0, 1, 0, 0, 0 @ R
  .word 3, 0, 0, 0, 0, 0 @ S
  .word 1, 1, 0, 0, 0, 0 @ T
  .word 3, 0, 0, 1, 0, 0 @ U
  .word 4, 0, 0, 0, 1, 0 @ V
  .word 3, 0, 1, 1, 0, 0 @ W
  .word 4, 1, 0, 0, 1, 0 @ X
  .word 4, 1, 0, 1, 1, 0 @ Y
  .word 4, 1, 1, 0, 0, 0 @ Z
  .word 5, 1, 1, 1, 1, 1 @ 0 -> index 26
  .word 5, 0, 1, 1, 1, 1 @ 1 
  .word 5, 0, 0, 1, 1, 1 @ 2
  .word 5, 0, 0, 0, 1, 1 @ 3
  .word 5, 0, 0, 0, 0, 1 @ 4
  .word 5, 0, 0, 0, 0, 0 @ 5
  .word 5, 1, 0, 0, 0, 0 @ 6
  .word 5, 1, 1, 0, 0, 0 @ 7
  .word 5, 1, 1, 1, 0, 0 @ 8
  .word 5, 1, 1, 1, 1, 0 @ 9