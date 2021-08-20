@ Utility functions and symbols

.syntax unified
@ --------------------- Module Interface --------------------

@ Function exports:
.global delay

@ --------------------- Implementation --------------------
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
