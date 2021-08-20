.syntax unified
@ --------------------- Module Interface --------------------
@ Symbol exports:
@ NOTE: these symbols should be used in the following way:
@   ldr r0, =SYMBOL

@ base addresses (ADR = address)
.global ADR_SYSCFG      @ 0x40010000
.global ADR_RCC         @ 0x40021000
.global ADR_EXTI        @ 0x40010400
.global ADR_SYST_CSR    @ 0xE000E010
.global ADR_SYST_RVR    @ 0xE000E014
.global ADR_SYST_CVR    @ 0xE000E018
.global ADR_NVIC        @ 0xE000E000
.global ADR_SCB_ICSR    @ 0xE000ED04
.global ADR_SCB_SHPR1   @ 0xE000ED18
.global ADR_SCB_SHPR2   @ 0xE000ED1C
.global ADR_SCB_SHPR3   @ 0xE000ED20
.global ADR_MPU,        @ 0xE000ED90
.global ADR_GPIOA       @ 0x48000000
.global ADR_GPIOB       @ 0x48000400
.global ADR_GPIOC       @ 0x48000800
.global ADR_GPIOD       @ 0x48000C00
.global ADR_GPIOE       @ 0x48001000
.global ADR_GPIOF       @ 0x48001400
.global ADR_GPIOG       @ 0x48001800
.global ADR_GPIOH       @ 0x48001C00

@ offsets (OFS = offset)
.global OFS_RCC_AHB2ENR  @ 0x4C
.global OFS_RCC_APB2ENR  @ 0x60
.global OFS_GPIOx_MODER  @ 0x00
.global OFS_GPIOx_PUPDR  @ 0x0C
.global OFS_GPIOx_ODR    @ 0x14
.global OFS_GPIOx_IDR    @ 0x10
.global OFS_NVIC_ISER0   @ 0x100
.global OFS_NVIC_ICER0   @ 0x180
.global OFS_NVIC_ISPR0   @ 0x200
.global OFS_NVIC_ICPR0   @ 0x280
.global OFS_NVIC_IABR0   @ 0x300
.global OFS_EXTI_IMR1    @ 0x0
.global OFS_EXTI_EMR1    @ 0x4
.global OFS_EXTI_RTSR1   @ 0x8
.global OFS_EXTI_FTSR1   @ 0xC
.global OFS_EXTI_PR1     @ 0x14
.global OFS_EXTI_IMR2    @ 0x20
.global OFS_EXTI_EMR2    @ 0x24
.global OFS_EXTI_RTSR2   @ 0x28
.global OFS_EXTI_FTSR2   @ 0x2C
.global OFS_EXTI_PR2     @ 0x34

@ RCC port pin indices (IDX = index)
.global IDX_GPIOA  @ 0
.global IDX_GPIOB  @ 1
.global IDX_GPIOC  @ 2
.global IDX_GPIOD  @ 3
.global IDX_GPIOE  @ 4
.global IDX_GPIOF  @ 5
.global IDX_GPIOG  @ 6
.global IDX_GPIOH  @ 7

@ --------------------- Implementation --------------------
.set ADR_SYSCFG,    0x40010000
.set ADR_RCC,       0x40021000
.set ADR_EXTI,      0x40010400
.set ADR_SYST_CSR,  0xE000E010
.set ADR_SYST_RVR,  0xE000E014
.set ADR_SYST_CVR,  0xE000E018
.set ADR_NVIC,      0xE000E000
.set ADR_SCB_ICSR,  0xE000ED04
.set ADR_SCB_SHPR1, 0xE000ED18
.set ADR_SCB_SHPR2, 0xE000ED1C
.set ADR_SCB_SHPR3, 0xE000ED20
.set ADR_ICSR,      0xE000ED00
.set ADR_SHPR,      0xE000ED14
.set ADR_MPU,       0xE000ED90
.set ADR_GPIOA,     0x48000000
.set ADR_GPIOB,     0x48000400
.set ADR_GPIOC,     0x48000800
.set ADR_GPIOD,     0x48000C00
.set ADR_GPIOE,     0x48001000
.set ADR_GPIOF,     0x48001400
.set ADR_GPIOG,     0x48001800
.set ADR_GPIOH,     0x48001C00

.set OFS_RCC_AHB2ENR, 0x4C
.set OFS_RCC_APB2ENR, 0x60
.set OFS_GPIOx_MODER, 0x00
.set OFS_GPIOx_PUPDR, 0x0C
.set OFS_GPIOx_ODR,   0x14
.set OFS_GPIOx_IDR,   0x10
.set OFS_NVIC_ISER0,  0x100
.set OFS_NVIC_ICER0,  0x180
.set OFS_NVIC_ISPR0,  0x200
.set OFS_NVIC_ICPR0,  0x280
.set OFS_NVIC_IABR0,  0x300
.set OFS_EXTI_IMR1,   0x0
.set OFS_EXTI_EMR1,   0x4
.set OFS_EXTI_RTSR1,  0x8
.set OFS_EXTI_FTSR1,  0xC
.set OFS_EXTI_PR1,    0x14
.set OFS_EXTI_IMR2,   0x20
.set OFS_EXTI_EMR2,   0x24
.set OFS_EXTI_RTSR2,  0x28
.set OFS_EXTI_FTSR2,  0x2C
.set OFS_EXTI_PR2,    0x34

.set IDX_GPIOA, 0
.set IDX_GPIOB, 1
.set IDX_GPIOC, 2
.set IDX_GPIOD, 3
.set IDX_GPIOE, 4
.set IDX_GPIOF, 5
.set IDX_GPIOG, 6
.set IDX_GPIOH, 7