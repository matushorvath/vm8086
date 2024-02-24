.EXPORT execute_lda
.EXPORT execute_ldx
.EXPORT execute_ldy

.EXPORT execute_sta
.EXPORT execute_stx
.EXPORT execute_sty

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_a
.IMPORT reg_x
.IMPORT reg_y

##########
execute_lda:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_a]

    lt  127, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 0
    ret 1
.ENDFRAME

##########
execute_ldx:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_x]

    lt  127, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    arb 0
    ret 1
.ENDFRAME

##########
execute_ldy:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_y]

    lt  127, [reg_y], [flag_negative]
    eq  [reg_y], 0, [flag_zero]

    arb 0
    ret 1
.ENDFRAME

##########
execute_sta:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    add [reg_a], 0, [rb - 2]
    arb -2
    call write

    arb 0
    ret 1
.ENDFRAME

##########
execute_stx:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    add [reg_x], 0, [rb - 2]
    arb -2
    call write

    arb 0
    ret 1
.ENDFRAME

##########
execute_sty:
.FRAME addr;
    arb -0

    add [rb + addr], 0, [rb - 1]
    add [reg_y], 0, [rb - 2]
    arb -2
    call write

    arb 0
    ret 1
.ENDFRAME

.EOF

execute_tax
execute_tay
execute_tsx
execute_txa
execute_tya
