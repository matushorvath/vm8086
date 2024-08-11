.EXPORT execute_in_al_immediate_b
.EXPORT execute_in_ax_immediate_b
.EXPORT execute_out_al_immediate_b
.EXPORT execute_out_ax_immediate_b

.EXPORT execute_in_al_dx
.EXPORT execute_in_ax_dx
.EXPORT execute_out_al_dx
.EXPORT execute_out_ax_dx

# From memory.s
.IMPORT read_cs_ip_b

# From ports.s
.IMPORT handle_port_read
.IMPORT handle_port_write

# From state.s
.IMPORT reg_al
.IMPORT reg_ax
.IMPORT reg_dx
.IMPORT inc_ip_b

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
    add 0, 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_al]

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
    add 0, 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_ax + 0]

    # Increment the port with wrap around
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port], -0x100, [rb + port]

.after_inc:
    add [rb + port], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_ax + 1]

    arb 2
    ret 0
.ENDFRAME

##########
execute_in_al_dx:
.FRAME
    # Input 8-bit value from the 16-bit port in DX to AL
    add [reg_dx + 0], 0, [rb - 1]
    add [reg_dx + 1], 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_al]

    ret 0
.ENDFRAME

##########
execute_in_ax_dx:
.FRAME port_lo, port_hi, tmp
    arb -3

    # Read 16-bit port number from DX
    add [reg_dx + 0], 0, [rb + port_lo]
    add [reg_dx + 1], 0, [rb + port_hi]

    # Input 16-bit value from two consecutive ports to AX
    add [rb + port_lo], 0, [rb - 1]
    add [rb + port_hi], 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_ax + 0]

    # Increment the port with wrap around
    add [rb + port_lo], 1, [rb + port_lo]

    lt  [rb + port_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port_lo], -0x100, [rb + port_lo]
    add [rb + port_hi], 1, [rb + port_hi]

    lt  [rb + port_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port_hi], -0x100, [rb + port_hi]

.after_inc:
    add [rb + port_lo], 0, [rb - 1]
    add [rb + port_hi], 0, [rb - 2]
    arb -2
    call handle_port_read
    add [rb - 4], 0, [reg_ax + 1]

    arb 3
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
    add 0, 0, [rb - 2]
    add [reg_al], 0, [rb - 3]
    arb -3
    call handle_port_write

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
    add 0, 0, [rb - 2]
    add [reg_ax + 0], 0, [rb - 3]
    arb -3
    call handle_port_write

    # Increment the port with wrap around
    add [rb + port], 1, [rb + port]

    lt  [rb + port], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port], -0x100, [rb + port]

.after_inc:
    add [rb + port], 0, [rb - 1]
    add 0, 0, [rb - 2]
    add [reg_ax + 1], 0, [rb - 3]
    arb -3
    call handle_port_write

    arb 2
    ret 0
.ENDFRAME

##########
execute_out_al_dx:
.FRAME
    # Output 8-bit value from AL to the 16-bit port in DX
    add [reg_dx + 0], 0, [rb - 1]
    add [reg_dx + 1], 0, [rb - 2]
    add [reg_al], 0, [rb - 3]
    arb -3
    call handle_port_write

    ret 0
.ENDFRAME

##########
execute_out_ax_dx:
.FRAME port_lo, port_hi, tmp
    arb -3

    # Read 16-bit port number from DX
    add [reg_dx + 0], 0, [rb + port_lo]
    add [reg_dx + 1], 0, [rb + port_hi]

    # Output 16-bit value from AX to two consecutive ports
    add [rb + port_lo], 0, [rb - 1]
    add [rb + port_hi], 0, [rb - 2]
    add [reg_ax + 0], 0, [rb - 3]
    arb -3
    call handle_port_write

    # Increment the port with wrap around
    add [rb + port_lo], 1, [rb + port_lo]

    lt  [rb + port_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port_lo], -0x100, [rb + port_lo]
    add [rb + port_hi], 1, [rb + port_hi]

    lt  [rb + port_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_inc

    add [rb + port_hi], -0x100, [rb + port_hi]

.after_inc:
    add [rb + port_lo], 0, [rb - 1]
    add [rb + port_hi], 0, [rb - 2]
    add [reg_ax + 1], 0, [rb - 3]
    arb -3
    call handle_port_write

    arb 3
    ret 0
.ENDFRAME

.EOF
