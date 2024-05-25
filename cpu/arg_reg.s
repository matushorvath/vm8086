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
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_ax + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_bx:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_bx + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_cx:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_cx + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_dx:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_dx + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_sp:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_sp + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_bp:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_bp + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_si:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_si + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_di:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_di + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_cs:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_cs + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_ds:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_ds + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_ss:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_ss + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

##########
arg_es:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    add 0x10000, 0, [rb + lseg]
    add reg_es + 0, 0, [rb + loff]

    arb 2
    ret 0
.ENDFRAME

.EOF
