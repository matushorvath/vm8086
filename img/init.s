.EXPORT init_images

# From images.s
.IMPORT floppy_count
.IMPORT floppy_image
.IMPORT floppy_data
.IMPORT floppy_size

# From inflate.s
.IMPORT deflated_size
.IMPORT inflate_image

# From cpu/state.s
.IMPORT mem

# From util/error.s
.IMPORT report_error

# From util/util.s
.IMPORT check_range

# From libxib.a
.IMPORT brk
.IMPORT sbrk

##########
init_images:
.FRAME images, rom_address; index, image, tmp
    arb -3

    # This function assumes the first image is the ROM, followed by up to MAX_FLOPPY_COUNT-1 floppy images

    # Validate the ROM address
    add [rb + rom_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Reclaim memory used by the images; this assumes there were no allocations yet
    add [rb + images], 0, [rb - 1]
    arb -1
    call brk

    # Reserve space for 8086 memory (including space for the ROM image)
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Find the first floppy image (by skipping the ROM image)
    add [rb + images], 0, [rb - 1]
    arb -1
    call deflated_size

    add [rb + images], [rb - 3], [rb + image]

    # Load information about deflated floppy images
    add 0, 0, [rb + index]

.load_loop:
    add [rb + image], 0, [ip + 1]
    jz  [0], .load_done

    # Save deflated floppy image pointer
    add floppy_image, [rb + index], [ip + 3]
    add [rb + image], 0, [0]                                # floppy_image[index] = image

    # Save floppy image size
    add [rb + image], 0, [ip + 1]
    add [0], 0, [rb + tmp]                                  # tmp = image.size
    add floppy_size, [rb + index], [ip + 3]
    add [rb + tmp], 0, [0]                                  # floppy_size[index] = tmp

    # Allocate space for inflated floppy image
    add [rb + tmp], 0, [rb - 1]
    arb -1
    call sbrk

    add floppy_data, [rb + index], [ip + 3]
    add [rb - 3], 0, [0]                                    # floppy_data[index] = sbrk(tmp)

    # Move to next image
    add [rb + image], 0, [rb - 1]
    arb -1
    call deflated_size

    add [rb + image], [rb - 3], [rb + image]                # image = image + deflated_size(image)
    add [rb + index], 1, [rb + index]

    lt  [rb + index], 16, [rb + tmp]                        # if (index >= MAX_FLOPPY_COUNT (16)) report_error()
    jz  [rb + tmp], .too_many_images

    jz  0, .load_loop

.load_done:
    add [rb + index], 0, [floppy_count]

    # The output buffers we allocated for inflated images overlap the input buffers with compressed image data
    # We need to inflate the images back to front to avoid overwriting inputs we still need

.inflate_loop:
    jz  [rb + index], .inflate_done
    add [rb + index], -1, [rb + index]

    # Inflate the floppy image
    add floppy_image, [rb + index], [ip + 1]
    add [0], 0, [rb - 1]                                    # param0 = floppy_image[index]
    add floppy_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 2]                                    # param1 = floppy_data[index]
    add floppy_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 3]
    add floppy_size, [rb + index], [ip + 1]
    add [0], [rb - 3], [rb - 3]                             # param2 = floppy_data[index] + floppy_size[index]
    arb -3
    call inflate_image

    jz  0, .inflate_loop

.inflate_done:
    # Inflate the ROM (the first deflated image)
    add [rb + images], 0, [rb - 1]
    add [mem], [rb + rom_address], [rb - 2]
    add [mem], 0x100000, [rb - 3]
    arb -3
    call inflate_image

    arb 3
    ret 2

.too_many_images:
    add .too_many_images_msg, 0, [rb - 1]
    arb -1
    call report_error

.too_many_images_msg:
    db  "too many floppy images", 0
.ENDFRAME

.EOF
