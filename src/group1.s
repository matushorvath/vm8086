.EXPORT execute_group1

# From decode.s
.IMPORT decode_mod_rm

# From error.s
.IMPORT report_error

# From inc_dec.s
.IMPORT execute_inc_b
.IMPORT execute_dec_b

# From memory.s
.IMPORT read_cs_ip_b

# From split233.s
.IMPORT split233

# From state.s
.IMPORT inc_ip

# Group 1 instructions, first byte is MOD xxx RM, where xxx is:
# 000 INC REG8/MEM8
# 001 DEC REG8/MEM8

##########
execute_group1:
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
    # TODO jump table
    eq  [rb + op], 0b000, [rb + tmp]
    jnz [rb + tmp], execute_group1_inc

    eq  [rb + op], 0b001, [rb + tmp]
    jnz [rb + tmp], execute_group1_dec

    add execute_group1_invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_group1_inc:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_inc_b

    jz  0, execute_group1_end

execute_group1_dec:
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call execute_dec_b

execute_group1_end:
    arb 6
    ret 0

execute_group1_invalid_op_message:
    db  "invalid group 1 operation", 0
.ENDFRAME

.EOF
