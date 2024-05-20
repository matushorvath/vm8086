.EXPORT execute_in_al_immediate_b
.EXPORT execute_in_ax_immediate_b
.EXPORT execute_out_al_immediate_b
.EXPORT execute_out_ax_immediate_b

.EXPORT execute_in_al_dx
.EXPORT execute_in_ax_dx
.EXPORT execute_out_al_dx
.EXPORT execute_out_ax_dx

# From the config file
.IMPORT config_io_port_debugging

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT reg_al
.IMPORT reg_ax
.IMPORT reg_dx
.IMPORT inc_ip_b

# From test_api.s
.IMPORT dump_dx
.IMPORT dump_state
.IMPORT handle_shutdown_api
.IMPORT mark
.IMPORT print_char

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

.SYMBOL DUMP_STATE_PORT                 0x42

# The port to access is either the immediate parameter (8-bit) or DX (16-bit).
# The data to send/receive is in either AL (8-bit) or AX (16-bit).
# All combinations of these are possible.

##########
execute_in_al_immediate_b:
.FRAME port
    arb -1

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip_b

    # Input 8-bit value from the port to AL
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_al]

    arb 1
    ret 0
.ENDFRAME

##########
execute_in_ax_immediate_b:
.FRAME port, tmp
    arb -2

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip_b

    # Input 16-bit value from two consecutive ports to AX
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_ax + 0]

    # Increment the port with wrap around
    # TODO HW Does real hardware wrap around to 8 bits here?
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_in_ax_immediate_b_no_overflow

    add [rb + port], -0x100, [rb + port]

execute_in_ax_immediate_b_no_overflow:
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_ax + 1]

    arb 2
    ret 0
.ENDFRAME

##########
execute_in_al_dx:
.FRAME port
    arb -1

    # Read 16-bit port number from DX
    mul [reg_dx + 1], 0x100, [rb + port]
    add [reg_dx + 0], [rb + port], [rb + port]

    # Input 8-bit value from the port to AL
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_al]

    arb 1
    ret 0
.ENDFRAME

##########
execute_in_ax_dx:
.FRAME port, tmp
    arb -2

    # Read 16-bit port number from DX
    mul [reg_dx + 1], 0x100, [rb + port]
    add [reg_dx + 0], [rb + port], [rb + port]

    # Input 16-bit value from two consecutive ports to AX
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_ax + 0]

    # Increment the port with wrap around
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x10000, [rb + tmp]
    jnz [rb + tmp], execute_in_ax_dx_no_overflow

    add [rb + port], -0x10000, [rb + port]

execute_in_ax_dx_no_overflow:
    add [rb + port], 0, [rb - 1]
    arb -1
    call port_in
    add [rb - 3], 0, [reg_ax + 1]

    arb 2
    ret 0
.ENDFRAME

##########
execute_out_al_immediate_b:
.FRAME port
    arb -1

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip_b

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
.FRAME port, tmp
    arb -2

    # Read 8-bit port number from the immediate parameter
    call read_cs_ip_b
    add [rb - 2], 0, [rb + port]
    call inc_ip_b

    # Output 16-bit value from AX to two consecutive ports
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 0], 0, [rb - 2]
    arb -2
    call port_out

    # Increment the port with wrap around
    # TODO HW Does real hardware wrap around to 8 bits here?
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_out_ax_immediate_b_no_overflow

    add [rb + port], -0x100, [rb + port]

execute_out_ax_immediate_b_no_overflow:
    add [rb + port], 0, [rb - 1]
    add [reg_ax + 1], 0, [rb - 2]
    arb -2
    call port_out

    arb 2
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
port_in:
.FRAME port; value                                          # returns values
    arb -1

    # Input a constant for unmapped ports
    add 0xff, 0, [rb + value]

    # Is I/O port debugging on?
    jz  [config_io_port_debugging], port_in_done

    # Output port number to stdout
    add port_in_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

port_in_done:
    arb 1
    ret 1
.ENDFRAME

##########
port_out:
.FRAME port, value; tmp
    arb -1

    # Is I/O port debugging on?
    jz  [config_io_port_debugging], port_out_done

    # Port 0x42 is used to dump VM state to stdout, for tests
    eq  [rb + port], 0x42, [rb + tmp]
    jnz [rb + tmp], port_out_dump_state

    # Port 0x43 is used to output a mark to stdout, for tests
    eq  [rb + port], 0x43, [rb + tmp]
    jnz [rb + tmp], port_out_mark

    # Port 0x44 is used to output the DX register to stdout, for tests
    eq  [rb + port], 0x44, [rb + tmp]
    jnz [rb + tmp], port_out_dump_dx

    # Port 0xe9 is a bochs API to output a character to console, used for debugging
    eq  [rb + port], 0xe9, [rb + tmp]
    jnz [rb + tmp], port_out_print_char

    # Port 0x8900 is a bochs API to shutdown the computer, used by tests
    eq  [rb + port], 0x8900, [rb + tmp]
    jnz [rb + tmp], port_out_shutdown

    # Output the port and value to stdout
    add port_out_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    add port_out_message_separator, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
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
    jz  0, port_out_done

port_out_print_char:
    call print_char
    jz  0, port_out_done

port_out_shutdown:
    add [rb + value], 0, [rb - 1]
    arb -1
    call handle_shutdown_api

port_out_done:
    arb 1
    ret 2

port_in_message_start:
    db  "IN port 0x", 0
port_out_message_start:
    db  "OUT port 0x", 0
port_out_message_separator:
    db  ": 0x", 0
.ENDFRAME

.EOF
