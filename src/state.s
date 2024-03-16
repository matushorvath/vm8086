.EXPORT reg_ip

.EXPORT reg_ax
.EXPORT reg_al
.EXPORT reg_ah

.EXPORT reg_bx
.EXPORT reg_bl
.EXPORT reg_bh

.EXPORT reg_cx
.EXPORT reg_cl
.EXPORT reg_ch

.EXPORT reg_dx
.EXPORT reg_dl
.EXPORT reg_dh

.EXPORT reg_sp
.EXPORT reg_bp
.EXPORT reg_si
.EXPORT reg_di

.EXPORT reg_cs
.EXPORT reg_ds
.EXPORT reg_ss
.EXPORT reg_es

.EXPORT flag_carry
.EXPORT flag_parity
.EXPORT flag_auxiliary_carry
.EXPORT flag_zero
.EXPORT flag_sign
.EXPORT flag_overflow

.EXPORT flag_interrupt
.EXPORT flag_direction
.EXPORT flag_trap

.EXPORT init_state
# TODO .EXPORT pack_sr TODO rename sr
# TODO .EXPORT unpack_sr TODO rename sr
.EXPORT inc_ip

# From the linked 8086 binary
.IMPORT binary_start_address_cs
.IMPORT binary_start_address_ip

# From error.s
.IMPORT report_error

# From memory.s
# TODO .IMPORT read

# From util.s
.IMPORT check_range

##########
# vm state

reg_ip:
    db  0
    db  0

reg_ax:
reg_al:
    db  0
reg_ah:
    db  0

reg_bx:
reg_bl:
    db  0
reg_bh:
    db  0

reg_cx:
reg_cl:
    db  0
reg_ch:
    db  0

reg_dx:
reg_dl:
    db  0
reg_dh:
    db  0

reg_sp:
    db  0
    db  0

reg_bp:
    db  0
    db  0

reg_si:
    db  0
    db  0

reg_di:
    db  0
    db  0

reg_cs:
    db  0
    db  0

reg_ds:
    db  0
    db  0

reg_ss:
    db  0
    db  0

reg_es:
    db  0
    db  0

# FLAGS: ----ODIT SZ-A-P-C

flag_carry:                             # CF
    db  0
flag_parity:                            # PF
    db  0
flag_auxiliary_carry:                   # AF
    db  0
flag_zero:                              # ZF
    db  0
flag_sign:                              # SF
    db  0
flag_overflow:                          # OF
    db  0
flag_interrupt:                         # IF
    db  0
flag_direction:                         # DF
    db  0
flag_trap:                              # TF
    db  0

##########
init_state:
.FRAME tmp
    arb -1

    # Load the start address to cs:ip
    add [binary_start_address_cs + 0], 0, [reg_cs + 0]
    add [binary_start_address_cs + 1], 0, [reg_cs + 1]
    add [binary_start_address_ip + 0], 0, [reg_ip + 0]
    add [binary_start_address_ip + 1], 0, [reg_ip + 1]

    # Check if cs:ip is a sane value
    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    add 0xffff, 0, [rb - 2]
    arb -2
    call check_range

    mul [reg_ip + 1], 0x100, [rb - 1]
    add [reg_ip + 0], [rb - 1], [rb - 1]
    add 0xffff, 0, [rb - 2]
    arb -2
    call check_range

    arb 1
    ret 0
.ENDFRAME

##########
# Increase ip with wrap around
inc_ip:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_ip + 0], 1, [reg_ip + 0]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_done

    add 0, 0, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_done

    # Overflow to zero
    add 0, 0, [reg_ip + 1]

inc_ip_done:
    arb 1
    ret 0
.ENDFRAME

.EOF

##########
pack_sr: # TODO rename sr
.FRAME sr                                           # returns sr
    arb -1

    add 0b00110000, 0, [rb + sr]

    jz  [flag_carry], pack_sr_after_carry
    add [rb + sr], 0b00000001, [rb + sr]
pack_sr_after_carry:

    jz  [flag_zero], pack_sr_after_zero
    add [rb + sr], 0b00000010, [rb + sr]
pack_sr_after_zero:

    jz  [flag_interrupt], pack_sr_after_interrupt
    add [rb + sr], 0b00000100, [rb + sr]
pack_sr_after_interrupt:

    jz  [flag_decimal], pack_sr_after_decimal
    add [rb + sr], 0b00001000, [rb + sr]
pack_sr_after_decimal:

    jz  [flag_overflow], pack_sr_after_overflow
    add [rb + sr], 0b01000000, [rb + sr]
pack_sr_after_overflow:

    jz  [flag_negative], pack_sr_after_negative
    add [rb + sr], 0b10000000, [rb + sr]
pack_sr_after_negative:


    arb 1
    ret 0
.ENDFRAME

##########
unpack_sr: # TODO rename sr
.FRAME sr;
    lt  0b01111111, [rb + sr], [flag_negative]
    jz  [flag_negative], unpack_sr_after_negative
    add [rb + sr], -0b10000000, [rb + sr]
unpack_sr_after_negative:

    lt  0b00111111, [rb + sr], [flag_overflow]
    jz  [flag_overflow], unpack_sr_after_overflow
    add [rb + sr], -0b01000000, [rb + sr]
unpack_sr_after_overflow:

    lt  0b00011111, [rb + sr], [flag_decimal]               # flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_ignored
    add [rb + sr], -0b00100000, [rb + sr]
unpack_sr_after_ignored:

    lt  0b00001111, [rb + sr], [flag_decimal]               # flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_break
    add [rb + sr], -0b00010000, [rb + sr]
unpack_sr_after_break:

    lt  0b00000111, [rb + sr], [flag_decimal]
    jz  [flag_decimal], unpack_sr_after_decimal
    add [rb + sr], -0b00001000, [rb + sr]
unpack_sr_after_decimal:

    lt  0b00000011, [rb + sr], [flag_interrupt]
    jz  [flag_interrupt], unpack_sr_after_interrupt
    add [rb + sr], -0b00000100, [rb + sr]
unpack_sr_after_interrupt:

    lt  0b00000001, [rb + sr], [flag_zero]
    jz  [flag_zero], unpack_sr_after_zero
    add [rb + sr], -0b00000010, [rb + sr]
unpack_sr_after_zero:

    lt  0, [rb + sr], [flag_carry]

    ret 1
.ENDFRAME
