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
.EXPORT pack_sr
.EXPORT unpack_sr

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
    add 65533, 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 256, [rb + tmp]           # read(0xfffd) * 0x100 -> [tmp]

    add 65532, 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + tmp], [reg_pc]      # read(0xfffc) + read(0xfffd) * 0x100 -> [reg_pc]

init_state_skip_reset_vec:
    # Check if pc is a sane value
    add [reg_pc], 0, [rb - 1]
    arb -1
    call check_16bit

    arb 1
    ret 0
.ENDFRAME

##########
pack_sr:
.FRAME sr                                           # returns sr
    arb -1

    add 16, 32, [rb + sr]                           # 0b0011_0000

    jz  [flag_carry], pack_sr_after_carry
    add [rb + sr], 1, [rb + sr]                     # 0b0000_0001
pack_sr_after_carry:

    jz  [flag_zero], pack_sr_after_zero
    add [rb + sr], 2, [rb + sr]                     # 0b0000_0010
pack_sr_after_zero:

    jz  [flag_interrupt], pack_sr_after_interrupt
    add [rb + sr], 4, [rb + sr]                     # 0b0000_0100
pack_sr_after_interrupt:

    jz  [flag_decimal], pack_sr_after_decimal
    add [rb + sr], 8, [rb + sr]                     # 0b0000_1000
pack_sr_after_decimal:

    jz  [flag_overflow], pack_sr_after_overflow
    add [rb + sr], 64, [rb + sr]                    # 0b0100_0000
pack_sr_after_overflow:

    jz  [flag_negative], pack_sr_after_negative
    add [rb + sr], 128, [rb + sr]                   # 0b1000_0000
pack_sr_after_negative:

    arb 1
    ret 0
.ENDFRAME

##########
unpack_sr:
.FRAME sr;
    lt  127, [rb + sr], [flag_negative]             # 0b1000_0000
    jz  [flag_negative], unpack_sr_after_negative
    add [rb + sr], -128, [rb + sr]
unpack_sr_after_negative:

    lt  63, [rb + sr], [flag_overflow]              # 0b0100_0000
    jz  [flag_overflow], unpack_sr_after_overflow
    add [rb + sr], -64, [rb + sr]
unpack_sr_after_overflow:

    lt  31, [rb + sr], [flag_decimal]               # 0b0010_0000; flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_ignored
    add [rb + sr], -32, [rb + sr]
unpack_sr_after_ignored:

    lt  15, [rb + sr], [flag_decimal]               # 0b0001_0000; flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_break
    add [rb + sr], -16, [rb + sr]
unpack_sr_after_break:

    lt  7, [rb + sr], [flag_decimal]                # 0b0000_1000
    jz  [flag_decimal], unpack_sr_after_decimal
    add [rb + sr], -8, [rb + sr]
unpack_sr_after_decimal:

    lt  3, [rb + sr], [flag_interrupt]              # 0b0000_0100
    jz  [flag_interrupt], unpack_sr_after_interrupt
    add [rb + sr], -4, [rb + sr]
unpack_sr_after_interrupt:

    lt  1, [rb + sr], [flag_zero]                   # 0b0000_0010
    jz  [flag_zero], unpack_sr_after_zero
    add [rb + sr], -2, [rb + sr]
unpack_sr_after_zero:

    lt  0, [rb + sr], [flag_carry]                  # 0b0000_0001

    ret 1
.ENDFRAME

.EOF
