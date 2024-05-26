.EXPORT register_devices

# From bochs_api.s
.IMPORT bochs_shutdown
.IMPORT bochs_out_char

# From devices.s
.IMPORT register_port

# From dump_state.s
.IMPORT dump_state

# From test_api.s
.IMPORT port_in_debug
.IMPORT port_out_debug
.IMPORT print_mark

##########
data:
    # Debug output for ports used in the in_out test
    db  0x00, 0x00, port_in_debug, port_out_debug
    db  0x00, 0xcd, port_in_debug, port_out_debug
    db  0x00, 0xef, port_in_debug, port_out_debug
    db  0x00, 0xf0, port_in_debug, port_out_debug
    db  0x00, 0xff, port_in_debug, port_out_debug
    db  0x12, 0x34, port_in_debug, port_out_debug
    db  0xba, 0x98, port_in_debug, port_out_debug
    db  0xba, 0x99, port_in_debug, port_out_debug
    db  0xff, 0xff, port_in_debug, port_out_debug

    db  0x00, 0x42, 0, dump_state                           # dump VM state to stdout
    db  0x00, 0x43, 0, print_mark                           # output a mark to stdout

    db  0x00, 0xe9, 0, bochs_out_char                       # bochs API to output a character to console
    db  0x89, 0x00, 0, bochs_shutdown                       # bochs API to shutdown the computer

    db  -1, -1, -1, -1

##########
register_devices:
.FRAME record, tmp
    arb -2

    add data, 0, [rb + record]

register_devices_loop:
    # Load next data record and register the port
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb - 2]

    eq  [rb - 2], -1, [rb + tmp]
    jnz [rb + tmp], register_devices_done

    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb - 1]
    add [rb + record], 2, [ip + 1]
    add [0], 0, [rb - 3]
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb - 4]

    arb -4
    call register_port

    add [rb + record], 4, [rb + record]

    jz  0, register_devices_loop

register_devices_done:
    arb 2
    ret 0
.ENDFRAME

.EOF
