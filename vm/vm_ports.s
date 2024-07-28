.EXPORT init_vm_ports

# From cpu/ports.s
.IMPORT register_ports

# From cga/status_bar.s
.IMPORT post_status_write

##########
vm_ports:
    db  0x80, 0x00, 0, post_status_write                                        # POST status port

    db  -1, -1, -1, -1

##########
init_vm_ports:
.FRAME
    # Register I/O ports
    add vm_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

.EOF
