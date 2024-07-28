.EXPORT read_location_b
.EXPORT read_location_w
.EXPORT read_location_dw
.EXPORT write_location_b
.EXPORT write_location_w

# From util/error.s
.IMPORT report_error

# From memory.s
.IMPORT read_seg_off_w
.IMPORT read_seg_off_dw
.IMPORT write_seg_off_w

# From regions.s
.IMPORT read_memory_b
.IMPORT write_memory_b

# Location is a generalized data item:
#
# lseg: 0x10000
# loff: intcode address, for example of an 8-bit 8086 register, or of the lo byte of a 16-bit 8086 register
#
# lseg: < 0x10000; segment part of an 8086 address
# loff: offset part of an 8086 address

##########
read_location_b:
.FRAME lseg, loff; value, tmp                               # returns value
    arb -2

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], .register

    # Read from an 8086 address

    # 32107654321076543210
    # |-----seg------|
    #     |-----off------|

    # Calculate the physical address
    mul [rb + lseg], 0x10, [rb - 1]
    add [rb + loff], [rb - 1], [rb - 1]

    # Wrap around to 20 bits
    lt  [rb - 1], 0x100000, [rb - 2]
    jnz [rb - 2], .after_mod

    add [rb - 1], -0x100000, [rb - 1]

.after_mod:
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value]

    jz  0, .done

.register:
    # Read from an intcode address
    add [rb + loff], 0, [ip + 1]
    add [0], 0, [rb + value]

.done:
    arb 2
    ret 2
.ENDFRAME

##########
read_location_w:
.FRAME lseg, loff; value_lo, value_hi, tmp                  # returns value_*
    arb -3

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], .register

    # Read from an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    jz  0, .done

.register:
    # Read from an intcode address
    add [rb + loff], 0, [ip + 1]
    add [0], 0, [rb + value_lo]

    add [rb + loff], 1, [ip + 1]
    add [0], 0, [rb + value_hi]

.done:
    arb 3
    ret 2
.ENDFRAME

##########
read_location_dw:
.FRAME lseg, loff; value_ll, value_lh, value_hl, value_hh, tmp                  # returns value_*
    arb -5

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], .register

    # Read from an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_seg_off_dw
    add [rb - 4], 0, [rb + value_ll]
    add [rb - 5], 0, [rb + value_lh]
    add [rb - 6], 0, [rb + value_hl]
    add [rb - 7], 0, [rb + value_hh]

    jz  0, .done

.register:
    # The location must be 8086 memory, since we read 4 bytes from it
    add .register_message, 0, [rb - 1]
    arb -1
    call report_error

.done:
    arb 5
    ret 2

.register_message:
    db  "cannot read 4 bytes from a register", 0
.ENDFRAME

##########
write_location_b:
.FRAME lseg, loff, value; tmp
    arb -1

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], .register

    # Write to an 8086 address

    # 32107654321076543210
    # |-----seg------|
    #     |-----off------|

    # Calculate the physical address
    mul [rb + lseg], 0x10, [rb - 1]
    add [rb + loff], [rb - 1], [rb - 1]

    # Wrap around to 20 bits
    lt  [rb - 1], 0x100000, [rb - 2]
    jnz [rb - 2], .after_mod

    add [rb - 1], -0x100000, [rb - 1]

.after_mod:
    add [rb + value], 0, [rb - 2]
    arb -2
    call write_memory_b

    jz  0, .done

.register:
    # Write to an intcode address
    add [rb + loff], 0, [ip + 3]
    add [rb + value], 0, [0]

.done:
    arb 1
    ret 3
.ENDFRAME

##########
write_location_w:
.FRAME lseg, loff, value_lo, value_hi; tmp
    arb -1

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], .register

    # Write to an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    jz  0, .done

.register:
    # Write to an intcode address
    add [rb + loff], 0, [ip + 3]
    add [rb + value_lo], 0, [0]

    add [rb + loff], 1, [ip + 3]
    add [rb + value_hi], 0, [0]

.done:
    arb 1
    ret 4
.ENDFRAME

.EOF
