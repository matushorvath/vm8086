.EXPORT execute_inc
.EXPORT execute_inx
.EXPORT execute_iny

.EXPORT execute_dec
.EXPORT execute_dex
.EXPORT execute_dey

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_x
.IMPORT reg_y

# From util.s
.IMPORT mod_8bit

##########
.FRAME addr; delta
execute_inc:
    arb -1
    add 1, 0, [rb + delta]

    jz 0, execute_inc_dec_generic

execute_dec:
    arb -1
    add -1, 0, [rb + delta]

execute_inc_dec_generic:
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read

    add [rb - 3], [rb + delta], [rb - 1]            # read() + delte -> param0
    arb -1
    call mod_8bit

    lt  127, [rb - 3], [flag_negative]
    eq  [rb - 3], 0, [flag_zero]

    add [rb + addr], 0, [rb - 1]
    add [rb - 3], 0, [rb - 2]                       # mod_8bit() -> param1
    arb -2
    call write

    arb 1
    ret 1
.ENDFRAME

##########
execute_inx:
.FRAME
    add [reg_x], 1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_x]

    lt  127, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_iny:
.FRAME
    add [reg_y], 1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_y]

    lt  127, [reg_y], [flag_negative]
    eq  [reg_y], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_dex:
.FRAME
    add [reg_x], -1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_x]

    lt  127, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_dey:
.FRAME
    add [reg_y], -1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_y]

    lt  127, [reg_y], [flag_negative]
    eq  [reg_y], 0, [flag_zero]

    ret 0
.ENDFRAME

.EOF
