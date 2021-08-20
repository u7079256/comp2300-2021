.syntax unified
.global main

.type main, %function
main:
  @ b exercise_3

  @ Your code goes here
  initialize:
    @ pokemon
    movs r0, #100
    movs r1, #10
    @ enemy
    movs r2, #100
    movs r3, #10

  @ For each turn: pokemon plays `frenzy` then enemy plays `fireball`,
  @ then pokemon plays `eye of Zardok` then enemy plays `magic poison`.
  @ After one turn, if pokemon/enemy has less than 30 HP, it/they will
  @ recover 20 HP and add 10 strength.
  fight:
    pokemon_attack_1:
      adds r3, #10
      subs r2, #30
      ble pokemon_wins
    enemy_attack_1:
      subs r0, #20
      ble enemy_wins
    pokemon_attack_2: 
      mul r4, r2, r3
      movs r5, #100
      udiv r3, r4, r5
      movs r5, #16
      udiv r4, r3, r5
      mul r5, r4, r4
      mul r4, r5
      subs r2, r4
      ble pokemon_wins
    enemy_attack_2:
      movs r5, #2
      mul r4, r1, r5
      subs r0, r4
      ble enemy_wins
    recovery:
      cmp r0, #30
      ble recover_pokemon
      cmp r2, #30
      ble recover_enemy
      b remaining
      recover_pokemon:
        adds r0, #20
        adds r1, #10
        cmp r2, #30
        ble recover_enemy
        b remaining
      recover_enemy:
        adds r2, #20
        adds r3, #10
      remaining:
    b fight

  pokemon_wins:
    nop
    b pokemon_wins

  enemy_wins:
    nop
    b enemy_wins

  healing_potion:
    adds r0, #50
    b healing_potion
@ a simple infinite loop
end_loop:
  nop
  b end_loop
.size main, .-main

@ a place for your to complete exercise 3. uncomment line 6 when you're ready to start working on it!
exercise_3:
  @ set the negative flag
  @... your instruction(s) go here ...
  movs r1, 0xF0000000
  @ set the zero flag
  @... your instruction(s) go here ...
  movs r1, #0
  @ set the carry flag
  @... your instruction(s) go here ...
  movs r1, 2
  subs r1, 1
  @ set the overflow flag
  @... your instruction(s) go here ...
  movs r1, 0x7fffffff
  adds r1, 1
  nop

  b exercise_3 @ loop back to the beginning of this section--we don't want to fall off the end of the world!