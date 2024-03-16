.EXPORT arg_reg_ax
.EXPORT arg_reg_cx
.EXPORT arg_reg_dx
.EXPORT arg_reg_bx
.EXPORT arg_reg_sp
.EXPORT arg_reg_bp
.EXPORT arg_reg_si
.EXPORT arg_reg_di

# From state.s
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx
.IMPORT reg_sp
.IMPORT reg_bp
.IMPORT reg_si
.IMPORT reg_di

# The argument is a fixed 16-bit register (encoded as part of the opcode).
# We return address of the first byte of the register.

##########
arg_reg_ax:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_ax + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_bx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_bx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_cx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_cx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_dx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_dx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_sp:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_sp + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_bp:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_bp + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_si:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_si + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_reg_di:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_di + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

.EOF
