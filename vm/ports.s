.EXPORT init_ports

# From devices.s
.IMPORT register_ports

# From libxib.a
.IMPORT print_str
.IMPORT print_num_radix

##########
ports:
    db  0x80, 0x00, 0, post_status_write                                        # POST status port

    db  -1, -1, -1, -1

##########
init_ports:
.FRAME
    # Register I/O ports
    add ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
post_status_write:
.FRAME port, value;
    add post_status_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2

post_status_message:
    db  "POST status: ", 0
.ENDFRAME

.EOF
