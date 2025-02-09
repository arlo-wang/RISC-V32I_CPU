.text
.globl main
main:
    # Initialize registers with test values
    li t0, 5          # t0 = 5
    li t1, 10         # t1 = 10
    li t2, -5         # t2 = -5
    li t3, -10        # t3 = -10

    # Test BLT (branch if t0 < t1)
    blt t0, t1, branch_less    # Branch if t0 < t1 (5 < 10)

no_branch:
    # Code if BLT branch not taken
    li t4, 0xDEAD    # t4 = 0xDEAD (not taken)
    jal check_bge      # Skip the BLT branch taken code

branch_less:
    # Code if BLT branch taken
    li t4, 0xBEEF    # t4 = 0xBEEF (branch taken)

check_bge:
    # Test BGE (branch if t2 >= t3)
    bge t2, t3, branch_ge      # Branch if t2 >= t3 (-5 >= -10)

no_branch_ge:
    # Code if BGE branch not taken
    li t5, 0xCAFE    # t5 = 0xCAFE (not taken)
    jal end            # Skip the BGE branch taken code

branch_ge:
    # Code if BGE branch taken
    li t5, 0xF00D    # t5 = 0xF00D (branch taken)

end:
    # Validate results by summing into a0
    li a0, 0         # Initialize a0 = 0
    add a0, a0, t4   # a0 += t4 (result of BLT) = 0xBEEF
    add a0, a0, t5   # a0 += t5 (result of BGE) = 0xF00D

    # Infinite loop to finish program
finish:     # expected result is 0x1AEFC = 0xBEEF + 0xF00D
    bne     a0, zero, finish     # loop forever
