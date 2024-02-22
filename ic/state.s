.EXPORT reg_pc
.EXPORT reg_sp

.EXPORT reg_a
.EXPORT reg_x
.EXPORT reg_y

.EXPORT flag_negative
.EXPORT flag_overflow
.EXPORT flag_decimal
.EXPORT flag_interrupt
.EXPORT flag_zero
.EXPORT flag_carry

.EXPORT init_state

# From error.s
.IMPORT report_error

# From binary.s
.IMPORT binary

##########
# vm state

reg_pc:
    db  0
reg_sp:
    db  255                 # 0xff

reg_a:
    db  0
reg_x:
    db  0
reg_y:
    db  0

flag_negative:              # N
    db  0
flag_overflow:              # V
    db  0
flag_decimal:               # D
    db  0
flag_interrupt:             # I
    db  0
flag_zero:                  # Z
    db  0
flag_carry:                 # C
    db  0

##########
init_state:
.FRAME tmp
    arb -1

    # Load the start address to pc
    add [binary + 0], 0, [reg_pc]

    # If it is -1, use the reset vector
    eq  [reg_pc], -1, [rb + tmp]
    jz  [rb + tmp], init_state_skip_reset_vec

    # Read the reset vector from 0xfffc and 0xfffd
    add MEM, 65532, [ip + 1]
    mul [0], 256, [rb + tmp]                # [0xfffc] * 0x100

    add MEM, 65533, [ip + 1]
    add [0], [rb + tmp], [reg_pc]           # + [0xfffd]

init_state_skip_reset_vec:
    # Check if pc is a sane value
    lt  [reg_pc], 0, [rb + tmp]
    jnz [rb + tmp], init_state_pc_invalid
    lt  65535, [reg_pc], [rb + tmp]
    jnz [rb + tmp], init_state_pc_invalid

    arb 1
    ret 0

init_state_pc_invalid:
    # check if pc is a sane value
    add err_pc_invalid, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
# error messages

err_pc_invalid:
    db  "Initial value of pc register is invalid", 0

.EOF
