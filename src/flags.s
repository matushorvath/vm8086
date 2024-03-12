.EXPORT execute_clc
.EXPORT execute_stc
.EXPORT execute_cmc

.EXPORT execute_cld
.EXPORT execute_std

.EXPORT execute_cli
.EXPORT execute_sti

# From state.s
.IMPORT flag_carry
.IMPORT flag_direction
.IMPORT flag_interrupt

##########
execute_clc:
.FRAME
    add 0, 0, [flag_carry]
    ret 0
.ENDFRAME

##########
execute_stc:
.FRAME
    add 1, 0, [flag_carry]
    ret 0
.ENDFRAME

##########
execute_cmc:
.FRAME
    eq  [flag_carry], 0, [flag_carry]
    ret 0
.ENDFRAME

##########
execute_cld:
.FRAME
    add 0, 0, [flag_direction]
    ret 0
.ENDFRAME

##########
execute_std:
.FRAME
    add 1, 0, [flag_direction]
    ret 0
.ENDFRAME

##########
execute_cli:
.FRAME
    add 0, 0, [flag_interrupt]
    ret 0
.ENDFRAME

##########
execute_sti:
.FRAME
    add 1, 0, [flag_interrupt]
    ret 0
.ENDFRAME

.EOF
