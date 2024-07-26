.EXPORT init_processor_test

# From util/brk.s
.IMPORT brk
.IMPORT sbrk

# From util/error.s
.IMPORT report_error

# From cpu/flags.s
.IMPORT unpack_flags_lo
.IMPORT unpack_flags_hi

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

# From test_header.s
.IMPORT test_header_end
.IMPORT init_ax
.IMPORT init_bx
.IMPORT init_cx
.IMPORT init_dx
.IMPORT init_cs
.IMPORT init_ss
.IMPORT init_ds
.IMPORT init_es
.IMPORT init_sp
.IMPORT init_bp
.IMPORT init_si
.IMPORT init_di
.IMPORT init_ip
.IMPORT init_flags

.IMPORT init_mem_length
.IMPORT result_mem_length
.IMPORT mem_data

# From util/util.s
.IMPORT split_16_8_8

##########
init_processor_test:
.FRAME
    call init_heap
    call init_registers
    call init_memory

    ret 0
.ENDFRAME

##########
init_heap:
.FRAME program_break
    arb -1

    # The __heap_start symbol does not account for the test data that was concatenated
    # to the binary without properly linking it. Set up program break so future memory
    # allocations will not overwrite the test data.

    mul [init_mem_length], 2, [rb + program_break]
    add [rb + program_break], [result_mem_length], [rb + program_break]
    add [rb + program_break], mem_data, [rb + program_break]

    add [rb + program_break], 0, [rb - 1]
    arb -1
    call brk

    arb 1
    ret 0
.ENDFRAME

##########
init_registers:
.FRAME tmp
    arb -1

    # Load all registers
    add [init_ax], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_ax + 0]
    add [rb - 4], 0, [reg_ax + 1]

    add [init_bx], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_bx + 0]
    add [rb - 4], 0, [reg_bx + 1]

    add [init_cx], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_cx + 0]
    add [rb - 4], 0, [reg_cx + 1]

    add [init_dx], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_dx + 0]
    add [rb - 4], 0, [reg_dx + 1]

    add [init_cs], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_cs + 0]
    add [rb - 4], 0, [reg_cs + 1]

    add [init_ss], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_ss + 0]
    add [rb - 4], 0, [reg_ss + 1]

    add [init_ds], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_ds + 0]
    add [rb - 4], 0, [reg_ds + 1]

    add [init_es], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_es + 0]
    add [rb - 4], 0, [reg_es + 1]

    add [init_sp], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_sp + 0]
    add [rb - 4], 0, [reg_sp + 1]

    add [init_bp], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_bp + 0]
    add [rb - 4], 0, [reg_bp + 1]

    add [init_si], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_si + 0]
    add [rb - 4], 0, [reg_si + 1]

    add [init_di], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_di + 0]
    add [rb - 4], 0, [reg_di + 1]

    add [init_ip], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_ip + 0]
    add [rb - 4], 0, [reg_ip + 1]

    # Split flags to two bytes and unpack them
    add [init_flags], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [rb - 1]
    add [rb - 4], 0, [rb + tmp]

    arb -1
    call unpack_flags_lo

    add [rb + tmp], 0, [rb - 1]
    arb -1
    call unpack_flags_hi

    arb 1
    ret 0
.ENDFRAME

##########
init_memory:
.FRAME index, count, address, value, tmp
    arb -5

    # Reserve space for 8086 memory
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Iterate through memory initialization records and process them
    add 0, 0, [rb + index]
    add [init_mem_length], 0, [rb + count]

.loop:
    eq  [rb + index], [rb + count], [rb + tmp]
    jnz [rb + tmp], .done

    # Read address and value for this location
    mul [rb + index], 2, [rb + tmp]
    add mem_data + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + address]
    add mem_data + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + value]

    # Store value at that location
    add [mem], [rb + address], [ip + 3]
    add [rb + value], 0, [0]

    add [rb + index], 1, [rb + index]
    jz  0, .loop

.done:
    arb 5
    ret 0
.ENDFRAME

.EOF
