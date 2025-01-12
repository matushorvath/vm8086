.EXPORT init_rom_image
.EXPORT init_images

# From inflate.s
.IMPORT inflate_image

# From cpu/state.s
.IMPORT mem

# From util/util.s
.IMPORT check_range

# From libxib.a
.IMPORT brk
.IMPORT sbrk

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

    # Save floppy image size
    add [rb + floppy_a_image], 0, [ip + 1]
    add [0], 0, [rb + floppy_a_size]

    jz  [rb + floppy_a_size], .after_alloc_floppy_a

    # Reserve space for the floppy image
    add [rb + floppy_a_size], 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + floppy_a]

.after_alloc_floppy_a:
    # Allocate memory for floppy B, if enabled
    jz  [rb + floppy_b_image], .after_alloc_floppy_b

    # Save floppy image size
    add [rb + floppy_b_image], 0, [ip + 1]
    add [0], 0, [rb + floppy_b_size]

    jz  [rb + floppy_b_size], .after_alloc_floppy_b

    # Reserve space for the floppy image
    add [rb + floppy_b_size], 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + floppy_b]

.after_alloc_floppy_b:
    # The output buffers we allocated for inflated images overlap the input buffers with compressed image data
    # We need to inflate the images back to front to avoid overwriting inputs we still need

    # Inflate the image for floppy B, if enabled
    jz  [rb + floppy_b_size], .after_inflate_floppy_b

    # Inflate the floppy image
    add [rb + floppy_b_image], 0, [rb - 1]
    add [rb + floppy_b], 0, [rb - 2]
    add [rb + floppy_b], [rb + floppy_b_size], [rb - 3]
    arb -3
    call inflate_image

.after_inflate_floppy_b:
    # Inflate the image for floppy A, if enabled
    jz  [rb + floppy_a_size], .after_inflate_floppy_a

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

.EOF
