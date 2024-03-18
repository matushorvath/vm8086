.EXPORT execute_mov_b
.EXPORT execute_mov_w

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

##########
execute_mov_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the target value
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

    # Write the target value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_b().hi -> param4
    arb -4
    call write_location_w

    ret 4
.ENDFRAME

.EOF
