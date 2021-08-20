.syntax unified

@ These macros are defined to be simple wrappers for function calls.
@ to use them, add
@   .include "src/libcomp2300/macros.S"
@
@ These macros uses definitions in utils.S, bitops.S and symbols.S

@ macro for modulo operation
@ Rd, Rn, Rm must be different!
.macro mod Rd Rn Rm
  sdiv \Rd, \Rn, \Rm
  mul \Rd, \Rm
  rsb \Rd, \Rn
.endm

.macro RCC_AHB2ENR_write position value
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_AHB2ENR
    ldr r2, =\position
    ldr r3, =\value
    bl write_bit
.endm

.macro RCC_AHB2ENR_set position
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_AHB2ENR
    ldr r2, =\position
    bl set_bit
.endm

.macro RCC_AHB2ENR_clear position
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_AHB2ENR
    ldr r2, =\position
    bl clear_bit
.endm

.macro RCC_APB2ENR_write position value
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_APB2ENR
    ldr r2, =\position
    ldr r3, =\value
    bl write_bit
.endm

.macro RCC_APB2ENR_set position
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_APB2ENR
    ldr r2, =\position
    bl set_bit
.endm

.macro RCC_APB2ENR_clear position
    ldr r0, =ADR_RCC
    ldr r1, =OFS_RCC_APB2ENR
    ldr r2, =\position
    bl clear_bit
.endm

@ GPIO macros
.macro GPIOx_clock_enable port
    RCC_AHB2ENR_set IDX_GPIO\port
.endm

@ note that these arithmetic and shift expressions (e.g. +, <<)
@ are evaluated at compile time!
.macro GPIOx_MODER_write port pin mode
    ldr r0, =(ADR_GPIO\port + 0x0)
    ldr r1, =\mode
    ldr r2, =(\pin << 1)
    ldr r3, =2
    bl copy_bits
.endm

.macro GPIOx_PUPDR_write port pin mode
    ldr r0, =(ADR_GPIO\port + 0xC)
    ldr r1, =\mode
    ldr r2, =(\pin << 1)
    ldr r3, =2
    bl copy_bits
.endm

.macro GPIOx_ODR_write port pin data
    ldr r0, =ADR_GPIO\port
    ldr r1, =OFS_GPIOx_ODR
    ldr r2, =\pin
    ldr r3, =\data
    bl write_bit
.endm

.macro GPIOx_ODR_set port pin
    ldr r0, =ADR_GPIO\port
    ldr r1, =OFS_GPIOx_ODR
    ldr r2, =\pin
    bl set_bit
.endm

.macro GPIOx_ODR_clear port pin
    ldr r0, =ADR_GPIO\port
    ldr r1, =OFS_GPIOx_ODR
    ldr r2, =\pin
    bl clear_bit
.endm

.macro GPIOx_ODR_toggle port pin
    ldr r0, =ADR_GPIO\port
    ldr r1, =OFS_GPIOx_ODR
    ldr r2, =\pin
    bl toggle_bit
.endm

.macro GPIOx_IDR_read port pin
    ldr r0, =ADR_GPIO\port
    ldr r1, =OFS_GPIOx_IDR
    ldr r2, =\pin
    bl read_bit
.endm

@ ICSR
.macro ICSR_set pos
    ldr r0, =ADR_SCB_ICSR
    mov r1, 0
    ldr r2, =\pos
    bl set_bit
.endm

.macro ICSR_clear pos
    ldr r0, =ADR_SCB_ICSR
    mov r1, 0
    ldr r2, =\pos
    bl clear_bit
.endm

@ Interrupt related

@ EXTI

.macro SYSCFG_EXTIxCR_write port pin
    @ calculate the address of the register to write to (e.g. SYSCFG_EXTICR*n*)
    ldr r0, =(ADR_SYSCFG + 0x8 + 4 * (\pin / 4))
    ldr r1, [r0]
    @ insert port index (i.e. A=0, B=1, etc.) to appropriate bits in SYSCFG_EXTICR*n*
    ldr r2, =IDX_GPIO\port
    bfi r1, r2, 4 * (\pin % 4), 3
    str r1, [r0]
.endm

@ enable interrupt in EXTI interrupt mask register
.macro EXTI_IMR_enable number
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_IMR1
    ldr r2, =\number
    bl set_bit
.endm

.macro EXTI_IMR_disable number
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_IMR1
    ldr r2, =\number
    bl clear_bit
.endm

.macro EXTI_set_rising_edge_trigger pin
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_RTSR1
    ldr r2, =\pin
    bl set_bit
.endm

.macro EXTI_set_falling_edge_trigger pin
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_FTSR1
    ldr r2, =\pin
    bl set_bit
.endm

@ to trigger a software interrupt
.macro EXTI_PR_set_pending pin
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_SWIER1
    ldr r2, =\pin
    bl set_bit
.endm

@ to see if an interrupt has been triggered
.macro EXTI_PR_check_pending pin
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_PR1
    ldr r2, =\pin
    bl read_bit
.endm

@ to clear an already-triggered interrupt
@ (note: to *clear* a "pending" interrupt,
@  you need to *set* the bit in EXTI_PR1)
.macro EXTI_PR_clear_pending pin
    ldr r0, =ADR_EXTI
    ldr r1, =OFS_EXTI_PR1
    mov r2, 1
    lsl r2, \pin
    str r2, [r0, r1]
.endm

@ NVIC

.macro NVIC_read register position
    ldr r0, =ADR_NVIC
    ldr r1, =(OFS_NVIC_\register\()0)
    ldr r2, =(4 * (\position / 32))
    add r1, r2
    ldr r2, =(\position % 32)
    bl read_bit
.endm

.macro NVIC_set register position
    ldr r0, =ADR_NVIC
    ldr r1, =OFS_NVIC_\register\()0
    ldr r2, =(4 * (\position / 32))
    add r1, r2
    ldr r2, =(1 << (\position % 32))
    str r2, [r0, r1]
.endm

@ high-level helper macros

.macro GPIO_configure_output_pin port pin
  GPIOx_MODER_write \port, \pin, 0b01
.endm

.macro GPIO_configure_input_pin port pin
  GPIOx_MODER_write \port, \pin, 0b00
  GPIOx_PUPDR_write \port, \pin, 0b10
.endm

@ this one also enables the interrupts, although it's up to you to
@ make sure the appropriate EXTI interrupt is enabled in the NVIC
@ and that the handler function exists
.macro GPIO_configure_input_pin_it port pin
  GPIO_configure_input_pin \port, \pin
  ldr r0, =IDX_GPIO\port
  mov r1, \pin
  SYSCFG_EXTIxCR_write \port \pin
  EXTI_IMR_enable \pin
.endm
