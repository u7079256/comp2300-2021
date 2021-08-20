.syntax unified

// this code is a little wrapper around Ben's audio and clock libraries
// so that they expose functions similar to the ones we've used over the
// last couple of years.

.global init
.type init, %function
init:
    push {r4, lr}

    @ Detect if init has already been called
    ldr r0, =init_called
    ldr r1, [r0]
    cmp r1, 0
    bne already_called_init
    mov r1, 1
    str r1, [r0]

    @ Initialise peripherals
    bl clock_init
    bl audio_init

    @ Delay 1/4 seconds to let the audio output "warm up"
    ldr r4, =12000
    delay_loop:
    mov r0, -1
    bl BSP_AUDIO_OUT_Play_Sample
    subs r4, 1
    bne delay_loop

    @ Randomise scratch registers
    mov r0, 0xABABABAB
    mov r1, 0x00001234
    mov r2, 0x99009900
    mov r3, 0x00880088
    mov r12, 0xCCCCCCCC

    pop {r4, pc}

    @ If you reach here, then you have tried to call `init` more than
    @ once (or otherwise broken some library code)
    already_called_init:
    nop
    b already_called_init
.size init, . - init


.data
init_called:
.word 0
