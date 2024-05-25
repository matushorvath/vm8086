.EXPORT dump_state
.EXPORT handle_shutdown_api
.EXPORT mark
.EXPORT print_char

# From execute.s
.IMPORT halt

# From flags.s
.IMPORT pack_flags_lo
.IMPORT pack_flags_hi

# From memory.s
.IMPORT read_seg_off_w

# From state.s
.IMPORT reg_ip
.IMPORT reg_al

.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx
.IMPORT reg_sp
.IMPORT reg_bp
.IMPORT reg_si
.IMPORT reg_di

.IMPORT reg_cs
.IMPORT reg_ds
.IMPORT reg_ss
.IMPORT reg_es

.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow
.IMPORT flag_interrupt
.IMPORT flag_direction
.IMPORT flag_trap

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

# TODO split dump_state.s, bochs.s

##########
dump_state:
.FRAME port, value; tmp
    arb -1

    add separator, 0, [rb - 1]
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
    ret 2
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
.FRAME flags_lo, flags_hi, tmp
    arb -3

    add dump_state_flags, 0, [rb - 1]
    arb -1
    call print_str

    # Print flags as lowercase/uppercase characters
    out '-'
    out '-'
    out '-'
    out '-'

    mul [flag_overflow], -0x20, [rb + tmp]
    add 'o', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    mul [flag_direction], -0x20, [rb + tmp]
    add 'd', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    mul [flag_interrupt], -0x20, [rb + tmp]
    add 'i', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    mul [flag_trap], -0x20, [rb + tmp]
    add 't', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    out ' '

    mul [flag_sign], -0x20, [rb + tmp]
    add 's', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    mul [flag_zero], -0x20, [rb + tmp]
    add 'z', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    out '-'

    mul [flag_auxiliary_carry], -0x20, [rb + tmp]
    add 'a', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    out '-'

    mul [flag_parity], -0x20, [rb + tmp]
    add 'p', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    out '-'

    mul [flag_carry], -0x20, [rb + tmp]
    add 'c', [rb + tmp], [rb + tmp]
    out [rb + tmp]

    out ' '

    # Binary value
    call pack_flags_hi
    add [rb - 2], 0, [rb + flags_hi]
    call pack_flags_lo
    add [rb - 2], 0, [rb + flags_lo]

    add [rb + flags_hi], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    add [rb + flags_lo], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '
    out '('

    # Hexadecimal value
    add [rb + flags_hi], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    add [rb + flags_lo], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ')'

    arb 3
    ret 0
.ENDFRAME

.SYMBOL DUMP_STACK_BYTES                16

##########
dump_stack:
.FRAME index, segment, offset, tmp
    arb -4

    add dump_state_stack, 0, [rb - 1]
    arb -1
    call print_str

    add 0, 0, [rb + index]

dump_stack_loop:
    lt  [rb + index], DUMP_STACK_BYTES, [rb + tmp]
    jz  [rb + tmp], dump_stack_end

    out ' '

    # Calculate segment
    mul [reg_ss + 1], 0x100, [rb + segment]
    add [reg_ss + 0], [rb + segment], [rb + segment]

    # Calculate offset with wrap around to 0x1000
    mul [reg_sp + 1], 0x100, [rb + offset]
    add [reg_sp + 0], [rb + offset], [rb + offset]
    add [rb + index], [rb + offset], [rb + offset]

    lt  [rb + offset], 0x10000, [rb + tmp]
    jnz [rb + tmp], dump_stack_after_overflow
    add [rb + offset], -0x10000, [rb + offset]

dump_stack_after_overflow:
    add [rb + segment], 0, [rb - 1]
    add [rb + offset], 0, [rb - 2]
    arb -2
    call read_seg_off_w

    mul [rb - 5], 0x100, [rb + tmp]
    add [rb - 4], [rb + tmp], [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    add [rb + index], 2, [rb + index]
    jz  0, dump_stack_loop

dump_stack_end:
    arb 4
    ret 0
.ENDFRAME

##########
mark:
.FRAME port, mark; tmp
    arb -1

    add separator, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    add mark_header, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + mark], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 2
.ENDFRAME

##########
print_char:
.FRAME port, value;
    out [reg_al]
    ret 2
.ENDFRAME

##########
handle_shutdown_api:
.FRAME port, value; tmp
    arb -1

    add handle_shutdown_api_string, [handle_shutdown_api_state], [ip + 1]
    eq  [0], [rb + value], [rb + tmp]
    jnz [rb + tmp], handle_shutdown_api_advance_state

    # Wrong character, reset the state
    add 0, 0, [handle_shutdown_api_state]
    jz  0, handle_shutdown_api_done

handle_shutdown_api_advance_state:
    add [handle_shutdown_api_state], 1, [handle_shutdown_api_state]

    # If we are not at the end of the string, return
    add handle_shutdown_api_string, [handle_shutdown_api_state], [ip + 1]
    jnz [0], handle_shutdown_api_done

    # Halt the VM
    add 1, 0, [halt]

handle_shutdown_api_done:
    arb 1
    ret 2

handle_shutdown_api_state:
    db  0
handle_shutdown_api_string:
    db  "Shutdown", 0
.ENDFRAME

##########
separator:
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
    db  "stack:", 0

mark_header:
    db  "MARK: ", 0

.EOF
