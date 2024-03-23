.EXPORT execute_group2

# From decode.s
.IMPORT decode_mod_rm

# From error.s
.IMPORT report_error

# From inc_dec.s
.IMPORT execute_inc_w
.IMPORT execute_dec_w

# From memory.s
.IMPORT read_cs_ip_b

# From split233.s
.IMPORT split233

# From state.s
.IMPORT inc_ip

# Group 2 instructions, first byte is MOD xxx RM, where xxx is:
# 000 INC MEM16
# 001 DEC MEM16
# 010 CALL REG16/MEM16 (within segment)
# 011 CALL MEM16 (intersegment)
# 100 JMP REG16/MEM16 (within segment)
# 101 JMP MEM16 (intersegment)
# 110 PUSH MEM16
# 111 (not used)

##########
execute_group2:
.FRAME tmp, mod, op, rm, loc_type, loc_addr
    arb -6

    # Read the MOD xxx R/M byte and split it
    call read_cs_ip_b
    add [rb - 2], 0, [rb + tmp]
    call inc_ip

    mul [rb + tmp], 3, [rb + tmp]
    add split233 + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + rm]
    add split233 + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + op]
    add split233 + 2, [rb + tmp], [ip + 1]
    add [0], 0, [rb + mod]

    # Decode MOD and RM
    add [rb + mod], 0, [rb - 1]
    add [rb + rm], 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call decode_mod_rm
    add [rb - 5], 0, [rb + loc_type]
    add [rb - 6], 0, [rb + loc_addr]

    # Execute the operation
    add execute_group2_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_group2_table:
    # Map each OP value to the label that handles it
    db  execute_group2_inc
    db  execute_group2_dec
    db  execute_group2_call_near
    db  execute_group2_call_far
    db  execute_group2_jmp_near
    db  execute_group2_jmp_far
    db  execute_group2_push_w
    db  execute_group2_invalid_op

execute_group2_invalid_op:
    add execute_group2_invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_inc:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_inc_w

    jz  0, execute_group2_end

execute_group2_dec:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_dec_w

    jz  0, execute_group2_end

execute_group2_call_near:
    # TODO implement
    add execute_group2_not_implemented, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_call_far:
    # TODO implement
    add execute_group2_not_implemented, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_jmp_near:
    # TODO implement
    add execute_group2_not_implemented, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_jmp_far:
    # TODO implement
    add execute_group2_not_implemented, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_push_w:
    # TODO implement
    add execute_group2_not_implemented, 0, [rb - 1]
    arb -1
    call report_error

execute_group2_end:
    arb 6
    ret 0

execute_group2_not_implemented:                             # TODO remove
    db  "group 2 operation not implemented", 0
execute_group2_invalid_op_message:
    db  "invalid group 2 operation", 0
.ENDFRAME

.EOF
