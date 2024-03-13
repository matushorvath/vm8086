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
.FRAME addr                             # addr is returned
arg_reg_ax:
    arb -1

    add reg_ax, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_bx:
    arb -1

    add reg_bx, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_cx:
    arb -1

    add reg_cx, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_dx:
    arb -1

    add reg_dx, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_sp:
    arb -1

    add reg_sp, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_bp:
    arb -1

    add reg_bp, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_si:
    arb -1

    add reg_si, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr                             # addr is returned
arg_reg_di:
    arb -1

    add reg_di, 0, [rb + addr]

    arb 1
    ret 0
.ENDFRAME

.EOF
