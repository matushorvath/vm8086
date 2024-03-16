.EXPORT init_memory
.EXPORT calc_addr

.EXPORT read_b
.EXPORT read_w
.EXPORT write_b
.EXPORT write_w

.EXPORT read_seg_off_b
.EXPORT read_seg_off_w
.EXPORT write_seg_off_b
.EXPORT write_seg_off_w

.EXPORT read_cs_ip_b
.EXPORT read_cs_ip_w

#.EXPORT push
#.EXPORT pop

# From the linked 8086 binary
.IMPORT binary_load_address
.IMPORT binary_length
.IMPORT binary_data

# From error.s
.IMPORT report_error

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# From util.s
.IMPORT check_range
.IMPORT mod

##########
init_memory:
.FRAME tmp, src, tgt, cnt
    arb -4

    # Initialize memory space for the 8086.

    # Validate the load address is a valid 20-bit number
    add [binary_load_address], 0, [rb - 1]
    add 0xfffff, 0, [rb - 2]
    arb -2
    call check_range

    # Validate the image will fit to 20-bits when loaded there
    add [binary_load_address], [binary_length], [rb + tgt]
    lt  0x100000, [rb + tgt], [rb + tmp]
    jz  [rb + tmp], init_memory_load_address_ok

    add image_too_big_error, 0, [rb - 1]
    arb -1
    call report_error

init_memory_load_address_ok:
    # The 8086 memory space will start where the binary starts now
    add binary_data, 0, [mem]

    # Do we need to move the binary to a different load address?
    jz  [binary_load_address], init_memory_done

    # Yes, calculate beginning address of the source (binary),
    add binary_data, 0, [rb + src]

    # Calculate the beginning address of the target ([mem] + [load])
    add [mem], [binary_load_address], [rb + tgt]

    # Number of bytes to copy
    add [binary_length], 0, [rb + cnt]

init_memory_loop:
    # Move the image from src to tgt (iterating in reverse direction)
    jz  [rb + cnt], init_memory_done
    add [rb + cnt], -1, [rb + cnt]

    # Copy one byte
    add [rb + src], [rb + cnt], [ip + 5]
    add [rb + tgt], [rb + cnt], [ip + 3]
    add [0], 0, [0]

    # Zero the source byte
    add [rb + src], [rb + cnt], [ip + 3]
    add 0, 0, [0]

    jz  0, init_memory_loop

init_memory_done:
    arb 4
    ret 0
.ENDFRAME

##########
read_b:
.FRAME addr; value                                          # returns value
    arb -1

    # TODO support memory mapped IO

    # Regular memory read
    add [mem], [rb + addr], [ip + 1]
    add [0], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
read_w:
.FRAME addr; value_lo, value_hi                             # returns value_lo, value_hi
    arb -2

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr], 1, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    arb 2
    ret 1
.ENDFRAME

##########
write_b:
.FRAME addr, value;
    # TODO support memory mapped IO
    # TODO handle not being able to write to ROM

    # Regular memory write
    add [mem], [rb + addr], [ip + 3]
    add [rb + value], 0, [0]

    ret 2
.ENDFRAME

##########
write_w:
.FRAME addr, value_lo, value_hi;
    add [rb + addr], 0, [rb - 1]
    add [rb + value_lo], 0, [rb - 2]
    arb -2
    call write_b

    add [rb + addr], 1, [rb - 1]
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_b

    ret 3
.ENDFRAME

##########
calc_addr:
.FRAME seg, off; addr                                       # returns addr
    arb -1

    # Calculate the physical address
    mul [rb + seg], 16, [rb + addr]
    add [rb + off], [rb + addr], [rb - 1]                   # store to param 0

    # Wrap around to 20 bits
    add 0x100000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + addr]

    arb 1
    ret 2
.ENDFRAME

##########
read_seg_off_b:
.FRAME seg, off; value, addr                                # returns value
    arb -2

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr
    add [rb - 4], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value]

    arb 2
    ret 2
.ENDFRAME

##########
read_seg_off_w:
.FRAME seg, off; value_lo, value_hi, addr                   # returns value_lo, value_hi
    arb -3

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr
    add [rb - 4], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr], 1, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    arb 3
    ret 2
.ENDFRAME

##########
write_seg_off_b:
.FRAME seg, off, value; addr
    arb -1

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr
    add [rb - 4], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call write_b

    arb 1
    ret 3
.ENDFRAME

##########
write_seg_off_w:
.FRAME seg, off, value_lo, value_hi; addr
    arb -1

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr
    add [rb - 4], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    add [rb + value_lo], 0, [rb - 2]
    arb -2
    call write_b

    add [rb + addr], 1, [rb - 1]
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_b

    arb 1
    ret 4
.ENDFRAME

##########
read_cs_ip_b:
.FRAME value                                                # returns value
    arb -1

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [reg_ip + 1], 0x100, [rb - 2]
    add [reg_ip + 0], [rb - 2], [rb - 2]
    arb -2
    call read_seg_off_b
    add [rb - 4], 0, [rb + value]

    arb 1
    ret 0
.ENDFRAME

##########
read_cs_ip_w:
.FRAME value_lo, value_hi                                   # returns value_lo, value_hi
    arb -2

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [reg_ip + 1], 0x100, [rb - 2]
    add [reg_ip + 0], [rb - 2], [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    arb 2
    ret 0
.ENDFRAME

##########
mem:
    db  0

image_too_big_error:
    db  "image too big to load at specified address", 0

.EOF
