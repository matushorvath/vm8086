.EXPORT reg_ip

.EXPORT reg_al
.EXPORT reg_ah
.EXPORT reg_bl
.EXPORT reg_bh
.EXPORT reg_cl
.EXPORT reg_ch
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

# From binary.s
.IMPORT binary

# From error.s
.IMPORT report_error

# From memory.s
# TODO .IMPORT read

# From util.s
.IMPORT check_16bit

##########
# vm state

reg_ip:
    db  0

reg_al:
    db  0
reg_ah:
    db  0
reg_bl:
    db  0
reg_bh:
    db  0
reg_cl:
    db  0
reg_ch:
    db  0
reg_dl:
    db  0
reg_dh:
    db  0

reg_sp:
    db  0
reg_bp:
    db  0
reg_si:
    db  0
reg_di:
    db  0

reg_cs:
    db  0
reg_ds:
    db  0
reg_ss:
    db  0
reg_es:
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
    add [binary + 0], 0, [reg_ip]
    add [binary + 1], 0, [reg_cs]

    # Check if cs:ip is a sane value
    add [reg_ip], 0, [rb - 1]
    arb -1
    call check_16bit

    add [reg_cs], 0, [rb - 1]
    arb -1
    call check_16bit

    arb 1
    ret 0
.ENDFRAME

##########
# Increase ip with wrap around
inc_ip:
.FRAME tmp
    arb -1

    add [reg_ip], 1, [reg_ip]

    eq  [reg_ip], 65536, [rb + tmp]
    jz  [rb + tmp], inc_ip_done

    add 0, 0, [reg_ip]

inc_ip_done:
    arb 1
    ret 0
.ENDFRAME

.EOF

##########
pack_sr: # TODO rename sr
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
unpack_sr: # TODO rename sr
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
