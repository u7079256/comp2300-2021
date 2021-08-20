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
@ r0: position (see table on 11.3 @Disco reference manual)
@ r1: priority (4 bits, 1111 = lowest priority, 0000 = highest priority)
NVIC_IPR_set_priority:
  push {lr}
  @ shuffle registers
  mov r3, r1
  @ calculate the memory offset from the position
  mov r1, 4
  sdiv r1, r0, r1
  lsl r1, 2
  @ calculate the bit shift for the priority
  sub r2, r0, r1
  lsl r2, 3
  add r2, 4
  @ load the IPRx register at ADR_NVIC + 400
  ldr r0, =0xE000E400
  ldr r0, [r0, r1]
  @ clear the bits
  push {r3}
  mov r3, 0b1111
  lsl r3, r2
  bic r0, r3
  pop {r3}
  @ write the bits
  lsl r3, r2
  orr r0, r3
  @ save the new priority
  ldr r2, =0xE000E400
  str r0, [r2, r1]
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
