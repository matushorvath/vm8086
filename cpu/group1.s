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
.IMPORT execute_div_w
.IMPORT execute_idiv_b
.IMPORT execute_idiv_w

# From util/error.s
.IMPORT report_error

# From mul.s
.IMPORT execute_mul_b
.IMPORT execute_mul_w
.IMPORT execute_imul_b
.IMPORT execute_imul_w

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
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
.FRAME op, lseg, loff; lseg_imm, loff_imm
    arb -2

    # Execute the operation
    add .table, [rb + op], [ip + 2]
    jz  0, [0]

.table:
    # Map each OP value to the label that handles it
    db  .test
    db  .invalid_op
    db  .not
    db  .neg
    db  .mul
    db  .imul
    db  .div
    db  .idiv

.invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

.test:
    # TEST has an additional IMMED8 parameter
    mul [reg_cs + 1], 0x100, [rb + lseg_imm]
    add [reg_cs + 0], [rb + lseg_imm], [rb + lseg_imm]
    mul [reg_ip + 1], 0x100, [rb + loff_imm]
    add [reg_ip + 0], [rb + loff_imm], [rb + loff_imm]

    call inc_ip_b

    # Execute the instruction
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + lseg_imm], 0, [rb - 3]
    add [rb + loff_imm], 0, [rb - 4]
    arb -4
    call execute_test_b

    jz  0, .end

.not:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_not_b

    jz  0, .end

.neg:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_neg_b

    jz  0, .end

.mul:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_mul_b

    jz  0, .end

.imul:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_imul_b

    jz  0, .end

.div:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_div_b

    jz  0, .end

.idiv:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_idiv_b

.end:
    arb 2
    ret 3
.ENDFRAME

##########
execute_group1_w:
.FRAME op, lseg, loff; lseg_imm, loff_imm
    arb -2

    # Execute the operation
    add .table, [rb + op], [ip + 2]
    jz  0, [0]

.table:
    # Map each OP value to the label that handles it
    db  .test
    db  .invalid_op
    db  .not
    db  .neg
    db  .mul
    db  .imul
    db  .div
    db  .idiv

.invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

.test:
    # TEST has an additional IMMED16 parameter
    mul [reg_cs + 1], 0x100, [rb + lseg_imm]
    add [reg_cs + 0], [rb + lseg_imm], [rb + lseg_imm]
    mul [reg_ip + 1], 0x100, [rb + loff_imm]
    add [reg_ip + 0], [rb + loff_imm], [rb + loff_imm]

    call inc_ip_w

    # Execute the instruction
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + lseg_imm], 0, [rb - 3]
    add [rb + loff_imm], 0, [rb - 4]
    arb -4
    call execute_test_w

    jz  0, .end

.not:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_not_w

    jz  0, .end

.neg:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_neg_w

    jz  0, .end

.mul:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_mul_w

    jz  0, .end

.imul:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_imul_w

    jz  0, .end

.div:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_div_w

    jz  0, .end

.idiv:
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call execute_idiv_w

.end:
    arb 2
    ret 3
.ENDFRAME

##########
invalid_op_message:
    db  "invalid group 1 operation", 0

.EOF
