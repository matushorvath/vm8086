.EXPORT init_rom_image
.EXPORT init_images

.EXPORT floppy_image
.EXPORT floppy_size

# From brk.s
.IMPORT brk
.IMPORT sbrk

# From util/error.s
.IMPORT report_error

# From state.s
.IMPORT mem

# From util/util.s
.IMPORT check_range

##########
init_rom_image:
.FRAME rom_address, rom_section_count, rom_header, rom_data;
    add [rb + rom_address], 0, [rb - 1]
    add [rb + rom_section_count], 0, [rb - 2]
    add [rb + rom_header], 0, [rb - 3]
    add [rb + rom_data], 0, [rb - 4]
    add 0, 0, [rb - 5]
    add 0, 0, [rb - 6]
    add 0, 0, [rb - 7]
    arb -7
    call init_images

    ret 4
.ENDFRAME

##########
init_images:
.FRAME rom_address, rom_section_count, rom_header, rom_data, floppy_section_count, floppy_header, floppy_data; tmp
    arb -1

    # This function assumes rom_data is in memory immediately before floppy_data

    # Reclaim memory used by image data; this assumes there were no allocations yet
    add [rb + rom_data], 0, [rb - 1]
    arb -1
    call brk

    # Validate the ROM address
    add [rb + rom_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Reserve space for 8086 memory
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Skip floppy image initialization if there is no floppy
    jz  [rb + floppy_section_count], init_images_after_floppy

    # Determine floppy size from the last section
    mul [rb + floppy_section_count], 3, [rb + tmp]
    add [rb + tmp], -3, [rb + tmp]
    add [rb + floppy_header], [rb + tmp], [rb + tmp]

    add [rb + tmp], 0, [ip + 6]
    add [rb + tmp], 2, [ip + 1]
    add [0], [0], [floppy_size]

    # Reserve space for the floppy image
    add [floppy_size], 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [floppy_image]

    # Inflate the floppy image
    add [rb + floppy_section_count], 0, [rb - 1]
    add [rb + floppy_header], 0, [rb - 2]
    add [rb + floppy_data], 0, [rb - 3]
    add [floppy_image], 0, [rb - 4]
    add [floppy_image], [floppy_size], [rb - 5]
    arb -5
    call inflate_image

init_images_after_floppy:
    # Inflate the ROM
    add [rb + rom_section_count], 0, [rb - 1]
    add [rb + rom_header], 0, [rb - 2]
    add [rb + rom_data], 0, [rb - 3]
    add [mem], [rb + rom_address], [rb - 4]
    add [mem], 0x100000, [rb - 5]
    arb -5
    call inflate_image

    arb 1
    ret 7
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

##########
floppy_image:
    db  0
floppy_size:
    db  0

.EOF
