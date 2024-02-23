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

# From binary.s
.IMPORT binary

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT read

# From util.s
.IMPORT check_16bit

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
    add 65532, 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 256, [rb + tmp]           # read(0xfffc) * 0x100 -> [tmp]

    add 65533, 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + tmp], [reg_pc]      # read(0xfffd) + read(0xfffc) * 0x100 -> [tmp]

init_state_skip_reset_vec:
    # Check if pc is a sane value
    add [reg_pc], 0, [rb - 1]
    arb -1
    call check_16bit

    arb 1
    ret 0
.ENDFRAME

.EOF
