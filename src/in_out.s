# TODO .EXPORT execute_in_al_immediate_b
# TODO .EXPORT execute_in_ax_immediate_b
.EXPORT execute_out_al_immediate_b
.EXPORT execute_out_ax_immediate_b

# TODO .EXPORT execute_in_al_dx
# TODO .EXPORT execute_in_ax_dx
.EXPORT execute_out_al_dx
.EXPORT execute_out_ax_dx

# From dump_state.s
.IMPORT dump_state
.IMPORT mark
.IMPORT dump_dx

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

.SYMBOL DUMP_STATE_PORT                 0x42

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

    # TODO HW If the first port is 0xff, should the second port be 0x100 or overflow to 0x00?
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
.FRAME port, tmp
    arb -2

    # Read 16-bit port number from DX
    mul [reg_dx + 1], 0x100, [rb + port]
    add [reg_dx + 0], [rb + port], [rb + port]

    # Output 16-bit value from AX to two consecutive ports
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 0], 0, [rb - 2]
    arb -2
    call port_out

    # Increment the port with wrap around
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x10000, [rb + tmp]
    jnz [rb + tmp], execute_out_ax_dx_no_overflow

    add [rb + port], -0x10000, [rb + port]

execute_out_ax_dx_no_overflow:
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 1], 0, [rb - 2]
    arb -2
    call port_out

    arb 2
    ret 0
.ENDFRAME

##########
port_out:
.FRAME port, value; tmp
    arb -1

    # Port 0x42 is used to dump VM state to stdout, for tests
    eq  [rb + port], 0x42, [rb + tmp]
    jnz [rb + tmp], port_out_dump_state

    # Port 0x43 is used to output a mark to stdout, for tests
    eq  [rb + port], 0x43, [rb + tmp]
    jnz [rb + tmp], port_out_mark

    # Port 0x43 is used to output the DX register to stdout, for tests
    eq  [rb + port], 0x44, [rb + tmp]
    jnz [rb + tmp], port_out_dump_dx

    # Output the port and value to stdout
    # TODO remove temporary I/O code

    add port_out_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add port_out_message_separator, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    jz  0, port_out_done

port_out_dump_state:
    call dump_state
    jz  0, port_out_done

port_out_mark:
    add [rb + value], 0, [rb - 1]
    arb -1
    call mark

    jz  0, port_out_done

port_out_dump_dx:
    call dump_dx

port_out_done:
    arb 1
    ret 2

port_out_message_start:
    db  "port 0x", 0
port_out_message_separator:
    db  ": 0x", 0
.ENDFRAME

.EOF
