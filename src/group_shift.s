.EXPORT execute_shift_b
.EXPORT execute_shift_w

# From error.s
.IMPORT report_error

# From shift.s
.IMPORT execute_rol_b
.IMPORT execute_rol_w
.IMPORT execute_ror_b
.IMPORT execute_ror_w
.IMPORT execute_rcl_b
.IMPORT execute_rcl_w
.IMPORT execute_rcr_b
.IMPORT execute_rcr_w
.IMPORT execute_shl_b
.IMPORT execute_shl_w
.IMPORT execute_shr_b
.IMPORT execute_shr_w
.IMPORT execute_sar_b
.IMPORT execute_sar_w

# Group "shift" instructions, first byte is MOD xxx R/M, where xxx is:
# 000 ROL, 001 ROR, 010 RCL, 011 RCR, 100 SAL/SHL, 101 SHR, 111 SAR
#
# Opcodes:
# 0xd0 <op> REG8/MEM8, 1
# 0xd1 <op> REG16/MEM16, 1
# 0xd2 <op> REG8/MEM8, CL
# 0xd3 <op> REG16/MEM16, CL

##########
execute_shift_b:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Prepare the arguments on stack
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]

    # Execute the operation
    add execute_shift_b_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_shift_b_table:
    # Map each OP value to the label that handles it
    db  execute_shift_b_rol
    db  execute_shift_b_ror
    db  execute_shift_b_rcl
    db  execute_shift_b_rcr
    db  execute_shift_b_shl
    db  execute_shift_b_shr
    db  execute_shift_b_invalid_op
    db  execute_shift_b_sar

execute_shift_b_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_shift_b_rol:
    arb -4
    call execute_rol_b
    jz  0, execute_shift_b_end

execute_shift_b_ror:
    arb -4
    call execute_ror_b
    jz  0, execute_shift_b_end

execute_shift_b_rcl:
    arb -4
    call execute_rcl_b
    jz  0, execute_shift_b_end

execute_shift_b_rcr:
    arb -4
    call execute_rcr_b
    jz  0, execute_shift_b_end

execute_shift_b_shl:
    arb -4
    call execute_shl_b
    jz  0, execute_shift_b_end

execute_shift_b_shr:
    arb -4
    call execute_shr_b
    jz  0, execute_shift_b_end

execute_shift_b_sar:
    arb -4
    call execute_sar_b

execute_shift_b_end:
    ret 5
.ENDFRAME

##########
execute_shift_w:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Prepare the arguments on stack
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]

    # Execute the operation
    add execute_shift_w_table, [rb + op], [ip + 2]
    jz  0, [0]

execute_shift_w_table:
    # Map each OP value to the label that handles it
    db  execute_shift_w_rol
    db  execute_shift_w_ror
    db  execute_shift_w_rcl
    db  execute_shift_w_rcr
    db  execute_shift_w_shl
    db  execute_shift_w_shr
    db  execute_shift_w_invalid_op
    db  execute_shift_w_sar

execute_shift_w_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_shift_w_rol:
    arb -4
    call execute_rol_w
    jz  0, execute_shift_w_end

execute_shift_w_ror:
    arb -4
    call execute_ror_w
    jz  0, execute_shift_w_end

execute_shift_w_rcl:
    arb -4
    call execute_rcl_w
    jz  0, execute_shift_w_end

execute_shift_w_rcr:
    arb -4
    call execute_rcr_w
    jz  0, execute_shift_w_end

execute_shift_w_shl:
    arb -4
    call execute_shl_w
    jz  0, execute_shift_w_end

execute_shift_w_shr:
    arb -4
    call execute_shr_w
    jz  0, execute_shift_w_end

execute_shift_w_sar:
    arb -4
    call execute_sar_w

execute_shift_w_end:
    ret 5
.ENDFRAME

invalid_op_message:
    db  "invalid group shift operation", 0

.EOF
