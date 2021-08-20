.syntax unified

// this code is a little wrapper around Ben's audio and clock libraries so that they expose functions similar to the ones we've used over the last couple of years.

.global init
.type init, %function
init:
    push {lr}
    bl clock_init
    bl audio_init
    pop {pc}
.size init, . - init