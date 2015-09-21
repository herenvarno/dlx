
addi r1, r0, 6
addi r2, r0, 7
nop
mult r3, r2, r1
addi r3, r3, 2
shift:

srli r3, r3, 1
bnez r3, shift

addui r1, r0, 65535
sw 1(r0), r1
addui r2, r0, 65535
lw r3, 1(r0)
mult r4, r3, r2
multu r4, r3, r2
mult r5, r4, r3
fine:
j fine
