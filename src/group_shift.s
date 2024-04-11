.EXPORT execute_shift_1_b
.EXPORT execute_shift_1_w
.EXPORT execute_shift_cl_b
.EXPORT execute_shift_cl_w

# From error.s
.IMPORT report_error

# From shift.s
.IMPORT execute_rol_1_b
.IMPORT execute_rol_1_w
.IMPORT execute_rol_cl_b
.IMPORT execute_rol_cl_w

.IMPORT execute_ror_1_b
.IMPORT execute_ror_1_w
.IMPORT execute_ror_cl_b
.IMPORT execute_ror_cl_w

.IMPORT execute_rcl_1_b
.IMPORT execute_rcl_1_w
.IMPORT execute_rcl_cl_b
.IMPORT execute_rcl_cl_w

.IMPORT execute_rcr_1_b
.IMPORT execute_rcr_1_w
.IMPORT execute_rcr_cl_b
.IMPORT execute_rcr_cl_w

.IMPORT execute_shl_1_b
.IMPORT execute_shl_1_w
.IMPORT execute_shl_cl_b
.IMPORT execute_shl_cl_w

.IMPORT execute_shr_1_b
.IMPORT execute_shr_1_w
.IMPORT execute_shr_cl_b
.IMPORT execute_shr_cl_w

.IMPORT execute_sar_1_b
.IMPORT execute_sar_1_w
.IMPORT execute_sar_cl_b
.IMPORT execute_sar_cl_w

# Group "shift" instructions, first byte is MOD xxx R/M, where xxx is:
# 000 ROL, 001 ROR, 010 RCL, 011 RCR, 100 SAL/SHL, 101 SHR, 111 SAR
#
# Opcodes:
# 0xd0 <op> REG8/MEM8, 1
# 0xd1 <op> REG16/MEM16, 1
# 0xd2 <op> REG8/MEM8, CL
# 0xd3 <op> REG16/MEM16, CL

##########
.FRAME op, loc_type, loc_addr; table
    # Function with multiple entry points

execute_shift_1_b:
    arb -1
    add shift_1_b_table, 0, [rb + table]
    jz  0, execute_shift

execute_shift_1_w:
    arb -1
    add shift_1_w_table, 0, [rb + table]
    jz  0, execute_shift

execute_shift_cl_b:
    arb -1
    add shift_cl_b_table, 0, [rb + table]
    jz  0, execute_shift

execute_shift_cl_w:
    arb -1
    add shift_cl_w_table, 0, [rb + table]
    jz  0, execute_shift

execute_shift:
    # Prepare the arguments on stack
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]

    # Execute the operation
    add [rb + table], [rb + op], [ip + 2]
    jz  0, [0]
    # TODO call, not jz

execute_shift_invalid_op:
    add invalid_op_message, 0, [rb - 1]
    arb -1
    call report_error

execute_shift_rol_1_b:
    arb -2
    call execute_rol_1_b
    jz  0, execute_shift_end

execute_shift_ror_1_b:
    arb -2
    call execute_ror_1_b
    jz  0, execute_shift_end

execute_shift_rcl_1_b:
    arb -2
    call execute_rcl_1_b
    jz  0, execute_shift_end

execute_shift_rcr_1_b:
    arb -2
    call execute_rcr_1_b
    jz  0, execute_shift_end

execute_shift_shl_1_b:
    arb -2
    call execute_shl_1_b
    jz  0, execute_shift_end

execute_shift_shr_1_b:
    arb -2
    call execute_shr_1_b
    jz  0, execute_shift_end

execute_shift_sar_1_b:
    arb -2
    call execute_sar_1_b
    jz  0, execute_shift_end

execute_shift_rol_1_w:
    arb -2
    call execute_rol_1_w
    jz  0, execute_shift_end

execute_shift_ror_1_w:
    arb -2
    call execute_ror_1_w
    jz  0, execute_shift_end

