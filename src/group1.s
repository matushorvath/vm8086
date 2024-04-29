.EXPORT execute_group1_b
.EXPORT execute_group1_w

# From arithmetic.s
.IMPORT execute_neg_b
.IMPORT execute_neg_w

# From bitwise.s
.IMPORT execute_test_b
.IMPORT execute_test_w
.IMPORT execute_not_b
.IMPORT execute_not_w

# From div.s
.IMPORT execute_div_b
#.IMPORT execute_div_w
#.IMPORT execute_idiv_b
#.IMPORT execute_idiv_w

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT calc_cs_ip_addr

# From mul.s
.IMPORT execute_mul_b
.IMPORT execute_mul_w
.IMPORT execute_imul_b
.IMPORT execute_imul_w

# From state.s
.IMPORT inc_ip_b
.IMPORT inc_ip_w

# Group 1, first byte is MOD xxx R/M, where xxx is:
# 000 TEST REG/MEM, IMMED
# 001 (not used)
# 010 NOT REG/MEM
# 011 NEG REG/MEM
# 100 MUL REG/MEM
# 101 IMUL REG/MEM
# 110 DIV REG/MEM
# 111 IDIV REG/MEM

##########
execute_group1_b:
.FRAME op, loc_type, loc_addr; loc_addr_immed
    arb -1

    # Execute the operation
    add execute_group1_b_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_group1_b_table:
    # Map each OP value to the label that handles it
    db  execute_group1_b_test
    db  execute_group1_b_invalid_op
    db  execute_group1_b_not
    db  execute_group1_b_neg
    db  execute_group1_b_mul
    db  execute_group1_b_imul
    db  execute_group1_b_div
    db  execute_group1_b_idiv

execute_group1_b_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_b_test:
    # TEST has an additional IMMED8 parameter
    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr_immed]
    call inc_ip_b

    # Execute the instruction
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add 1, 0, [rb - 3]
    add [rb + loc_addr_immed], 0, [rb - 4]
    arb -4
    call execute_test_b

    jz  0, execute_group1_b_end

execute_group1_b_not:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_not_b

    jz  0, execute_group1_b_end

execute_group1_b_neg:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_neg_b

    jz  0, execute_group1_b_end

execute_group1_b_mul:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_mul_b

    jz  0, execute_group1_b_end

execute_group1_b_imul:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_imul_b

    jz  0, execute_group1_b_end

execute_group1_b_div:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_div_b

    jz  0, execute_group1_b_end

execute_group1_b_idiv:
    # TODO implement IDIV
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_b_end:
    arb 1
    ret 3
.ENDFRAME

##########
execute_group1_w:
.FRAME op, loc_type, loc_addr; loc_addr_immed
    arb -1

    # Execute the operation
    add execute_group1_w_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_group1_w_table:
    # Map each OP value to the label that handles it
    db  execute_group1_w_test
    db  execute_group1_w_invalid_op
    db  execute_group1_w_not
    db  execute_group1_w_neg
    db  execute_group1_w_mul
    db  execute_group1_w_imul
    db  execute_group1_w_div
    db  execute_group1_w_idiv

execute_group1_w_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_w_test:
    # TEST has an additional IMMED16 parameter
    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr_immed]
    call inc_ip_w

    # Execute the instruction
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add 1, 0, [rb - 3]
    add [rb + loc_addr_immed], 0, [rb - 4]
    arb -4
    call execute_test_w

    jz  0, execute_group1_w_end

execute_group1_w_not:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_not_w

    jz  0, execute_group1_w_end

execute_group1_w_neg:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_neg_w

    jz  0, execute_group1_w_end

execute_group1_w_mul:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_mul_w

    jz  0, execute_group1_w_end

execute_group1_w_imul:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_imul_w

    jz  0, execute_group1_w_end

execute_group1_w_div:
    # TODO implement DIV
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_w_idiv:
    # TODO implement IDIV
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_w_end:
    arb 1
    ret 3
.ENDFRAME

##########
not_implemented_message:                                    # TODO remove
    db  "group 1 operation not implemented", 0

invalid_op_message:
    db  "invalid group 1 operation", 0

.EOF
