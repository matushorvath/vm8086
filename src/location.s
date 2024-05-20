.EXPORT read_location_b
.EXPORT read_location_w
.EXPORT read_location_dw
.EXPORT write_location_b
.EXPORT write_location_w

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT read_seg_off_b
.IMPORT read_seg_off_w
.IMPORT read_seg_off_dw
.IMPORT write_seg_off_b
.IMPORT write_seg_off_w

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
    jnz [rb + tmp], read_location_b_register

    # Read from an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_seg_off_b
    add [rb - 4], 0, [rb + value]

    jz  0, read_location_b_done

read_location_b_register:
    # Read from an intcode address
    add [rb + loff], 0, [ip + 1]
    add [0], 0, [rb + value]

read_location_b_done:
    arb 2
    ret 2
.ENDFRAME

##########
read_location_w:
.FRAME lseg, loff; value_lo, value_hi, tmp                  # returns value_*
    arb -3

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], read_location_w_register

    # Read from an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    jz  0, read_location_w_done

read_location_w_register:
    # Read from an intcode address
    add [rb + loff], 0, [ip + 1]
    add [0], 0, [rb + value_lo]

    add [rb + loff], 1, [ip + 1]
    add [0], 0, [rb + value_hi]

read_location_w_done:
    arb 3
    ret 2
.ENDFRAME

##########
read_location_dw:
.FRAME lseg, loff; value_ll, value_lh, value_hl, value_hh, tmp                  # returns value_*
    arb -5

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], read_location_dw_register

    # Read from an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_seg_off_dw
    add [rb - 4], 0, [rb + value_ll]
    add [rb - 5], 0, [rb + value_lh]
    add [rb - 6], 0, [rb + value_hl]
    add [rb - 7], 0, [rb + value_hh]

    jz  0, read_location_dw_done

read_location_dw_register:
    # The location must be 8086 memory, since we read 4 bytes from it
    add read_location_dw_register_message, 0, [rb - 1]
    arb -1
    call report_error

read_location_dw_done:
    arb 5
    ret 2

read_location_dw_register_message:
    db  "cannot read 4 bytes from a register", 0
.ENDFRAME

##########
write_location_b:
.FRAME lseg, loff, value; tmp
    arb -1

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], write_location_b_register

    # Write to an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value], 0, [rb - 3]
    arb -3
    call write_seg_off_b

    jz  0, write_location_b_done

write_location_b_register:
    # Write to an intcode address
    add [rb + loff], 0, [ip + 3]
    add [rb + value], 0, [0]

write_location_b_done:
    arb 1
    ret 3
.ENDFRAME

##########
write_location_w:
.FRAME lseg, loff, value_lo, value_hi; tmp
    arb -1

    eq  [rb + lseg], 0x10000, [rb + tmp]
    jnz [rb + tmp], write_location_w_register

    # Write to an 8086 address
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    jz  0, write_location_w_done

write_location_w_register:
    # Write to an intcode address
    add [rb + loff], 0, [ip + 3]
    add [rb + value_lo], 0, [0]

    add [rb + loff], 1, [ip + 3]
    add [rb + value_hi], 0, [0]

write_location_w_done:
    arb 1
    ret 4
.ENDFRAME

.EOF
