.EXPORT execute_lda
.EXPORT execute_ldx
.EXPORT execute_ldy

.EXPORT execute_sta
.EXPORT execute_stx
.EXPORT execute_sty

.EXPORT execute_tax
.EXPORT execute_tay
.EXPORT execute_txa
.EXPORT execute_tya
.EXPORT execute_txs
.EXPORT execute_tsx

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_sp
.IMPORT reg_a
.IMPORT reg_x
.IMPORT reg_y

##########
execute_lda:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_a]

    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    ret 1
.ENDFRAME

##########
execute_ldx:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_x]

    lt  0x7f, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    ret 1
.ENDFRAME

##########
execute_ldy:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [reg_y]

    lt  0x7f, [reg_y], [flag_negative]
    eq  [reg_y], 0, [flag_zero]

    ret 1
.ENDFRAME

##########
execute_sta:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    add [reg_a], 0, [rb - 2]
    arb -2
    call write

    ret 1
.ENDFRAME

##########
execute_stx:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    add [reg_x], 0, [rb - 2]
    arb -2
    call write

    ret 1
.ENDFRAME

##########
execute_sty:
.FRAME addr;
    add [rb + addr], 0, [rb - 1]
    add [reg_y], 0, [rb - 2]
    arb -2
    call write

    ret 1
.ENDFRAME

##########
execute_tax:
.FRAME
    add [reg_a], 0, [reg_x]

    lt  0x7f, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_tay:
.FRAME
    add [reg_a], 0, [reg_y]

    lt  0x7f, [reg_y], [flag_negative]
    eq  [reg_y], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_txa:
.FRAME
    add [reg_x], 0, [reg_a]

    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_tya:
.FRAME
    add [reg_y], 0, [reg_a]

    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    ret 0
.ENDFRAME

##########
execute_txs:
.FRAME
    add [reg_x], 0, [reg_sp]

    ret 0
.ENDFRAME

##########
execute_tsx:
.FRAME
    add [reg_sp], 0, [reg_x]

    lt  0x7f, [reg_x], [flag_negative]
    eq  [reg_x], 0, [flag_zero]

    ret 0
.ENDFRAME

.EOF
