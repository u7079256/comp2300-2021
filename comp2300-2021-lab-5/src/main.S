.syntax unified
.global main

.type main, %function
main:
  @ set up the arguments
  mov r0, 66 @ ass1 mark
  mov r1, 73 @ ass2 mark
  mov r2, 71 @ final exam mark
  
  @ call the function
  bl calculate_total_mark

  mov r0, 15 @ F
  bl grade_from_mark_recursive
  mov r0, 99 @ A
  bl grade_from_mark_recursive
  mov r0, 70 @ C
  bl grade_from_mark_recursive
  mov r0, 3 @ F
  bl grade_from_mark_recursive

  mov r0, 88 @ ass1 mark
  mov r1, 91 @ ass2 mark
  mov r2, 91 @ final exam mark
  bl calculate_grade

  mov r0, 88 @ ass1 mark
  mov r1, 91 @ ass2 mark
  mov r2, 91 @ final exam mark
  bl calculate_grade_sa

  bl calculate_lab_grades

  @ go to the end loop
  b end

end:
  b end
.size main, .-main


.type calculate_total_mark, %function
calculate_total_mark:
  @ do stuff with the arguments
  @ ...
  stmdb sp!, {r4, r5, r6}
  @ move constants to registers
  mov r4, 25
  mov r5, 50
  mov r6, 100
  @ get marks of each part * 100
  mul r0, r4
  mul r1, r4
  mul r2, r5
  @ sum all the marks * 100
  add r0, r1
  add r0, r2
  @ get the mark
  udiv r0, r0, r6

  @ go back to where the function was called from
  ldmia sp!, {r4, r5, r6}
  bx lr
.size calculate_total_mark, .-calculate_total_mark

.type grade_from_mark, %function
grade_from_mark:
  @ if is full mark, branch into edge case 1
  cmp r0, 100
  beq edge_case_1
  @ get the mark divided by 10
  mov r1, 10
  udiv r0, r0, r1
  @ if the student fail, branch into edge case 2
  cmp r0, 5
  blt edge_case_2
  @ normal cases and return
  mov r1, #19
  sub r0, r1, r0
  b return
  @ full marks
  edge_case_1:
    mov r0, 0xA
    b return
  @ fail
  edge_case_2:
    mov r0, 0xF
  @ return part
  return:
  @ store grade in data
  ldr r1, =data
  add r2, r0, 55
  strb r2, [r1], 1
  bx lr
.size grade_from_mark, .-grade_from_mark

.type calculate_grade, %function
calculate_grade:
  str lr, [sp, #-4]!

  bl calculate_total_mark
  bl grade_from_mark

  ldr lr, [sp], #4
  bx lr
.size calculate_grade, .-calculate_grade

.type grade_from_mark_recursive, %function
grade_from_mark_recursive:
  str lr, [sp, #-4]!
  @ edge case (full mark)
  cmp r0, 100
  beq edge_cases
  @ normal case
  cmp r0, 50
  blt base_case
  step_case:
    push {r0}  @ keep track of the mark
    sub r0, 10
    bl grade_from_mark_recursive  @ recursive call
    pop {r1}  @ keep track of the mark
    sub r0, 1
    b return_statement
  base_case:
    mov r0, 0xf
    b return_statement
  edge_cases:
    mov r0, 0xa
  @ return the result
  return_statement:
  ldr lr, [sp], #4
  bx lr
.size grade_from_mark_recursive, .-grade_from_mark_recursive

.type calculate_grade_sa, %function
calculate_grade_sa:
  @ TODO: prep for call
  str lr, [sp, #-4]!
  bl calculate_total_mark

  @ store teacher's mark on top of stack
  str r0, [sp, -4]!
  @ delete the teacher's mark from r0
  mov r0, 0

  @ TODO: prep for call
  bl self_assessment  @ cheat in here
  ldr r1, [sp], 4

  @ TODO: calculate final grade from: 
  @ - student grade (r0) 
  @ - teacher grade (r1)
  @ ...
  sub r2, r0, r1
  cmp r2, 10
  ble case_2
  @ difference is larger than 10
  case_1:
    sub r0, r1, r2
  @ difference is smaller or equal to 10
  case_2:
    add r0, r1
    lsr r0, r0, #1
  @ return from the function
  ldr lr, [sp], #4
  bx lr
.size calculate_grade_sa, .-calculate_grade_sa

.type self_assessment, %function
self_assessment:
  @ TODO: return self assessed grade in r0
  @ cheat by reading value from the stack
  ldr r0, [sp]
  add r0, 10
  cmp r0, 100
  ble return_cheat
  mov r0, 100
  return_cheat:
  bx lr
.size self_assessment, .-self_assessment

.type calculate_lab_grades, %function
calculate_lab_grades:
  stmdb sp!, {lr, r4, r5, r6, r7}

  ldr r3, =results  @ the memory address of the result
  ldr r4, [r3]  @ the length of the array
  add r3, 4  @ add r3 to the start position of data
  mov r5, 0  @ the counter
  mov r6, 16  @ constant 16, number of bytes used for each student

  calculation_loop:
    mul r7, r5, r6
    add r7, r3
    ldr r2, [r7, #8]
    ldr r1, [r7, #4]
    ldr r0, [r7]
    @ branch to function to calculate score
    bl calculate_total_mark
    @ store the score in the fourth position for the student
    str r0, [r7, 12] 
    @ increment the counter
    add r5, 1
    @ compare the counter with the length of the array
    cmp r5, r6  
    @ if the number of the counter is not equal to the length of array, back to the loop
    bne calculation_loop
  @ return to the program
  ldmia sp!, {lr, r4, r5, r6, r7}
  bx lr
.size calculate_lab_grades, .-calculate_lab_grades

.data
data:
  .word 0x0

results:
  @ Length of array: 6
  .word 6
  @S1
  .word 50, 50, 40, 0
  @S2
  .word 77, 80, 63, 0
  @S3
  .word 40, 50, 60, 0
  @S4
  .word 80, 82, 89, 0
  @S5
  .word 80, 85, 77, 0
  @S6
  .word 91, 90, 95, 0