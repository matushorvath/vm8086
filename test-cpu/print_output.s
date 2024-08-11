.EXPORT print_output

# From test_header.s
.IMPORT init_mem_length
.IMPORT result_mem_length
.IMPORT mem_data

# From cpu/flags.s
.IMPORT pack_flags_lo
.IMPORT pack_flags_hi

# From cpu/state.s
.IMPORT reg_ip
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
.IMPORT mem

# From libxib.a
.IMPORT print_str
.IMPORT print_num_radix

##########
print_output:
.FRAME
    add start, 0, [rb - 1]
    arb -1
    call print_str

    add label_ax, 0, [rb - 1]
    add reg_ax, 0, [rb - 2]
    arb -2
    call print_register

    add label_bx, 0, [rb - 1]
    add reg_bx, 0, [rb - 2]
    arb -2
    call print_register

    add label_cx, 0, [rb - 1]
    add reg_cx, 0, [rb - 2]
    arb -2
    call print_register

    add label_dx, 0, [rb - 1]
    add reg_dx, 0, [rb - 2]
    arb -2
    call print_register

    add label_cs, 0, [rb - 1]
    add reg_cs, 0, [rb - 2]
    arb -2
    call print_register

    add label_ss, 0, [rb - 1]
    add reg_ss, 0, [rb - 2]
    arb -2
    call print_register

    add label_ds, 0, [rb - 1]
    add reg_ds, 0, [rb - 2]
    arb -2
    call print_register

    add label_es, 0, [rb - 1]
    add reg_es, 0, [rb - 2]
    arb -2
    call print_register

    add label_sp, 0, [rb - 1]
    add reg_sp, 0, [rb - 2]
    arb -2
    call print_register

    add label_bp, 0, [rb - 1]
    add reg_bp, 0, [rb - 2]
    arb -2
    call print_register

    add label_si, 0, [rb - 1]
    add reg_si, 0, [rb - 2]
    arb -2
    call print_register

    add label_di, 0, [rb - 1]
    add reg_di, 0, [rb - 2]
    arb -2
    call print_register

    add label_ip, 0, [rb - 1]
    add reg_ip, 0, [rb - 2]
    arb -2
    call print_register

    call print_flags

    add middle, 0, [rb - 1]
    arb -1
    call print_str

    call print_memory

    add end, 0, [rb - 1]
    arb -1
    call print_str

    ret 0
.ENDFRAME

##########
print_register:
.FRAME label, regptr; value
    arb -1

    add [rb + label], 0, [rb - 1]
    arb -1
    call print_str

    add [rb + regptr], 1, [ip + 1]
    mul [0], 0x100, [rb + value]
    add [rb + regptr], 0, [ip + 1]
    add [0], [rb + value], [rb + value]

    add [rb + value], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    arb 1
    ret 2
.ENDFRAME

##########
print_flags:
.FRAME flags
    arb -1

    add label_flags, 0, [rb - 1]
    arb -1
    call print_str

    call pack_flags_hi
    mul [rb - 2], 0x100, [rb + flags]
    call pack_flags_lo
    add [rb - 2], [rb + flags], [rb + flags]

    add [rb + flags], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    arb 1
    ret 0
.ENDFRAME

##########
print_memory:
.FRAME result_data, index, count, address, value, tmp
    arb -6

    mul [init_mem_length], 2, [rb + tmp]
    add mem_data, [rb + tmp], [rb + result_data]

    # Iterate through memory result records and process them
    add 0, 0, [rb + index]
    add [result_mem_length], 0, [rb + count]

.loop:
    eq  [rb + index], [rb + count], [rb + tmp]
    jnz [rb + tmp], .done

    # Read address from the record
    add [rb + result_data], [rb + index], [ip + 1]
    add [0], 0, [rb + address]

    # Read value at that address
    add [mem], [rb + address], [ip + 1]
    add [0], 0, [rb + value]

    # Print a comma unless it's the first item
    jz  [rb + index], .skip_comma
    out ','

.skip_comma:
    out '['

    # Print the address and value
    add [rb + address], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ','

    add [rb + value], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ']'

    add [rb + index], 1, [rb + index]
    jz  0, .loop

.done:
    arb 6
    ret 0
.ENDFRAME

##########
start:
    db  "{\"regs\":", 0
label_ax:
    db  "{\"ax\":", 0
label_bx:
    db  ",\"bx\":", 0
label_cx:
    db  ",\"cx\":", 0
label_dx:
    db  ",\"dx\":", 0
label_cs:
    db  ",\"cs\":", 0
label_ss:
    db  ",\"ss\":", 0
label_ds:
    db  ",\"ds\":", 0
label_es:
    db  ",\"es\":", 0
label_sp:
    db  ",\"sp\":", 0
label_bp:
    db  ",\"bp\":", 0
label_si:
    db  ",\"si\":", 0
label_di:
    db  ",\"di\":", 0
label_ip:
    db  ",\"ip\":", 0
label_flags:
    db  ",\"flags\":", 0
middle:
    db  "},\"ram\":[", 0
end:
    db  "]}", 0

.EOF
