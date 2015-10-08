# BRANCH

addi r1, r0, #5
L1:
subi r1, r1, #1
bnez r1, L1

addi r2, r0, #5
L2:
subi r2, r2, #1
beqz r2, L2

# JUMP
L3:
j L4
nop
nop
L4:
jal L5
nop
nop
nop
L5:
nop
# JUMP REGISTER
addi r3, r0, L6
jr r3
nop
nop
nop
L6:
jalr r3
