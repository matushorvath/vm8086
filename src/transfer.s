.EXPORT execute_mov_b
.EXPORT execute_mov_w

.EXPORT execute_xchg_b
.EXPORT execute_xchg_w
.EXPORT execute_xchg_ax_w

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

# From state.s
.IMPORT reg_ax

##########
execute_mov_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b() -> param3
    arb -3
    call write_location_b

    ret 4
.ENDFRAME

##########
execute_mov_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_w().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_w().hi -> param4
    arb -4
    call write_location_w

    ret 4
.ENDFRAME

##########
execute_xchg_b:
.FRAME loc_type_1, loc_addr_1, loc_type_2, loc_addr_2; value
    arb -1

    # Read the first value
    add [rb + loc_type_1], 0, [rb - 1]
    add [rb + loc_addr_1], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + value]

    # Read the second value
    add [rb + loc_type_2], 0, [rb - 1]
    add [rb + loc_addr_2], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the second value to first location
    add [rb + loc_type_1], 0, [rb - 1]
    add [rb + loc_addr_1], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b() -> param3
    arb -3
    call write_location_b

    # Write the first value to second location
    add [rb + loc_type_2], 0, [rb - 1]
    add [rb + loc_addr_2], 0, [rb - 2]
    add [rb + value], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 1
    ret 4
.ENDFRAME

##########
execute_xchg_w:
.FRAME loc_type_1, loc_addr_1, loc_type_2, loc_addr_2; value_lo, value_hi
    arb -2

    # Read the first value
    add [rb + loc_type_1], 0, [rb - 1]
    add [rb + loc_addr_1], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Read the second value
    add [rb + loc_type_2], 0, [rb - 1]
    add [rb + loc_addr_2], 0, [rb - 2]
    arb -2
    call read_location_w

    # Write the second value to first location
    add [rb + loc_type_1], 0, [rb - 1]
    add [rb + loc_addr_1], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_w().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_w().hi -> param4
    arb -4
    call write_location_w

    # Write the first value to second location
    add [rb + loc_type_2], 0, [rb - 1]
    add [rb + loc_addr_2], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 2
    ret 4
.ENDFRAME

##########
execute_xchg_ax_w:
.FRAME loc_type, loc_addr

    # Exchange AX with location
    add 0, 0, [rb - 1]
    add reg_ax + 0, 0, [rb - 2]
    add [rb + loc_type], 0, [rb - 3]
    add [rb + loc_addr], 0, [rb - 4]
    arb -4
    call execute_xchg_w

    ret 2
.ENDFRAME

.EOF
