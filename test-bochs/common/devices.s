.EXPORT register_devices

# From bochs_api.s
.IMPORT bochs_shutdown
.IMPORT bochs_out_char

# From dump_state.s
.IMPORT dump_state

# From test_api.s
.IMPORT port_in_debug
.IMPORT port_out_debug
.IMPORT print_mark

# From cpu/ports.s
.IMPORT register_ports

##########
ports:
    # Debug output for ports used in the in_out test
    db  0x00, 0x00, port_in_debug, port_out_debug
    db  0xcd, 0x00, port_in_debug, port_out_debug
    db  0xef, 0x00, port_in_debug, port_out_debug
    db  0xf0, 0x00, port_in_debug, port_out_debug
    db  0xff, 0x00, port_in_debug, port_out_debug
    db  0x34, 0x12, port_in_debug, port_out_debug
    db  0x98, 0xba, port_in_debug, port_out_debug
    db  0x99, 0xba, port_in_debug, port_out_debug
    db  0xff, 0xff, port_in_debug, port_out_debug

    db  0x42, 0x00, 0, dump_state                           # dump VM state to stdout
    db  0x43, 0x00, 0, print_mark                           # output a mark to stdout

    db  0xe9, 0x00, 0, bochs_out_char                       # bochs API to output a character to console
    db  0x00, 0x89, 0, bochs_shutdown                       # bochs API to shutdown the computer

    db  -1, -1, -1, -1

##########
register_devices:
.FRAME
    add ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

.EOF
