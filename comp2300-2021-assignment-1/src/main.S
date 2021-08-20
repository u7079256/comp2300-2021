.syntax unified
.global main

.set SAMPLING_FREQ, 48000   @ sampling frequency
.set PLAYED_FREQ, 440    @ played frequency
.set ON_DUTY_PORTION, 50  @ proportion of on_duty samples (in %)
.set FREQ_FIX_CYCLE, 11  @ @ fix the frequency every 11 normal cycles
.set HIGH_AMP, 0x7fff  @ high amplitude
.set LOW_AMP, 0x8000  @ low amplitude

.type main, %function
main:
  bl init

  mov r0, SAMPLING_FREQ
  mov r1, PLAYED_FREQ
  udiv r3, r0, r1   @ r3 -> sample numbers per cycle
  @ calculate on_duty samples
  mov r2, 100
  mov r1, ON_DUTY_PORTION
  mul r6, r3, r1
  udiv r6, r6, r2  @  r6 -> on duty samples
  sub r7, r3, r6  @ r7 -> off duty samples
  mov r4, FREQ_FIX_CYCLE  @ fix the frequency every 11 normal cycles
  mov r5, r6  @ count samples being taken (initially the number of on duty samples)
  
  
  @ the normal on duty samples
  normal_on_duty_loop:
    @ play sound
    mov r0, HIGH_AMP
    bl BSP_AUDIO_OUT_Play_Sample
    @ decrement the sample numbers needed
    subs r5, 1
    @ check whether have collected 22 samples
    beq normal_on_jump
    @ stay in the loop
    b normal_on_duty_loop
    normal_on_jump:
      @ load the normal off duty samples needed and branch into another loop
      mov r5, r7  @ load the off duty samples
      b normal_off_duty_loop

  @ the normal off duty samples
  normal_off_duty_loop:
    @ play sound
    mov r0, LOW_AMP
    bl BSP_AUDIO_OUT_Play_Sample
    @ decrement the sample numbers needed
    subs r5, 1
    @ check whether have collected 87 samples
    beq normal_off_jump
    @ stay in the loop
    b normal_off_duty_loop
    normal_off_jump:
      @ decrement number of cycles
      subs r4, 1
      mov r5, r6  @ load the on duty samples
      @ check whether we need to average the frequency
      beq fix_freq_on_duty_loop
      @ go back to the normal on duty loop
      b normal_on_duty_loop

  @ the fixing frequency on duty samples
  fix_freq_on_duty_loop:
    add r5, 1  @ add 1 to fix the frequency
    fix_freq_on_duty_loop_body:
      @ play sound
      mov r0, HIGH_AMP
      bl BSP_AUDIO_OUT_Play_Sample
      @ decrenemnt the sample numbers needed
      subs r5, 1
      @ check whether have collected 22 samples
      beq fix_on_jump
      @ stay in the loop
      b fix_freq_on_duty_loop_body
      @ prepare to branching into fix frequency off duty loop
    fix_on_jump:
      @ load the different number of samples
      mov r5, r7  @ load the off duty samples
      b fix_freq_off_duty_loop

  @ the fixing frequency off duty samples
  fix_freq_off_duty_loop:
    @ play sound
    mov r0, LOW_AMP
    bl BSP_AUDIO_OUT_Play_Sample
    @ decrement the sample numbers needed
    subs r5, 1
    @ check whether have collected 88 samples
    beq fix_off_jump
    @ stay in the loop
    b fix_freq_off_duty_loop
    @ prepare to branching back to the normal on duty loop
    fix_off_jump:
      @ reload the frequency fix counter
      mov r4, FREQ_FIX_CYCLE
      mov r5, r6  @ load the on duty samples
      b normal_on_duty_loop

  b main
.size main, .-main