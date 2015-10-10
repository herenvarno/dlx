# hardware div with RAL hazzard
addi r5, r0, #4
addi r7, r0, #-88
sw 0(r0), r7
addi r1, r0, #9
xor r3, r3, r3
lw r6, 0(r0)
divu r3, r6, r1
div r3, r6, r1
divu r4, r3, r5
nop
nop

lhi r1, #65535
addui r1, r1, #65535
addui r2, r0, #1
divu r3, r1, r2

# hardware square root with RAL hazzard
addi r10, r0, #81
addi r11, r0, #148996
sw 4(r0), r10
xor r3, r3, r3
lw r12, 4(r0)
sqrt r3, r12, r0
sqrt r3, r11, r0
divu r4, r11, r10

NOOP:
j NOOP
