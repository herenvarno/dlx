#addi r1, r0, 10
#sw	1(r0), r1
#addi r2, r0, 11
#add r3, r1, r2
#lw  r4, 1(r0)
#add r5, r3, r4
#subi r5, r4, 5
addi r1, r1, 1
LAB:
addi r2, r1, 1
andi r3, r2, 1
beqz r3, LAB
jal 0

