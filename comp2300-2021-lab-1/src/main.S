.syntax unified
.global main

.type main, %function
main:
  mov r1, 0

loop:
  add r1, 1
  b loop