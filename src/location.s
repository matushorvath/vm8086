.EXPORT read_location_b
.EXPORT read_location_w
.EXPORT write_location_b
.EXPORT write_location_w

# From memory.s
.IMPORT read_b
.IMPORT write_b

# Location is a generalized data item, which can refer either to 8086 memory or to an 8086 register.
# The location has a type and an address.

# loc_type: 0
# loc_addr: intcode address of an 8-bit 8086 register, or of the lo byte of a 16-bit 8086 register
#
# loc_type: 1
# loc_addr: 8086 physical memory address

##########
read_location_b:
.FRAME loc_type, loc_addr; value                            # returns value
    arb -1

    jz  [rb + loc_type], read_location_b_register

    # Read from an 8086 address
    add [rb + loc_addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value]

    jz  0, read_location_b_done

read_location_b_register:
    # Read from an intcode address
    add [rb + loc_addr], 0, [ip + 1]
    add [0], 0, [rb + value]

read_location_b_done:
    arb 1
    ret 2
.ENDFRAME

##########
read_location_w:
.FRAME loc_type, loc_addr; value_lo, value_hi               # returns value_lo, value_hi
    arb -2

    jz  [rb + loc_type], read_location_w_register

    # Read from an 8086 address
    add [rb + loc_addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    # TODO loc_addr wrap around to 20 bits
    add [rb + loc_addr], 1, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    jz  0, read_location_w_done

read_location_w_register:
    # Read from an intcode address
    add [rb + loc_addr], 0, [ip + 1]
    add [0], 0, [rb + value_lo]

    add [rb + loc_addr], 1, [ip + 1]
    add [0], 0, [rb + value_hi]

read_location_w_done:
    arb 2
    ret 2
.ENDFRAME

##########
write_location_b:
.FRAME loc_type, loc_addr, value;
    jz  [rb + loc_type], write_location_b_register

    # Write to an 8086 address
    add [rb + loc_addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call write_b

    jz  0, write_location_b_done

write_location_b_register:
    # Write to an intcode address
    add [rb + loc_addr], 0, [ip + 3]
    add [rb + value], 0, [0]

write_location_b_done:
    ret 3
.ENDFRAME

##########
write_location_w:
.FRAME loc_type, loc_addr, value_lo, value_hi;
    jz  [rb + loc_type], write_location_w_register

    # Write to an 8086 address
    add [rb + loc_addr], 0, [rb - 1]
    add [rb + value_lo], 0, [rb - 2]
    arb -2
    call write_b

    # TODO loc_addr wrap around to 20 bits
    add [rb + loc_addr], 1, [rb - 1]
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_b

    jz  0, write_location_w_done

write_location_w_register:
    # Write to an intcode address
    add [rb + loc_addr], 0, [ip + 3]
    add [rb + value_lo], 0, [0]

    add [rb + loc_addr], 1, [ip + 3]
    add [rb + value_hi], 0, [0]

write_location_w_done:
    ret 4
.ENDFRAME

.EOF
