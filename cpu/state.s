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

.EXPORT inc_ip_b
.EXPORT inc_ip_w

.EXPORT mem

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
    db  0xff
    db  0xff

reg_ds:
    db  0
    db  0

reg_ss:
    db  0
    db  0

reg_es:
    db  0
    db  0

mem:
    db  0

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
# Increment ip by 1 with wrap around
inc_ip_b:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_ip + 0], 1, [reg_ip + 0]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .done

    add [reg_ip + 1], -0x100, [reg_ip + 1]

.done:
    arb 1
    ret 0
.ENDFRAME

##########
# Increment ip by 2 with wrap around
inc_ip_w:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_ip + 0], 2, [reg_ip + 0]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .done

    add [reg_ip + 1], -0x100, [reg_ip + 1]

.done:
    arb 1
    ret 0
.ENDFRAME

.EOF
