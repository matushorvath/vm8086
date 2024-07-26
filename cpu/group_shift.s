.EXPORT execute_shift_1_b
.EXPORT execute_shift_1_w
.EXPORT execute_shift_cl_b
.EXPORT execute_shift_cl_w

# From util/error.s
.IMPORT report_error

# From rotate_b.s
.IMPORT execute_rol_1_b
.IMPORT execute_rol_cl_b
.IMPORT execute_ror_1_b
.IMPORT execute_ror_cl_b
.IMPORT execute_rcl_1_b
.IMPORT execute_rcl_cl_b
.IMPORT execute_rcr_1_b
.IMPORT execute_rcr_cl_b

# From rotate_w.s
.IMPORT execute_rol_1_w
.IMPORT execute_rol_cl_w
.IMPORT execute_ror_1_w
.IMPORT execute_ror_cl_w
.IMPORT execute_rcl_1_w
.IMPORT execute_rcl_cl_w
.IMPORT execute_rcr_1_w
.IMPORT execute_rcr_cl_w

# From shift_b.s
.IMPORT execute_shl_1_b
.IMPORT execute_shl_cl_b
.IMPORT execute_shr_1_b
.IMPORT execute_shr_cl_b
.IMPORT execute_sar_1_b
.IMPORT execute_sar_cl_b

# From shift_w.s
.IMPORT execute_shl_1_w
.IMPORT execute_shl_cl_w
.IMPORT execute_shr_1_w
.IMPORT execute_shr_cl_w
.IMPORT execute_sar_1_w
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
execute_shift_1_b:
.FRAME op, lseg, loff;
    # Determine which function to call
    add .table, [rb + op], [ip + 1]
    add [0], 0, [shift_function]

    # Call the function
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call [shift_function]

    ret 3

.table:
    db  execute_rol_1_b
    db  execute_ror_1_b
    db  execute_rcl_1_b
    db  execute_rcr_1_b
    db  execute_shl_1_b
    db  execute_shr_1_b
    db  invalid_shift_op
    db  execute_sar_1_b
.ENDFRAME

##########
execute_shift_1_w:
.FRAME op, lseg, loff;
    # Determine which function to call
    add .table, [rb + op], [ip + 1]
    add [0], 0, [shift_function]

    # Call the function
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call [shift_function]

    ret 3

.table:
    db  execute_rol_1_w
    db  execute_ror_1_w
    db  execute_rcl_1_w
    db  execute_rcr_1_w
    db  execute_shl_1_w
    db  execute_shr_1_w
    db  invalid_shift_op
    db  execute_sar_1_w
.ENDFRAME

##########
execute_shift_cl_b:
.FRAME op, lseg, loff;
    # Determine which function to call
    add .table, [rb + op], [ip + 1]
    add [0], 0, [shift_function]

    # Call the function
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call [shift_function]

    ret 3

.table:
    db  execute_rol_cl_b
    db  execute_ror_cl_b
    db  execute_rcl_cl_b
    db  execute_rcr_cl_b
    db  execute_shl_cl_b
    db  execute_shr_cl_b
    db  invalid_shift_op
    db  execute_sar_cl_b
.ENDFRAME

##########
execute_shift_cl_w:
.FRAME op, lseg, loff;
    # Determine which function to call
    add .table, [rb + op], [ip + 1]
    add [0], 0, [shift_function]

    # Call the function
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call [shift_function]

    ret 3

.table:
    db  execute_rol_cl_w
    db  execute_ror_cl_w
    db  execute_rcl_cl_w
    db  execute_rcr_cl_w
    db  execute_shl_cl_w
    db  execute_shr_cl_w
    db  invalid_shift_op
    db  execute_sar_cl_w
.ENDFRAME

##########
invalid_shift_op:
.FRAME lseg, loff;
    add .msg, 0, [rb - 1]
    arb -1
    call report_error

.msg:
    db  "invalid group shift operation", 0
.ENDFRAME

##########
shift_function:
    # Global variable to avoid issues when accessing local variables with updated rb
    db  0

.EOF
