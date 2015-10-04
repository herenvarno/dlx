# BRANCH PREDITION TEST
addi r3, r3, #10
sw 4(r0), r3
BEGIN:
lw r2, 4(r0)
subi r2, r2, #1
sw 4(r0), r2
nop
lw r1, 4(r0)
bnez r1, BEGIN

addi r3, r3, #10
sw 4(r0), r3
BEGIN1:
lw r2, 4(r0)
subi r2, r2, #1
sw 4(r0), r2
nop
lw r1, 4(r0)
bnez r1, BEGIN1

addi r3, r3, #10
sw 4(r0), r3
BEGIN2:
lw r2, 4(r0)
subi r2, r2, #1
sw 4(r0), r2
nop
lw r1, 4(r0)
bnez r1, BEGIN2

NOOP:
j NOOP