execute_shift_rcl_1_w:
    arb -2
    call execute_rcl_1_w
    jz  0, execute_shift_end

execute_shift_rcr_1_w:
    arb -2
    call execute_rcr_1_w
    jz  0, execute_shift_end

execute_shift_shl_1_w:
    arb -2
    call execute_shl_1_w
    jz  0, execute_shift_end

execute_shift_shr_1_w:
    arb -2
    call execute_shr_1_w
    jz  0, execute_shift_end

execute_shift_sar_1_w:
    arb -2
    call execute_sar_1_w
    jz  0, execute_shift_end

execute_shift_rol_cl_b:
    arb -2
    call execute_rol_cl_b
    jz  0, execute_shift_end

execute_shift_ror_cl_b:
    arb -2
    call execute_ror_cl_b
    jz  0, execute_shift_end

execute_shift_rcl_cl_b:
    arb -2
    call execute_rcl_cl_b
    jz  0, execute_shift_end

execute_shift_rcr_cl_b:
    arb -2
    call execute_rcr_cl_b
    jz  0, execute_shift_end

execute_shift_shl_cl_b:
    arb -2
    call execute_shl_cl_b
    jz  0, execute_shift_end

execute_shift_shr_cl_b:
    arb -2
    call execute_shr_cl_b
    jz  0, execute_shift_end

execute_shift_sar_cl_b:
    arb -2
    call execute_sar_cl_b
    jz  0, execute_shift_end

execute_shift_rol_cl_w:
    arb -2
    call execute_rol_cl_w
    jz  0, execute_shift_end

execute_shift_ror_cl_w:
    arb -2
    call execute_ror_cl_w
    jz  0, execute_shift_end

execute_shift_rcl_cl_w:
    arb -2
    call execute_rcl_cl_w
    jz  0, execute_shift_end

execute_shift_rcr_cl_w:
    arb -2
    call execute_rcr_cl_w
    jz  0, execute_shift_end

execute_shift_shl_cl_w:
    arb -2
    call execute_shl_cl_w
    jz  0, execute_shift_end

execute_shift_shr_cl_w:
    arb -2
    call execute_shr_cl_w
    jz  0, execute_shift_end

execute_shift_sar_cl_w:
    arb -2
    call execute_sar_cl_w

execute_shift_end:
    arb 1
    ret 3
.ENDFRAME

##########
# Map each OP value to the label that handles it
shift_1_b_table:
    db  execute_shift_rol_1_b
    db  execute_shift_ror_1_b
    db  execute_shift_rcl_1_b
    db  execute_shift_rcr_1_b
    db  execute_shift_shl_1_b
    db  execute_shift_shr_1_b
    db  execute_shift_invalid_op
    db  execute_shift_sar_1_b

shift_cl_b_table:
    db  execute_shift_rol_cl_b
    db  execute_shift_ror_cl_b
    db  execute_shift_rcl_cl_b
    db  execute_shift_rcr_cl_b
    db  execute_shift_shl_cl_b
    db  execute_shift_shr_cl_b
    db  execute_shift_invalid_op
    db  execute_shift_sar_cl_b

shift_1_w_table:
    db  execute_shift_rol_1_w
    db  execute_shift_ror_1_w
    db  execute_shift_rcl_1_w
    db  execute_shift_rcr_1_w
    db  execute_shift_shl_1_w
    db  execute_shift_shr_1_w
    db  execute_shift_invalid_op
    db  execute_shift_sar_1_w

shift_cl_w_table:
    db  execute_shift_rol_cl_w
    db  execute_shift_ror_cl_w
    db  execute_shift_rcl_cl_w
    db  execute_shift_rcr_cl_w
    db  execute_shift_shl_cl_w
    db  execute_shift_shr_cl_w
    db  execute_shift_invalid_op
    db  execute_shift_sar_cl_w

invalid_op_message:
    db  "invalid group shift operation", 0

.EOF
