.EXPORT execute_clc
.EXPORT execute_cld
.EXPORT execute_cli
.EXPORT execute_clv

.EXPORT execute_sec
.EXPORT execute_sed
.EXPORT execute_sei

# From state.s
.IMPORT flag_overflow
.IMPORT flag_decimal
.IMPORT flag_interrupt
.IMPORT flag_carry

##########
execute_clc:
.FRAME
    add 0, 0, [flag_carry]
    ret 0
.ENDFRAME

##########
execute_cld:
.FRAME
    add 0, 0, [flag_decimal]
    ret 0
.ENDFRAME

##########
execute_cli:
.FRAME
    add 0, 0, [flag_interrupt]
    ret 0
.ENDFRAME

##########
execute_clv:
.FRAME
    add 0, 0, [flag_overflow]
    ret 0
.ENDFRAME

##########
execute_sec:
.FRAME
    add 1, 0, [flag_carry]
    ret 0
.ENDFRAME

##########
execute_sed:
.FRAME
    add 1, 0, [flag_decimal]
    ret 0
.ENDFRAME

##########
execute_sei:
.FRAME
    add 1, 0, [flag_interrupt]
    ret 0
.ENDFRAME

.EOF
