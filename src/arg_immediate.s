.EXPORT arg_immediate_b
# TODO .EXPORT arg_immediate_w

# From memory.s
.IMPORT calc_addr

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip

# The argument is 8-bit or 16-bit data that follows the opcode.
# We return the 8086 physical address of the data.

##########
arg_immediate_b:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [reg_ip + 1], 0x100, [rb - 2]
    add [reg_ip + 0], [rb - 2], [rb - 2]
    arb -2
    call calc_addr

    add 1, 0, [rb + loc_type]
    add [rb - 2], 0, [rb + loc_addr]

    call inc_ip

    arb 2
    ret 0
.ENDFRAME

.EOF
