@ Implements a simple stateful sawtooth wave library
.syntax unified

@ --------------------- Module Interface --------------------
@ NOTES:
@
@   the `wave_play_next_sample` function plays the next sample
@   based on the current waveform state (pitch & amplitude)
@
@   the `wave_change` function changes the waveform state

.global wave_play_next_sample
.global wave_change

.global FREQ_SCALING_FACTOR

@ --------------------- Implementation --------------------
.set BSP_SAMPLE_FREQ,     48000
.set FREQ_SCALING_FACTOR, 100

.include "src/libcomp2300/macros.S"

.type wave_play_next_sample, %function
@ Play the next sample of the currently set wave
@ --parameters--
@ none
wave_play_next_sample:
  push {lr}

  ldr r0, =waveinfo
  bl get_next_sample
  bl BSP_AUDIO_OUT_Play_Sample

  pop {lr}
  bx lr
.size wave_play_next_sample, .-wave_play_next_sample

.type wave_change, %function
@ change the current waveform state
@ also resets the sample index to 0
@
@ the frequency is expected to be scaled by the FREQ_SCALING_FACTOR (default 100)
@ e.g. if you want to play a wave of 423.56Hz, pass 42356 as the first argument
@
@ This is just a simple fixed-point arithematic strategy to
@ avoid requiring floating point
@
@ --parameters--
@ r0: frequency * 100 (lower 16-bit)
@ r1: amplitude (lower 16-bit as signed)
wave_change:
  ldr r2, =waveinfo
  str r0,  [r2, 4]
  strh r1, [r2, 8]

  @ reset sample index to 0
  mov r0, 0
  str r0, [r2]
  bx lr
.size wave_change, .-wave_change

.data
@ state information for the wave
waveinfo:         @ NOTE: this symbol is NOT globally visible.
  .word 0         @ current sample index, initialised to 0
  .word 44000     @ scaled frequency (440 * 100)
  .hword 0x7fff   @ amplitude

@ ---- Implementation Details ----
.text

.type sawtooth, %function
@ --parameters--
@ r0: sample index
@ r1: period length
@ r2: amplitude
@ --returns--
@ r0: sawtooth sample value at sample index
@     that's between [-amp/2, amp/2] (lower 16-bits)
sawtooth:
  @ idx = idx % period
  mod   r3, r0, r1
  mov   r0, r3

  lsr   r3, r2, 1
  rsb   r3, 0       @ r3 <- -amp/2
  udiv  r1, r2, r1  @ r1 <- increment
  mul   r0, r1
  add   r0, r3      @ r0 <- -amp/2 + increment * idx
  ldr   r1, =0xffff
  add   r0, r1      @ mask off the higher 16-bits
  bx lr
.size sawtooth, .-sawtooth

@ wave generation function
.type get_next_sample, %function
@ --parameters--
@ r0: address of waveinfo
@ record waveinfo:
@   .word idx_sample;
@   .word freq_scaled;
@   .hword amplitude;
@ --returns--
@ r0: next sample
@ information in record will also be updated
get_next_sample:
  push  {r4-r5, lr}
  mov   r4, r0      @ r4 <- pointer to record

  ldr   r1, =BSP_SAMPLE_FREQ
  ldr   r2, =FREQ_SCALING_FACTOR
  mul   r1, r1, r2

  ldr   r2, [r0, 4] @ scaled freq
  udiv  r5, r1, r2  @ r5 <- period length (rounded down)

  ldr    r0, [r4, 0]
  mov    r1, r5
  ldrh   r2, [r4, 8]
  bl     sawtooth
  @ r0 contains the sample

  ldr    r1, [r4, 0]  @ current sample index
  add    r1, 1
  cmp    r1, r5
  ble    wave_next_not_over_period
  @ otherwise reset sample index to 1
  mov    r1, 1
wave_next_not_over_period:
  str    r1, [r4, 0]
  pop    {r4-r5, lr}
  bx     lr
.size get_next_sample, .-get_next_sample
