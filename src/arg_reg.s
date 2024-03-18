.EXPORT arg_ax
.EXPORT arg_cx
.EXPORT arg_dx
.EXPORT arg_bx
.EXPORT arg_sp
.EXPORT arg_bp
.EXPORT arg_si
.EXPORT arg_di
.EXPORT arg_cs
.EXPORT arg_ds
.EXPORT arg_ss
.EXPORT arg_es

# From state.s
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx
.IMPORT reg_sp
.IMPORT reg_bp
.IMPORT reg_si
.IMPORT reg_di
.IMPORT reg_cs
.IMPORT reg_ds
.IMPORT reg_ss
.IMPORT reg_es

# The argument is a fixed 16-bit register (encoded as part of the opcode).
# We return the intcode address of the first byte of the register.

##########
arg_ax:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_ax + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_bx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_bx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_cx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_cx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_dx:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_dx + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_sp:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_sp + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_bp:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_bp + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_si:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_si + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_di:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_di + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_cs:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_cs + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_ds:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_ds + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_ss:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_ss + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

##########
arg_es:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 0, 0, [rb + loc_type]
    add reg_es + 0, 0, [rb + loc_addr]

    arb 2
    ret 0
.ENDFRAME

.EOF
