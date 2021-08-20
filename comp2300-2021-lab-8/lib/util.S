@ Utility functions and symbols

.syntax unified
@ --------------------- Module Interface --------------------

@ Function exports:
.global set_bit, clear_bit, toggle_bit, write_bit, read_bit, copy_bits
.global delay

@ Symbol exports:
@ NOTE: these symbols should be used in the following way:
@   ldr r0, =SYMBOL

@ base addresses (ADR = address)
.global ADR_SYSCFG   @ 0x40010000
.global ADR_RCC      @ 0x40021000
.global ADR_EXTI     @ 0x40010400
.global ADR_NVIC     @ 0xE000E100
.global ADR_MPU      @ 0xE000ED90
.global ADR_SYSTICK  @ 0xE000E010
.global ADR_ICSR     @ 0xE000ED00
.global ADR_GPIOA    @ 0x48000000
.global ADR_GPIOB    @ 0x48000400
.global ADR_GPIOC    @ 0x48000800
.global ADR_GPIOD    @ 0x48000C00
.global ADR_GPIOE    @ 0x48001000
.global ADR_GPIOF    @ 0x48001400
.global ADR_GPIOG    @ 0x48001800
.global ADR_GPIOH    @ 0x48001C00

@ offsets (OFS = offset)
.global OFS_RCC_AHB2ENR  @ 0x4C
.global OFS_RCC_APB2ENR  @ 0x60
.global OFS_ICSR         @ 0x04
.global OFS_GPIOx_MODER  @ 0x00
.global OFS_GPIOx_PUPDR  @ 0x0C
.global OFS_GPIOx_ODR    @ 0x14
.global OFS_GPIOx_IDR    @ 0x10

@ RCC port pin indices (IDX = index)
.global IDX_RCC_GPIOA  @ 0
.global IDX_RCC_GPIOB  @ 1
.global IDX_RCC_GPIOC  @ 2
.global IDX_RCC_GPIOD  @ 3
.global IDX_RCC_GPIOE  @ 4
.global IDX_RCC_GPIOF  @ 5
.global IDX_RCC_GPIOG  @ 6
.global IDX_RCC_GPIOH  @ 7

@ --------------------- Implementation --------------------

@ bit fiddling utility functions
.type set_bit, %function
@ --parameters--
@ r0: base address
@ r1: offset
@ r2: bit index
set_bit:
  @ calculate address (base + offset), store in r0
  add r0, r1

  @ load current register value, store in r1
  ldr r1, [r0]

  @ align the "1" bit into the correct slot in r4
  mov r3, 1
  lsl r3, r2

  @ set the desired bit
  orr r1, r3

  @ write the data back
  str r1, [r0]
  bx lr
.size set_bit, .-set_bit

.type clear_bit, %function
@ --parameters--
@ r0: base address
@ r1: offset
@ r2: bit index
clear_bit:
  add r0, r1
  ldr r1, [r0]
  mov r3, 1
  lsl r3, r2
  @ clear the desired bit
  bic r1, r3
  str r1, [r0]
  bx lr
.size clear_bit, .-clear_bit

.type toggle_bit, %function
@ --parameters--
@ r0: base address
@ r1: offset
@ r2: bit index
toggle_bit:
  add r0, r1
  ldr r1, [r0]
  mov r3, 1
  lsl r3, r2
  @ toggle the desired bit
  eor r1, r3
  str r1, [r0]
  bx lr
.size toggle_bit, .-toggle_bit

.type write_bit, %function
@ --parameters--
@ r0: base address
@ r1: offset
@ r2: bit index
@ r3: data (LSB)
write_bit:
  add r0, r1
  push {r0} @ save base address + offset to stack
  ldr r1, [r0]
  @ first, clear the bit we're going to replace
  mov r0, 1
  lsl r0, r2
  bic r1, r0
  @ move the data bit into place and orr to "write" it
  and r3, 1   @ clear all but LSB
  lsl r3, r2
  orr r1, r3  @ then orr to set 0/1
  pop {r0}    @ restore base address + offset
  str r1, [r0]
  bx lr
.size write_bit, .-write_bit

.type read_bit, %function
@ --parameters--
@ r0: base address
@ r1: offset
@ r2: bit index
@ --return--
@ r0: bit<0> contains read bit
@ flags set
read_bit:
  add r1, r0
  ldr r0, [r1]
  lsr r0, r2
  ands r0, 1
  bx lr
.size read_bit, .-read_bit

.type copy_bits, %function
@ --parameters--
@ r0: address (base + offset)
@ r1: bits to copy
@ r2: least significant bit index
@ r3: width
copy_bits:
  push {r4}
  orn r4, 0
  lsl r4, r3
  orr r3, r4, r1  @ r3 = 0xff..f:bits
  rsb r2, 32
  ror r3, r2      @ r3 = 0xf..f:bits:f..f
  ror r1, r2      @ r1 = 0x0..0:bits:0..0
  ldr r4, [r0]
  orr r4, r1
  and r4, r3
  str r4, [r0]
  pop {r4}
  bx lr
.size copy_bits, .-copy_bits

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

@ Symbols
.set ADR_SYSCFG,   0x40010000
.set ADR_RCC,      0x40021000
.set ADR_EXTI,     0x40010400
.set ADR_NVIC,     0xE000E100
.set ADR_MPU,      0xE000ED90
.set ADR_SYSTICK,  0xE000E010
.set ADR_ICSR,     0xE000ED00
.set ADR_GPIOA,    0x48000000
.set ADR_GPIOB,    0x48000400
.set ADR_GPIOC,    0x48000800
.set ADR_GPIOD,    0x48000C00
.set ADR_GPIOE,    0x48001000
.set ADR_GPIOF,    0x48001400
.set ADR_GPIOG,    0x48001800
.set ADR_GPIOH,    0x48001C00

.set OFS_RCC_AHB2ENR, 0x4C
.set OFS_RCC_APB2ENR, 0x60
.set OFS_ICSR,        0x04
.set OFS_GPIOx_MODER, 0x00
.set OFS_GPIOx_PUPDR, 0x0C
.set OFS_GPIOx_ODR,   0x14
.set OFS_GPIOx_IDR,   0x10

.set IDX_RCC_GPIOA, 0
.set IDX_RCC_GPIOB, 1
.set IDX_RCC_GPIOC, 2
.set IDX_RCC_GPIOD, 3
.set IDX_RCC_GPIOE, 4
.set IDX_RCC_GPIOF, 5
.set IDX_RCC_GPIOG, 6
.set IDX_RCC_GPIOH, 7
