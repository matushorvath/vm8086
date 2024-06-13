.EXPORT init_memory

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
init_memory:
.FRAME rom_address, rom_section_count, rom_header, rom_data;
    # Reclaim memory used by the binary data; this assumes there were no allocations yet
    add [rb + rom_data], 0, [rb - 1]
    arb -1
    call brk

    # Reserve space for 8086 memory
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Validate the ROM address
    add [rb + rom_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Inflate the ROM
    add [rb + rom_section_count], 0, [rb - 1]
    add [rb + rom_header], 0, [rb - 2]
    add [rb + rom_data], 0, [rb - 3]
    add [mem], [rb + rom_address], [rb - 4]
    add [mem], 0x100000, [rb - 5]
    arb -5
    call inflate_image

    ret 4
.ENDFRAME

##########
inflate_image:
.FRAME img_section_count, img_header, img_data, img_address, limit; section_header, section_address, section_data, section_size, tmp
    arb -5

    # Load image sections end to start

inflate_image_loop:
    jz  [rb + img_section_count], inflate_image_done
    add [rb + img_section_count], -1, [rb + img_section_count]

    # Load section header
    mul [rb + img_section_count], 3, [rb + section_header]
    add [rb + img_header], [rb + section_header], [rb + section_header]

    add [rb + section_header], 0, [ip + 1]
    add [0], [rb + img_address], [rb + section_address]
    add [rb + section_header], 1, [ip + 1]
    add [0], [rb + img_data], [rb + section_data]
    add [rb + section_header], 2, [ip + 1]
    add [0], 0, [rb + section_size]

    # Validate the section will fit within the limit
    add [rb + section_address], [rb + section_size], [rb + tmp]
    lt  [rb + limit], [rb + tmp], [rb + tmp]
    jnz [rb + tmp], inflate_image_too_big

    # Move the section to target location
    add [rb + section_data], 0, [rb - 1]
    add [rb + section_address], 0, [rb - 2]
    add [rb + section_size], 0, [rb - 3]
    arb -3
    call move_memory_reverse

    jz  0, inflate_image_loop

inflate_image_done:
    arb 5
    ret 5

inflate_image_too_big:
    add inflate_image_too_big_message, 0, [rb - 1]
    arb -1
    call report_error

inflate_image_too_big_message:
    db  "image too big to load at that address", 0
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
