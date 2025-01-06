.EXPORT init_rom_image
.EXPORT init_images

# From state.s
.IMPORT mem

# From util/error.s
.IMPORT report_error

# From util/util.s
.IMPORT check_range

# From libxib.a
.IMPORT brk
.IMPORT sbrk

# TODO this should not be part of libcpu.a

##########
init_rom_image:
.FRAME rom_address, rom_image;
    add [rb + rom_address], 0, [rb - 1]
    add [rb + rom_image], 0, [rb - 2]
    add 0, 0, [rb - 3]
    add 0, 0, [rb - 4]
    arb -4
    call init_images

    ret 2
.ENDFRAME

##########
init_images:
.FRAME rom_address, rom_image, floppy_a_image, floppy_b_image; floppy_a, floppy_b, floppy_a_size, floppy_b_size # returns floppy_a|b, floppy_a|b_size
    arb -4

    # This function assumes the ROM image is in memory immediately before the optional A and B floppy images

    add 0, 0, [rb + floppy_a]
    add 0, 0, [rb + floppy_a_size]
    add 0, 0, [rb + floppy_b]
    add 0, 0, [rb + floppy_b_size]

    # Validate the ROM address
    add [rb + rom_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Reclaim memory used by images; this assumes there were no allocations yet
    add [rb + rom_image], 0, [rb - 1]
    arb -1
    call brk

    # Reserve space for 8086 memory
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Allocate memory for floppy A, if enabled
    jz  [rb + floppy_a_image], .after_alloc_floppy_a

    # Save floppy size
    add [rb + floppy_a_image], 0, [ip + 1]
    add [0], 0, [rb + floppy_a_size]

    # Reserve space for the floppy image
    add [rb + floppy_a_size], 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + floppy_a]

.after_alloc_floppy_a:
    # Allocate memory for floppy B, if enabled
    jz  [rb + floppy_b_image], .after_alloc_floppy_b

    # Save floppy size
    add [rb + floppy_b_image], 0, [ip + 1]
    add [0], 0, [rb + floppy_b_size]

    # Reserve space for the floppy image
    add [rb + floppy_b_size], 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + floppy_b]

.after_alloc_floppy_b:
    # The output buffers we allocated for inflated images overlap the input buffers with compressed image data
    # We need to inflate the images back to front to avoid overwriting inputs we still need

    # Inflate the image for floppy B, if enabled
    jz  [rb + floppy_b_image], .after_inflate_floppy_b

    # Inflate the floppy image
    add [rb + floppy_b_image], 0, [rb - 1]
    add [rb + floppy_b], 0, [rb - 2]
    add [rb + floppy_b], [rb + floppy_b_size], [rb - 3]
    arb -3
    call inflate_image

.after_inflate_floppy_b:
    # Inflate the image for floppy A, if enabled
    jz  [rb + floppy_a_image], .after_inflate_floppy_a

    # Inflate the floppy image
    add [rb + floppy_a_image], 0, [rb - 1]
    add [rb + floppy_a], 0, [rb - 2]
    add [rb + floppy_a], [rb + floppy_a_size], [rb - 3]
    arb -3
    call inflate_image

.after_inflate_floppy_a:
    # Inflate the ROM
    add [rb + rom_image], 0, [rb - 1]
    add [mem], [rb + rom_address], [rb - 2]
    add [mem], 0x100000, [rb - 3]
    arb -3
    call inflate_image

    arb 4
    ret 4
.ENDFRAME

##########
inflate_image:
.FRAME image, base_address, limit_address; section_count, image_header, image_data, section_header, section_address, section_data, section_size, tmp
    arb -8

    # This function zeroes out the input image, to make sure we don't leave any invalid numbers accessible to the 8086

    # Parse the image
    add [rb + image], 1, [ip + 1]
    add [0], 0, [rb + section_count]
    add [rb + image], 2, [rb + image_header]
    mul [rb + section_count], 3, [rb + image_data]
    add [rb + image_header], [rb + image_data], [rb + image_data]

    # Load image sections end to start

.loop:
    jz  [rb + section_count], .done
    add [rb + section_count], -1, [rb + section_count]

    # Load section header
    mul [rb + section_count], 3, [rb + section_header]
    add [rb + image_header], [rb + section_header], [rb + section_header]

    add [rb + section_header], 0, [ip + 1]
    add [0], [rb + base_address], [rb + section_address]
    add [rb + section_header], 1, [ip + 1]
    add [0], [rb + image_data], [rb + section_data]
    add [rb + section_header], 2, [ip + 1]
    add [0], 0, [rb + section_size]

    # Validate the section will fit within the limit
    add [rb + section_address], [rb + section_size], [rb + tmp]
    lt  [rb + limit_address], [rb + tmp], [rb + tmp]
    jnz [rb + tmp], .too_big

    # Clear the section header
    add [rb + section_header], 0, [ip + 3]
    add 0, 0, [0]
    add [rb + section_header], 1, [ip + 3]
    add 0, 0, [0]
    add [rb + section_header], 2, [ip + 3]
    add 0, 0, [0]

    # Move the section to target location
    add [rb + section_data], 0, [rb - 1]
    add [rb + section_address], 0, [rb - 2]
    add [rb + section_size], 0, [rb - 3]
    arb -3
    call move_memory_reverse

    jz  0, .loop

.done:
    # Clear the section count
    add image, 0, [ip + 3]
    add 0, 0, [0]

    arb 8
    ret 3

.too_big:
    add .too_big_message, 0, [rb - 1]
    arb -1
    call report_error

.too_big_message:
    db  "image too big to load at that address", 0
.ENDFRAME

##########
move_memory_reverse:
.FRAME source, target, count; tmp
    arb -1

    # Do we need to move the memory at all?
    eq  [rb + source], [rb + target], [rb + tmp]
    jnz [rb + tmp], .done

.loop:
    # Move a section from source to target (iterating in reverse direction)
    jz  [rb + count], .done
    add [rb + count], -1, [rb + count]

    # Copy one byte
    add [rb + source], [rb + count], [ip + 5]
    add [rb + target], [rb + count], [ip + 3]
    add [0], 0, [0]

    # Zero the source byte
    add [rb + source], [rb + count], [ip + 3]
    add 0, 0, [0]

    jz  0, .loop

.done:
    arb 1
    ret 3
.ENDFRAME

.EOF
