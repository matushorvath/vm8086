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
.EXPORT inc_ip
.EXPORT dump_state

.EXPORT mem

# From the linked 8086 binary
.IMPORT binary_start_address_cs
.IMPORT binary_start_address_ip

# From flags.s
.IMPORT pack_flags_lo
.IMPORT pack_flags_hi

# From memory.s
.IMPORT read_seg_off_w

# From util.s
.IMPORT check_range

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

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
# Increment ip with wrap around
inc_ip:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_ip + 0], 1, [reg_ip + 0]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_done

    # Overflow to zero
    add [reg_ip + 1], -0x100, [reg_ip + 1]

inc_ip_done:
    arb 1
    ret 0
.ENDFRAME

##########
dump_state:
.FRAME tmp
    arb -1

    add dump_state_separator, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    add dump_state_ip, 0, [rb - 1]
    add reg_ip + 0, 0, [rb - 2]
    arb -2
    call dump_register

    call dump_flags

    out 10

    add dump_state_cs, 0, [rb - 1]
    add reg_cs + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_ds, 0, [rb - 1]
    add reg_ds + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_ss, 0, [rb - 1]
    add reg_ss + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_es, 0, [rb - 1]
    add reg_es + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_bp, 0, [rb - 1]
    add reg_bp + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_sp, 0, [rb - 1]
    add reg_sp + 0, 0, [rb - 2]
    arb -2
    call dump_register

    out 10

    add dump_state_ax, 0, [rb - 1]
    add reg_ax + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_bx, 0, [rb - 1]
    add reg_bx + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_cx, 0, [rb - 1]
    add reg_cx + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_dx, 0, [rb - 1]
    add reg_dx + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_si, 0, [rb - 1]
    add reg_si + 0, 0, [rb - 2]
    arb -2
    call dump_register

    add dump_state_di, 0, [rb - 1]
    add reg_di + 0, 0, [rb - 2]
    arb -2
    call dump_register

    out 10

    call dump_stack

    out 10

    arb 1
    ret 0
.ENDFRAME

##########
dump_register:
.FRAME label, regptr; tmp
    arb -1

    add [rb + label], 0, [rb - 1]
    arb -1
    call print_str

    add [rb + regptr], 1, [ip + 1]
    mul [0], 0x100, [rb + tmp]
    add [rb + regptr], 0, [ip + 1]
    add [0], [rb + tmp], [rb + tmp]

    add [rb + tmp], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    arb 1
    ret 2
.ENDFRAME

##########
dump_flags:
.FRAME tmp
    arb -1

    add dump_state_flags, 0, [rb - 1]
    arb -1
    call print_str

    call pack_flags_hi
    add [rb - 2], 0, [rb + tmp]

    add [rb + tmp], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    call pack_flags_lo
    add [rb - 2], 0, [rb + tmp]

    add [rb + tmp], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix

    arb 1
    ret 0
.ENDFRAME

.SYMBOL DUMP_STACK_BYTES                16

##########
dump_stack:
.FRAME index, tmp
    arb -2

    add dump_state_stack, 0, [rb - 1]
    arb -1
    call print_str

    add 0, 0, [rb + index]

dump_stack_loop:
    lt  [rb + index], DUMP_STACK_BYTES, [rb + tmp]
    jz  [rb + tmp], dump_stack_end

    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    add [rb + index], [rb - 2], [rb - 2]                    # TODO no sp overflow support
    arb -2
    call read_seg_off_w

    mul [rb - 5], 0x100, [rb + tmp]
    add [rb - 4], [rb + tmp], [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    add [rb + index], 2, [rb + index]
    jz  0, dump_stack_loop

dump_stack_end:
    arb 2
    ret 0
.ENDFRAME

##########
dump_state_separator:
    db  "----------", 0

dump_state_ip:
    db  "ip: ", 0
dump_state_flags:
    db  " flags: ", 0

dump_state_cs:
    db  "cs: ", 0
dump_state_ds:
    db  " ds: ", 0
dump_state_ss:
    db  " ss: ", 0
dump_state_es:
    db  " es: ", 0
dump_state_sp:
    db  " sp: ", 0
dump_state_bp:
    db  " bp: ", 0

dump_state_ax:
    db  "ax: ", 0
dump_state_bx:
    db  " bx: ", 0
dump_state_cx:
    db  " cx: ", 0
dump_state_dx:
    db  " dx: ", 0
dump_state_si:
    db  " si: ", 0
dump_state_di:
    db  " di: ", 0

dump_state_stack:
    db  "stack: ", 0

.EOF
