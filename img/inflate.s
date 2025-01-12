.EXPORT inflate_image

# From util/error.s
.IMPORT report_error

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
