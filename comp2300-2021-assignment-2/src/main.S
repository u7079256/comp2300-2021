.syntax unified
.global main

.set SAMPLING_FREQ, 48000  @ Sampling frequency is 48kHZ
.set MILISECOND, 1000  @ 1 second = 1000 miliseconds
.set HI_AMP, 0x7fff  @ the highest point of the amplitude
.set LO_AMP, 0x8000  @ the lowest point of the amplitude
.set FREQ_MUL, 100  @ multiply the frequency by 100 for taking decimals into account

.type main, %function
main:
  @ initialize the audio jack
  bl init

  @ intialize registers with data
  while_initialize_2:
    mov r0, HI_AMP  @ r0 -> node displacement
    ldr r4, =pitch_table  @ r4 -> address of the pitch table
    ldr r5, [r4], #4  @ r5 -> the number of pitches in the pitch table
    mov r6, 0  @ r6 -> loop counter, initialized with 0
  
  @ check whether all pitches in the pitch table has been played
  while_condition_2:
    cmp r6, r5
    beq while_initialize_2

  while_body_2:
    @ load the frequency and duration from pitch table, and call function to play the sound
    lsl r7, r6, 3
    ldr r1, [r4, r7]
    add r7, 4
    ldr r2, [r4, r7]
    bl play_sound
    
    @ increment the loop counter of pitch table
    add r6, 1
    b while_condition_2

.size main, .-main

@ play_sound function can play sound at the specified frequency for a period of time
@ Parameters: 
@ r0 -> the current node position
@ r1 -> the frequency of the sound x 100
@ r2 -> the duration of the sound
.type play_sound, %function
play_sound:
  @ save the registers according to the calling conventions
  push {r4, r5, lr}

  @ r3 -> number of samples needed in half of a cycle
  @ r4 -> number of samples in the duration (loop counter)
  mov r3, SAMPLING_FREQ
  mov r5, MILISECOND
  mul r4, r3, r2
  udiv r4, r5
  mov r5, FREQ_MUL
  mul r3, r5
  udiv r3, r1
  lsr r3, 1

  @ r5 -> loop counter for switching position of the node (init with r3)
  mov r5, r3

  @ while_condition_1 checks whether sound is played for the required time
  while_condition_1:
    cmp r4, 0
    beq return_statement

  @ in the duration, play sound
  while_body_1:

    @ check whether we need to switch the position of the node
    if_1:
      cmp r5, 0
      beq then_1
      b remaining_1
    
    @ we need to switch the position of the node
    then_1:

      @ check the current value of the node
      if_2:
        mov r1, HI_AMP
        cmp r0, r1
        beq then_2

      @ the current position is low, change to high
      else_2:
        mov r0, HI_AMP
        b remaining_2
      
      @ the current position is high, change to low
      then_2:
        mov r0, LO_AMP

      @ reload the loop counter for switching the node displacement
      remaining_2:
        mov r5, r3
    
    @ play the sound
    remaining_1:
      push {r0, r1, r2, r3}
      bl BSP_AUDIO_OUT_Play_Sample
      pop {r0, r1, r2, r3}

    @ decrement the loop counter (duration)
    sub r4, 1
    @ decrement the loop counter (node displacement)
    sub r5, 1
    b while_condition_1

  return_statement:
    @ pop the saved registers
    pop {r4, r5, lr}
    bx lr
.size play_sound, .-play_sound

.data
pitch_table:
  @ length of total pitch_table
  .word 25
  @ pitches
  .word 29366, 150
  .word 34923, 150
  .word 58733, 600
  .word 29366, 150
  .word 34923, 150
  .word 58733, 600
  .word 65925, 450
  .word 69846, 150
  .word 65925, 150
  .word 69846, 150
  .word 65925, 150
  .word 52335, 150
  .word 44000, 450
  .word 0, 150
  .word 44000, 300
  .word 29366, 300
  .word 34923, 150
  .word 39200, 150
  .word 44000, 750
  .word 0, 150
  .word 44000, 300
  .word 29366, 300
  .word 34923, 150
  .word 39200, 150
  .word 32963, 900