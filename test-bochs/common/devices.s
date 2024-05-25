.EXPORT device_interrupts
.EXPORT device_ports
.EXPORT device_regions

# From bochs_api.s
.IMPORT bochs_shutdown
.IMPORT bochs_out_char

# From dump_state.s
.IMPORT dump_state

# From test_api.s
.IMPORT port_in_debug
.IMPORT port_out_debug
.IMPORT print_mark

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
    db  0, print_mark                   # 0x0043 output a mark to stdout

    ds  0x89, 0
    ds  0x89, 0

    db  port_in_debug, port_out_debug   # 0x00cd used by tests

    ds  0x1b, 0
    ds  0x1b, 0

    db  0, bochs_out_char               # 0x00e9 bochs API to output a character to console

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
    db 0, bochs_shutdown                # 0x8900 bochs API to shutdown the computer

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

.EOF
