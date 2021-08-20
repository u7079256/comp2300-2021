.syntax unified
@ --------------------- Module Interface --------------------

@ Function exports:
.global delay
.global NVIC_IPR_set_priority, SHPR_set_priority

@ --------------------- Implementation --------------------
.include "src/libcomp2300/macros.S"

.type delay, %function
@ --parameters--
@ r0: delay amount
delay:
  subs r0, 1
  bmi delay_return
  b delay
delay_return:
  bx lr
.size delay, .-delay

@ Other helper functions

@ interrupt priorities

.type NVIC_IPR_set_priority, %function
@ --parameters--
@ r0: position
@ r1: priority
NVIC_IPR_set_priority:
  push {lr}
  @ r2 = 4 * (pos // 4)
  @ r3 = 8 * (pos mod 4) + 4
  lsr r2, r0, 2
  lsl r2, 2
  sub r3, r0, r2
  lsl r3, 3
  add r3, 4

  ldr r0, =(ADR_NVIC + 0x300)
  add r0, r2
  mov r2, r3
  mov r3, 4
  bl copy_bits

  pop {lr}
  bx lr
.size NVIC_IPR_set_priority, .-NVIC_IPR_set_priority

.type SHPR_set_priority, %function
@ --parameters--
@ r0: position
@ r1: priority
SHPR_set_priority:
  push {lr}
  @ r2 = 4 * (pos // 4)
  @ r3 = 8 * (pos mod 4) + 4
  lsr r2, r0, 2
  lsl r2, 2
  sub r3, r0, r2
  lsl r3, 3
  add r3, 4

  ldr r0, =0xE000ED14
  add r0, r2
  mov r2, r3
  mov r3, 4
  bl copy_bits

  pop {lr}
  bx lr
.size SHPR_set_priority, .-SHPR_set_priority
