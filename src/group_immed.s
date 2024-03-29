.EXPORT execute_immed_b
.EXPORT execute_immed_w

# From bitwise.s
.IMPORT execute_and_b
.IMPORT execute_and_w
.IMPORT execute_or_b
.IMPORT execute_or_w
.IMPORT execute_xor_b
.IMPORT execute_xor_w

# From error.s
.IMPORT report_error                    # TODO remove

# Group "immediate" instructions, first byte is MOD xxx R/M, where xxx is:
# 000 ADD, 001 OR, 010 ADC, 011 SBB, 100 AND, 101 SUB, 110 XOR, 111 CMP
#
# Opcodes:
# 0x80 <op> REG8/MEM8, IMMED8
# 0x81 <op> REG16/MEM16, IMMED16
# 0x82 <op> REG8/MEM8, IMMED8
# 0x83 <op> REG16/MEM16, IMMED8 (sign extend)

# TODO HW is opcode 0x80 the same as 0x82?

# Note: Opcodes 0x82 and 0x83 on Intel 8086 are not documented to include OR, AND and XOR.
# However, NASM will generate '83 f0 ff' for 'xor ax, word 0xffff' even with 'cpu 8086'.
# So, to make life easier, we support those operations even for opcodes 0x82 and 0x83.
# https://bugzilla.nasm.us/show_bug.cgi?id=3392642

##########
execute_immed_b:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Prepare the arguments on stack
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]

    # Execute the operation
    add execute_immed_b_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_immed_b_table:
    # Map each OP value to the label that handles it
    db  execute_immed_b_add
    db  execute_immed_b_or
    db  execute_immed_b_adc
    db  execute_immed_b_sbb
    db  execute_immed_b_and
    db  execute_immed_b_sub
    db  execute_immed_b_xor
    db  execute_immed_b_cmp

execute_immed_b_add:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_b_or:
    arb -4
    call execute_or_b
    jz  0, execute_immed_w_end

execute_immed_b_adc:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_b_sbb:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_b_and:
    arb -4
    call execute_and_b
    jz  0, execute_immed_w_end

execute_immed_b_sub:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_b_xor:
    arb -4
    call execute_xor_b
    jz  0, execute_immed_w_end

execute_immed_b_cmp:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_b_end:
    ret 5
.ENDFRAME

##########
execute_immed_w:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Prepare the arguments on stack
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]

    # Execute the operation
    add execute_immed_w_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_immed_w_table:
    # Map each OP value to the label that handles it
    db  execute_immed_w_add
    db  execute_immed_w_or
    db  execute_immed_w_adc
    db  execute_immed_w_sbb
    db  execute_immed_w_and
    db  execute_immed_w_sub
    db  execute_immed_w_xor
    db  execute_immed_w_cmp

execute_immed_w_add:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_w_or:
    arb -4
    call execute_or_w
    jz  0, execute_immed_w_end

execute_immed_w_adc:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_w_sbb:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_w_and:
    arb -4
    call execute_and_w
    jz  0, execute_immed_w_end

execute_immed_w_sub:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_w_xor:
    arb -4
    call execute_xor_w
    jz  0, execute_immed_w_end

execute_immed_w_cmp:
    # TODO implement
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

execute_immed_w_end:
    ret 5
.ENDFRAME

##########
not_implemented_message:                                    # TODO remove
    db  "group imediate operation not implemented", 0

.EOF
