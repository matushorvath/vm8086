.EXPORT execute_php
.EXPORT execute_plp
.EXPORT execute_pha
.EXPORT execute_pla

# From memory.s
.IMPORT pop
.IMPORT push

# From state.s
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_a
.IMPORT pack_sr
.IMPORT unpack_sr

##########
execute_php:
.FRAME
    # Pack sr and push it
    call pack_sr
    add [rb - 2], 0, [rb - 1]
    arb -1
    call push

    ret 0
.ENDFRAME

##########
execute_plp:
.FRAME
    # Pull sr and unpack it into flags_*
    call pop
    add [rb - 2], 0, [rb - 1]
    arb -1
    call unpack_sr

    ret 0
.ENDFRAME

##########
execute_pha:
.FRAME
    # Push reg_a
    add [reg_a], 0, [rb - 1]
    arb -1
    call push

    ret 0
.ENDFRAME

##########
execute_pla:
.FRAME
    # Pull reg_a
    call pop
    add [rb - 2], 0, [reg_a]

    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    ret 0
.ENDFRAME

.EOF
