.EXPORT calc_addr
.EXPORT calc_cs_ip_addr

.EXPORT read_b
.EXPORT write_b

.EXPORT read_seg_off_b
.EXPORT read_seg_off_w
.EXPORT write_seg_off_b
.EXPORT write_seg_off_w

.EXPORT read_cs_ip_b
.EXPORT read_cs_ip_w

#.EXPORT push
#.EXPORT pop

# From state.s
.IMPORT mem
.IMPORT reg_cs
.IMPORT reg_ip

# From util.s
.IMPORT modulo

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
calc_addr:
.FRAME seg, off; addr                                       # returns addr
    arb -1

    # Calculate the physical address
    mul [rb + seg], 0x10, [rb + addr]
    add [rb + off], [rb + addr], [rb - 1]                   # store to param 0

    # Wrap around to 20 bits
    # TODO should be less than 0x10000 over, instead of modulo just subtract 0x10000?
    add 0x100000, 0, [rb - 2]
    arb -2
    call modulo
    add [rb - 4], 0, [rb + addr]

    arb 1
    ret 2
.ENDFRAME

##########
calc_cs_ip_addr:
.FRAME addr                                                 # returns addr
    arb -1

    #      3210|7654 3210|7654 3210
    # cs = ---csh--- ---csl---
    # ip =      ---iph--- ---ipl---
    #
    # addr = (((csh << 4) + iph) << 4 + csl) << 4 + ipl;

    # Calculate the physical address
    mul [reg_cs + 1], 0x10, [rb + addr]
    add [reg_ip + 1], [rb + addr], [rb + addr]
    mul [rb + addr], 0x10, [rb + addr]
    add [reg_cs + 0], [rb + addr], [rb + addr]
    mul [rb + addr], 0x10, [rb + addr]
    add [reg_ip + 0], [rb + addr], [rb - 1]                 # store to param 0

    # Wrap around to 20 bits
    # TODO should be less than 0x10000 over, instead of modulo just subtract 0x10000?
    add 0x100000, 0, [rb - 2]
    arb -2
    call modulo
    add [rb - 4], 0, [rb + addr]

    arb 1
    ret 0
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

    add [rb + addr], 1, [rb - 1]                            # TODO wrap around to 20 bits
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

    add [rb + addr], 1, [rb - 1]                            # TODO wrap around to 20 bits
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_b

    arb 1
    ret 4
.ENDFRAME

##########
read_cs_ip_b:
.FRAME value, addr                                          # returns value
    arb -2

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value]

    arb 2
    ret 0
.ENDFRAME

##########
read_cs_ip_w:
.FRAME value_lo, value_hi, addr                             # returns value_lo, value_hi
    arb -3

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr], 1, [rb - 1]                            # TODO wrap around to 20 bits
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    arb 3
    ret 0
.ENDFRAME

.EOF
