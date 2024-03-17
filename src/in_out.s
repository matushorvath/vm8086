# TODO .EXPORT execute_in_al_immediate_b
# TODO .EXPORT execute_in_ax_immediate_b
.EXPORT execute_out_al_immediate_b
.EXPORT execute_out_ax_immediate_b

# TODO .EXPORT execute_in_al_dx
# TODO .EXPORT execute_in_ax_dx
.EXPORT execute_out_al_dx
.EXPORT execute_out_ax_dx

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT reg_al
.IMPORT reg_ax
.IMPORT reg_dx
.IMPORT inc_ip

# TODO remove temporary I/O code
.IMPORT print_num_radix
.IMPORT print_str

# The port to access is either the immediate parameter (8-bit) or DX (16-bit).
# The data to send/receive is in either AL (8-bit) or AX (16-bit).
# All combinations of these are possible.

##########
execute_out_al_immediate_b:
.FRAME port
    arb -1

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip

    # Output 8-bit value from AL to the port
    add [rb + port], 0, [rb - 1]
    add [reg_al], 0, [rb - 2]
    arb -2
    call port_out

    arb 1
    ret 0
.ENDFRAME

##########
execute_out_ax_immediate_b:
.FRAME port
    arb -1

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip

    # Output 16-bit value from AX to two consecutive ports
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 0], 0, [rb - 2]
    arb -2
    call port_out

    add [rb + port], 1, [rb - 1]
    add [reg_ax + 1], 0, [rb - 2]
    arb -2
    call port_out

    arb 1
    ret 0
.ENDFRAME

##########
execute_out_al_dx:
.FRAME port
    arb -1

    # Read 16-bit port number from DX
    mul [reg_dx + 1], 0x100, [rb + port]
    add [reg_dx + 0], [rb + port], [rb + port]

    # Output 8-bit value from AL to the port
    add [rb + port], 0, [rb - 1]
    add [reg_al], 0, [rb - 2]
    arb -2
    call port_out

    arb 1
    ret 0
.ENDFRAME

##########
execute_out_ax_dx:
.FRAME port
    arb -1

    # Read 16-bit port number from DX
    mul [reg_dx + 1], 0x100, [rb + port]
    add [reg_dx + 0], [rb + port], [rb + port]

    # Output 16-bit value from AX to two consecutive ports
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 0], 0, [rb - 2]
    arb -2
    call port_out

    add [rb + port], 1, [rb - 1]
    add [reg_ax + 1], 0, [rb - 2]
    arb -2
    call port_out

    arb 1
    ret 0
.ENDFRAME

##########
port_out:
.FRAME port, value;
    # Output the port and value to stdout
    # TODO remove temporary I/O code

    add out_port_b_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    add out_port_b_message_separator, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    out 10

    ret 2

out_port_b_message_start:
    db  "port 0x", 0
out_port_b_message_separator:
    db  ": 0x", 0
.ENDFRAME

.EOF
