.EXPORT init_images

# From floppy.s
.IMPORT floppy_count
.IMPORT floppy_data
.IMPORT floppy_size

# From images.s
.IMPORT image_count
.IMPORT image_data
.IMPORT image_size

# From inflate.s
.IMPORT deflated_size
.IMPORT inflate_image
.IMPORT move_memory_reverse

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
.FRAME rom_headers, images;
    # Parameters:
    #
    # rom_headers:              Pointer to zero-terminated array of ROM header records
    #
    # ROM header record:
    #       address (1 byte):   Memory address where this ROM should be mapped in memory
    #
    # images:                   Pointer to zero-terminated list of ROM image data
    #
    # Assuming there are N rom_header records, the first N images are ROM data which should
    # be mapped into 8086 memory. All records after that are floppy images, which are used
    # by libfdc to emulate floppy disks. There are up to MAX_IMAGE_COUNT-1 images.
    #
    # Each image is a bin2obj generated binary, with its own headers as documented in bin2obj
    # The last image is followed by uninitialized intcode memory, which behaves as all zeros.

    # Reclaim memory used by the images; this assumes there were no allocations yet
    add [rb + images], 0, [rb - 1]
    arb -1
    call brk

    # Allocate space for 8086 memory. This allocation also serves the purpose of making sure 
    # each inflated image buffer starts after the corresponing deflated data. This might not 
    # otherwise be guaranteed, since an inflated image can be shorter than its deflated data.
    add 0x100000, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [mem]

    # Expand all images in memory
    add [rb + images], 0, [rb - 1]
    arb -1
    call expand_images

    # Process the expanded images
    add [rb + rom_headers], 0, [rb - 1]
    arb -1
    call process_images

    ret 2
.ENDFRAME

##########
expand_images:
.FRAME images; index, image, tmp
    arb -3

    # Expand all deflated images in memory, filling a table with expanded image information

    # Load information about deflated floppy images
    add [rb + images], 0, [rb + image]
    add 0, 0, [rb + index]

.load_loop:
    add [rb + image], 0, [ip + 1]
    jz  [0], .load_done

    # Save deflated image pointer
    add .deflated_data, [rb + index], [ip + 3]
    add [rb + image], 0, [0]                                # deflated_data[index] = image

    # Save image size
    add [rb + image], 0, [ip + 1]
    add [0], 0, [rb + tmp]                                  # tmp = image.size
    add image_size, [rb + index], [ip + 3]
    add [rb + tmp], 0, [0]                                  # image_size[index] = tmp

    # Allocate space for the inflated image
    add [rb + tmp], 0, [rb - 1]
    arb -1
    call sbrk

    add image_data, [rb + index], [ip + 3]
    add [rb - 3], 0, [0]                                    # image_data[index] = sbrk(tmp)

    # Move to next image
    add [rb + image], 0, [rb - 1]
    arb -1
    call deflated_size

    add [rb + image], [rb - 3], [rb + image]                # image = image + deflated_size(image)
    add [rb + index], 1, [rb + index]

    lt  [rb + index], 32, [rb + tmp]                        # if (index >= MAX_IMAGE_COUNT (32)) report_error()
    jz  [rb + tmp], .too_many_images

    jz  0, .load_loop

.load_done:
    add [rb + index], 0, [image_count] # TODO use image_count instead of index

    # The output buffers we allocated for inflated images overlap the input buffers with compressed image data
    # We need to inflate the images back to front to avoid overwriting inputs we still need

.inflate_loop:
    jz  [rb + index], .inflate_done
    add [rb + index], -1, [rb + index]

    # Inflate the image
    add .deflated_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 1]                                    # param0 = deflated_data[index]
    add image_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 2]                                    # param1 = image_data[index]
    add image_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 3]
    add image_size, [rb + index], [ip + 1]
    add [0], [rb - 3], [rb - 3]                             # param2 = image_data[index] + image_size[index]
    arb -3
    call inflate_image

    jz  0, .inflate_loop

.inflate_done:
    arb 3
    ret 1

.deflated_data:
    # Array of pointers to deflated image data
    ds  32, 0       # MAX_IMAGE_COUNT

.too_many_images:
    add .too_many_images_msg, 0, [rb - 1]
    arb -1
    call report_error

.too_many_images_msg:
    db  "too many binary images", 0
.ENDFRAME

##########
process_images:
.FRAME rom_headers; index, image_type, address, tmp
    arb -4

    # First images are ROM images, until we run out of rom_headers
    add .process_rom, 0, [rb + image_type]

    # Zero out floppy image count
    add 0, 0, [floppy_count]

    # Iterate through all expanded images and pass them to the correct subsystem based on image type
    add 0, 0, [rb + index]

.process_loop:
    lt  [rb + index], [image_count], [rb + tmp]
    jz  [rb + tmp], .done

    # Process the image based on current image type
    jz  0, [rb + image_type]

.process_rom:
    # We are still processing ROMs, load image address from the ROM header
    add [rb + rom_headers], [rb + index], [ip + 1]
    add [0], 0, [rb + address]

    # Is there actually a ROM header for this image?
    jnz [rb + address], .is_rom

    # There is no ROM header, so this is the first floppy image
    add .process_floppy, 0, [rb + image_type]
    jz  0, .process_floppy

.is_rom:
    # This is a ROM image, validate the ROM address
    add [rb + address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Copy image data to main memory
    add image_data, [rb + index], [ip + 1]
    add [0], 0, [rb - 1]
    add [mem], [rb + address], [rb - 2]
    add image_size, [rb + index], [ip + 1]
    add [0], 0, [rb - 3]
    arb -3
    call move_memory_reverse

    jz  0, .process_next

.process_floppy:
    # We are processing floppy images, pass the image data to libfdc
    add image_data, [rb + index], [ip + 1]
    add [0], 0, [rb + tmp]
    add floppy_data, [floppy_count], [ip + 3]
    add [rb + tmp], 0, [0]

    add image_size, [rb + index], [ip + 1]
    add [0], 0, [rb + tmp]
    add floppy_size, [floppy_count], [ip + 3]
    add [rb + tmp], 0, [0]

    add [floppy_count], 1, [floppy_count]

    # Verify there are at most MAX_FLOPPY_COUNT (16) floppy images
    lt  [floppy_count], 16, [rb + tmp]
    jz  [rb + tmp], .too_many_floppy_images

    jz  0, .process_next

.process_next:
    # Move to next image
    add [rb + index], 1, [rb + index]
    jz  0, .process_loop

.done:
    arb 4
    ret 1

.too_many_floppy_images:
    add .too_many_floppy_images_msg, 0, [rb - 1]
    arb -1
    call report_error

.too_many_floppy_images_msg:
    db  "too many floppy images", 0
.ENDFRAME

.EOF
