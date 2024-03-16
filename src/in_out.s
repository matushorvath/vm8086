# TODO .EXPORT execute_in_b
# TODO .EXPORT execute_in_w
# TODO .EXPORT execute_out_b
.EXPORT execute_out_w

# From memory.s
.IMPORT read_location_w

# From state.s
.IMPORT reg_ax

# TODO remove temporary I/O code
.IMPORT print_num_radix

##########
execute_out_w:
.FRAME loc_type, loc_addr; value_lo, value_hi
    arb -2

    # TODO read and use the port (from loc_type/loc_addr)

    # Read the value
    # TODO the port can be 8-bit or 16-bit - we don't handle that
#    add [rb + loc_type], 0, [rb - 1]
#    add [rb + loc_addr], 0, [rb - 2]
#    arb -2
#    call read_location_w
#    add [rb - 4], 0, [rb + port_lo]
#    add [rb - 5], 0, [rb + port_hi]

    # Output the 16-bit AX value
    # TODO remove temporary I/O code
    mul [reg_ax + 1], 0x100, [rb - 1]
    add [reg_ax + 0], [rb - 1], [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    out 10

    arb 2
    ret 2
.ENDFRAME

.EOF
