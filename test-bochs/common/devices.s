.EXPORT device_interrupts
.EXPORT device_ports
.EXPORT device_regions

# From test_api.s
.IMPORT dump_dx
.IMPORT dump_state
.IMPORT handle_shutdown_api
.IMPORT mark
.IMPORT print_char

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

device_interrupts:
    db  0
device_ports:
    db  device_ports_table
device_regions:
    db  0

# Custom handling for selected I/O ports that are used in the tests
device_ports_table:
    db  device_ports_00
    ds  0x11, 0
    db  device_ports_12
    ds  0x76, 0
    db  device_ports_89
    ds  0x30, 0
    db  device_ports_ba
    ds  0x44, 0
    db  device_ports_ff

device_ports_00:
    db  port_in_debug, port_out_debug   # 0x0000 used by tests

    ds  0x41, 0
    ds  0x41, 0

    db  0, dump_state                   # 0x0042 dump VM state to stdout
    db  0, mark                         # 0x0043 output a mark to stdout
    db  0, dump_dx                      # 0x0044 output the DX register to stdout   # TODO probably unused, remove

    ds  0x88, 0
    ds  0x88, 0

    db  port_in_debug, port_out_debug   # 0x00cd used by tests

    ds  0x1b, 0
    ds  0x1b, 0

    db  0, print_char                   # 0x00e9 bochs API to output a character to console

    ds  0x05, 0
    ds  0x05, 0

    db  port_in_debug, port_out_debug   # 0x00ef used by tests
    db  port_in_debug, port_out_debug   # 0x00f0 used by tests

    ds  0x0e, 0
    ds  0x0e, 0

    db  port_in_debug, port_out_debug   # 0x00ff used by tests

device_ports_12:
    ds  0x34, 0
    ds  0x34, 0

    db  port_in_debug, port_out_debug   # 0x1234 used by tests

    ds 0xcb, 0
    ds 0xcb, 0

device_ports_89:
    db 0, handle_shutdown_api           # 0x8900 bochs API to shutdown the computer

    ds 0xff, 0
    ds 0xff, 0

device_ports_ba:
    ds  0x98, 0
    ds  0x98, 0

    db  port_in_debug, port_out_debug   # 0xba98 used by tests
    db  port_in_debug, port_out_debug   # 0xba99 used by tests

    ds 0x66, 0
    ds 0x66, 0

device_ports_ff:
    ds  0xff, 0
    ds  0xff, 0

    db  port_in_debug, port_out_debug   # 0xffff used by tests

##########
port_in_debug:
.FRAME port; value                                          # returns value
    arb -1

    # Input a constant for unmapped ports
    add 0xff, 0, [rb + value]

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
port_out_debug:
.FRAME port, value;
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

    ret 2
.ENDFRAME

##########
port_in_message_start:
    db  "IN port 0x", 0
port_out_message_start:
    db  "OUT port 0x", 0
port_out_message_separator:
    db  ": 0x", 0

.EOF
