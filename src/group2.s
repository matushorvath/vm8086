.EXPORT execute_group2_b
.EXPORT execute_group2_w

# From error.s
.IMPORT report_error

# From inc_dec.s
.IMPORT execute_inc_b
.IMPORT execute_inc_w
.IMPORT execute_dec_b
.IMPORT execute_dec_w

# From stack.s
.IMPORT execute_push_w

# TODO implement rest of group 2

# Group 2 8-bit instructions, first byte is MOD xxx R/M, where xxx is:
# 000 INC REG8/MEM8
# 001 DEC REG8/MEM8

##########
execute_group2_b:
.FRAME op, loc_type, loc_addr;
    # Prepare the arguments on stack
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]

    # Execute the operation
    add execute_group2_b_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_group2_b_table:
    # Map each OP value to the label that handles it
    db  execute_group2_b_inc
    db  execute_group2_b_dec
    db  execute_group2_b_invalid_op
    db  execute_group2_b_invalid_op
    db  execute_group2_b_invalid_op
    db  execute_group2_b_invalid_op
    db  execute_group2_b_invalid_op
    db  execute_group2_b_invalid_op

execute_group2_b_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_b_inc:
    arb -2
    call execute_inc_b
    jz  0, execute_group2_b_end

execute_group2_b_dec:
    arb -2
    call execute_dec_b

execute_group2_b_end:
    ret 3
.ENDFRAME

# Group 2 instructions, first byte is MOD xxx R/M, where xxx is:
# 000 INC MEM16
# 001 DEC MEM16
# 010 CALL REG16/MEM16 (within segment)
# 011 CALL MEM16 (intersegment)
# 100 JMP REG16/MEM16 (within segment)
# 101 JMP MEM16 (intersegment)
# 110 PUSH MEM16
# 111 (not used)

##########
execute_group2_w:
.FRAME op, loc_type, loc_addr;
    # Prepare the arguments on stack
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]

    # Execute the operation
    add execute_group2_w_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_group2_w_table:
    # Map each OP value to the label that handles it
    db  execute_group2_w_inc
    db  execute_group2_w_dec
    db  execute_group2_w_call_near
    db  execute_group2_w_call_far
    db  execute_group2_w_jmp_near
    db  execute_group2_w_jmp_far
    db  execute_group2_w_push_w
    db  execute_group2_w_invalid_op

execute_group2_w_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_w_inc:
    arb -2
    call execute_inc_w
    jz  0, execute_group2_w_end

execute_group2_w_dec:
    arb -2
    call execute_dec_w
    jz  0, execute_group2_w_end

execute_group2_w_call_near:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_w_call_far:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_w_jmp_near:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_w_jmp_far:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_w_push_w:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_push_w

execute_group2_w_end:
    ret 3
.ENDFRAME

##########
not_implemented_message:                                    # TODO remove
    db  "group 2 operation not implemented", 0

invalid_op_message:
    db  "invalid group 2 operation", 0

.EOF
