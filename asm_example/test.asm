# software div
addi r1, r0, 88
addi r2, r0, 9
xor r3, r3, r3
divide:
	slt r5, r1, r2
	bnez r5, finish
	sub r1, r1, r2
	addi r3, r3, 1
	j divide
finish:
add r4, r0, r1
nop

# hardware div with RAL hazard
addi r5, r0, 4
addi r7, r0, 88
sw 0(r0), r7
addi r1, r0, 9
xor r3, r3, r3
lw r6, 0(r0)
div r3, r6, r1
div r4, r3, r5
nop
nop

addui r1, r0, 65535
lhi r1, 65535
addui r2, r0, 1
div r3, r1, r2

NOOP:
j NOOP
