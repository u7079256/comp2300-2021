.syntax unified
.global main

cope:
  .ascii "COPE"

.type main, %function
main:
  nop

  @ move value 2 into register 1
  @ In memory address 0x0800018A, looks like 0x0221
  movs r1, 2
  @ add value 2 to register 1
  @ In memory address 0x0800018C, looks like 0x0231
  adds r1, 2

  @ machine code for `movs r1, 3` 0b0010000100000011
  .hword 0x2103
  @ machine code for `subs r1, 1` 0b0011100100000001
  .hword 0x3901

  @ "COPE" is treated as 'C', 'O', 'P', 'E' bytes 
  @ and storeed in the memory. So it's still COPE in memory
  @ When we load it into r1, it reversed to "EPOC"
  ldr r1, cope
  @ "HOPE" -> add 5 to the least significant bit
  add r2, r1, #5
  @ "HOPS" -> add 14 to the most significant bit
  mov r3, #14
  add r3, r2, r3, lsl 24

  loop:
    nop
    b loop
.size main, .-main