.EXPORT init_ps2_8042

# From cpu/execute.s
.IMPORT halt

# From cpu/ports.s
.IMPORT register_ports

# From libxib.a
.IMPORT print_str

# The 8042 PS/2 Controller wasn't included in the IBM PC/XT
# It's only supported partially, as an API to reset the CPU, which will cleanly shut down the VM

##########
ps2_ports:
    db  0x64, 0x00, 0, ps2_command_write                    # Command register

    db  -1, -1, -1, -1

##########
init_ps2_8042:
.FRAME
    # Register I/O ports
    add ps2_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
ps2_command_write:
.FRAME addr, value; tmp
    arb -1

    # We only support pulsing output line 0 (CPU reset)
    eq  [rb + value], 0xfe, [rb + tmp]
    jz  [rb + tmp], .done

    add .reboot_msg, 0, [rb - 1]
    arb -1
    call print_str

    # Instead of just resetting, shut down the VM
    add 1, 0, [halt]

.done:
    arb 1
    ret 2

.reboot_msg:
    db  10, 13, "vm8086: software triggered reboot, shutting down", 10, 13, 10, 13, 0
.ENDFRAME

.EOF
