.EXPORT init_shutdown_port

# From cpu/devices.s
.IMPORT register_port

# From cpu/execute.s
.IMPORT halt

# From libxib.a
.IMPORT print_str

##########
init_shutdown_port:
.FRAME
    add 0x42, 0, [rb - 1]
    add 0x00, 0, [rb - 2]
    add 0, 0, [rb - 3]
    add write_shutdown_port, 0, [rb - 4]
    arb -4
    call register_port

    ret 0
.ENDFRAME

##########
write_shutdown_port:
.FRAME port, value; tmp
    arb -1

    # OUT 0x42, 0x24 will shutdown the VM

    # Is the value 0x24?
    eq  [rb + value], 0x24, [rb + tmp]
    jz  [rb + tmp], .done

    # Yes, print a message and shutdown
    add .message, 0, [rb - 1]
    arb -1
    call print_str

    add 1, 0, [halt]

.done:
    arb 1
    ret 2

.message:
    db  "Shutting down", 10, 0
.ENDFRAME

.EOF
