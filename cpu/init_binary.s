.EXPORT init_binary

# From the linked 8086 binary
.IMPORT binary_start_address_cs
.IMPORT binary_start_address_ip
.IMPORT binary_load_address

# From brk.s
.IMPORT brk
.IMPORT sbrk

# From util/error.s
.IMPORT report_error

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT mem

# From util/util.s
.IMPORT check_range

##########
init_binary:
.FRAME rom_section_count, rom_header, rom_data;
    call init_binary_state

    add [rb + rom_section_count], 0, [rb - 1]
    add [rb + rom_header], 0, [rb - 2]
    add [rb + rom_data], 0, [rb - 3]
    arb -3
    call init_binary_memory

    ret 3
.ENDFRAME

##########
init_binary_state:
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
init_binary_memory:
.FRAME rom_section_count, rom_header, rom_data; tmp
    arb -1

    # Initialize memory space for the 8086.

    # Validate the load address is a valid 16-bit number
    add [binary_load_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Reclaim memory used by the binary data; assumes there were no allocations yet
    add [rb + rom_data], 0, [rb - 1]
    arb -1
    call brk

    # Reserve space for 8086 memory
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

init_memory_loop:
    # Process binary sections end to start
    jz  [rb + rom_section_count], init_memory_done
    add [rb + rom_section_count], -1, [rb + rom_section_count]

    # Load section header
    mul [rb + rom_section_count], 3, [rb + tmp]
    add [rb + rom_header], [rb + tmp], [rb + tmp]

    add [rb + tmp], 0, [ip + 1]
    add [0], 0, [rb - 1]
    add [rb + tmp], 1, [ip + 1]
    add [0], 0, [rb - 2]
    add [rb + tmp], 2, [ip + 1]
    add [0], 0, [rb - 3]
    add [rb + rom_data], 0, [rb - 4]
    arb -4
    call init_binary_section

    jz  0, init_memory_loop

init_memory_done:
    arb 1
    ret 3
.ENDFRAME

##########
init_binary_section:
.FRAME section_address, section_start, section_size, rom_data; tmp
    arb -1

    # Calculate target 8086 address where this section should be moved
    add [binary_load_address], [rb + section_address], [rb + section_address]

    # Validate the section will fit to 20-bits when moved there
    add [rb + section_address], [rb + section_size], [rb + tmp]
    lt  0x100000, [rb + tmp], [rb + tmp]
    jnz [rb + tmp], init_section_too_big

    # Source intcode address where this section currently is
    add [rb + rom_data], [rb + section_start], [rb - 1]
    # Target intcode address where this section should be moved
    add [mem], [rb + section_address], [rb - 2]
    # Number of bytes to copy
    add [rb + section_size], 0, [rb - 3]

    arb -3
    call move_memory_reverse

    arb 1
    ret 4

init_section_too_big:
    add init_section_too_big_message, 0, [rb - 1]
    arb -1
    call report_error

init_section_too_big_message:
    db  "image too big to load at specified address", 0
.ENDFRAME

##########
move_memory_reverse:
.FRAME source, target, count; tmp
    arb -1

    # Do we need to move the memory at all?
    eq  [rb + source], [rb + target], [rb + tmp]
    jnz [rb + tmp], move_memory_reverse_done

move_memory_reverse_loop:
    # Move a section from source to target (iterating in reverse direction)
    jz  [rb + count], move_memory_reverse_done
    add [rb + count], -1, [rb + count]

    # Copy one byte
    add [rb + source], [rb + count], [ip + 5]
    add [rb + target], [rb + count], [ip + 3]
    add [0], 0, [0]

    # Zero the source byte
    add [rb + source], [rb + count], [ip + 3]
    add 0, 0, [0]

    jz  0, move_memory_reverse_loop

move_memory_reverse_done:
    arb 1
    ret 3
.ENDFRAME

.EOF
