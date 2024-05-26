.EXPORT execute_clc
.EXPORT execute_stc
.EXPORT execute_cmc

.EXPORT execute_cld
.EXPORT execute_std

.EXPORT execute_cli
.EXPORT execute_sti

.EXPORT execute_lahf
.EXPORT execute_sahf

.EXPORT pack_flags_lo
.EXPORT pack_flags_hi
.EXPORT unpack_flags_lo
.EXPORT unpack_flags_hi

# From the config file
.IMPORT config_flags_as_286

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow
.IMPORT flag_interrupt
.IMPORT flag_direction
.IMPORT flag_trap
.IMPORT reg_ah

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

##########
execute_lahf:
.FRAME
    # Pack the flags into ah
    call pack_flags_lo
    add [rb - 2], 0, [reg_ah]

    ret 0
.ENDFRAME

##########
execute_sahf:
.FRAME
    # Unpack the flags from ah
    add [reg_ah], 0, [rb - 1]
    arb -1
    call unpack_flags_lo

    ret 0
.ENDFRAME

##########
pack_flags_lo:
.FRAME flags_lo                         # returns flags_lo
    arb -1

    add 0, 0, [rb + flags_lo]

    # ----ODIT SZ-A-P-C

    jz  [flag_carry], pack_flags_lo_after_carry
    add [rb + flags_lo], 0b00000001, [rb + flags_lo]
pack_flags_lo_after_carry:

    # set bit 1 to match bochs (which emulates the 32-bit eflags)
    add [rb + flags_lo], 0b00000010, [rb + flags_lo]

    jz  [flag_parity], pack_flags_lo_after_parity
    add [rb + flags_lo], 0b00000100, [rb + flags_lo]
pack_flags_lo_after_parity:

    jz  [flag_auxiliary_carry], pack_flags_lo_after_auxiliary_carry
    add [rb + flags_lo], 0b00010000, [rb + flags_lo]
pack_flags_lo_after_auxiliary_carry:

    jz  [flag_zero], pack_flags_lo_after_zero
    add [rb + flags_lo], 0b01000000, [rb + flags_lo]
pack_flags_lo_after_zero:

    jz  [flag_sign], pack_flags_lo_after_sign
    add [rb + flags_lo], 0b10000000, [rb + flags_lo]
pack_flags_lo_after_sign:

    arb 1
    ret 0
.ENDFRAME

##########
pack_flags_hi:
.FRAME flags_hi                         # returns flags_hi
    arb -1

    add 0, 0, [rb + flags_hi]

    # ----ODIT SZ-A-P-C

    jz  [flag_trap], pack_flags_hi_after_trap
    add [rb + flags_hi], 0b00000001, [rb + flags_hi]
pack_flags_hi_after_trap:

    jz  [flag_interrupt], pack_flags_hi_after_interrupt
    add [rb + flags_hi], 0b00000010, [rb + flags_hi]
pack_flags_hi_after_interrupt:

    jz  [flag_direction], pack_flags_hi_after_direction
    add [rb + flags_hi], 0b00000100, [rb + flags_hi]
pack_flags_hi_after_direction:

    jz  [flag_overflow], pack_flags_hi_after_overflow
    add [rb + flags_hi], 0b00001000, [rb + flags_hi]
pack_flags_hi_after_overflow:

    jnz  [config_flags_as_286], pack_flags_hi_flags_as_286

    # Set bits 12-15 like a real 8086. This does not match bochs, so it's configurable.
    add [rb + flags_hi], 0b11110000, [rb + flags_hi]

pack_flags_hi_flags_as_286:
    arb 1
    ret 0
.ENDFRAME

##########
unpack_flags_lo:
.FRAME flags_lo; tmp
    arb -1

    # ----ODIT SZ-A-P-C

    lt  0b01111111, [rb + flags_lo], [flag_sign]
    jz  [flag_sign], unpack_flags_lo_after_sign
    add [rb + flags_lo], -0b10000000, [rb + flags_lo]
unpack_flags_lo_after_sign:

    lt  0b00111111, [rb + flags_lo], [flag_zero]
    jz  [flag_zero], unpack_flags_lo_after_zero
    add [rb + flags_lo], -0b01000000, [rb + flags_lo]
unpack_flags_lo_after_zero:

    lt  0b00011111, [rb + flags_lo], [rb + tmp]
    jz  [rb + tmp], unpack_flags_lo_after_bit5
    add [rb + flags_lo], -0b00100000, [rb + flags_lo]
unpack_flags_lo_after_bit5:

    lt  0b00001111, [rb + flags_lo], [flag_auxiliary_carry]
    jz  [flag_auxiliary_carry], unpack_flags_lo_after_auxiliary_carry
    add [rb + flags_lo], -0b00010000, [rb + flags_lo]
unpack_flags_lo_after_auxiliary_carry:

    lt  0b00000111, [rb + flags_lo], [rb + tmp]
    jz  [rb + tmp], unpack_flags_lo_after_bit3
    add [rb + flags_lo], -0b00001000, [rb + flags_lo]
unpack_flags_lo_after_bit3:

    lt  0b00000011, [rb + flags_lo], [flag_parity]
    jz  [flag_parity], unpack_flags_lo_after_parity
    add [rb + flags_lo], -0b00000100, [rb + flags_lo]
unpack_flags_lo_after_parity:

    lt  0b00000001, [rb + flags_lo], [rb + tmp]
    jz  [rb + tmp], unpack_flags_lo_after_bit1
    add [rb + flags_lo], -0b00000010, [rb + flags_lo]
unpack_flags_lo_after_bit1:

    lt  0, [rb + flags_lo], [flag_carry]

    arb 1
    ret 1
.ENDFRAME

##########
unpack_flags_hi:
.FRAME flags_hi; tmp
    arb -1

    # ----ODIT SZ-A-P-C

    lt  0b01111111, [rb + flags_hi], [rb + tmp]
    jz  [rb + tmp], unpack_flags_hi_after_bit7
    add [rb + flags_hi], -0b10000000, [rb + flags_hi]
unpack_flags_hi_after_bit7:

    lt  0b00111111, [rb + flags_hi], [rb + tmp]
    jz  [rb + tmp], unpack_flags_hi_after_bit6
    add [rb + flags_hi], -0b01000000, [rb + flags_hi]
unpack_flags_hi_after_bit6:

    lt  0b00011111, [rb + flags_hi], [rb + tmp]
    jz  [rb + tmp], unpack_flags_hi_after_bit5
    add [rb + flags_hi], -0b00100000, [rb + flags_hi]
unpack_flags_hi_after_bit5:

    lt  0b00001111, [rb + flags_hi], [rb + tmp]
    jz  [rb + tmp], unpack_flags_hi_after_bit4
    add [rb + flags_hi], -0b00010000, [rb + flags_hi]
unpack_flags_hi_after_bit4:

    lt  0b00000111, [rb + flags_hi], [flag_overflow]
    jz  [flag_overflow], unpack_flags_hi_after_overflow
    add [rb + flags_hi], -0b00001000, [rb + flags_hi]
unpack_flags_hi_after_overflow:

    lt  0b00000011, [rb + flags_hi], [flag_direction]
    jz  [flag_direction], unpack_flags_hi_after_direction
    add [rb + flags_hi], -0b00000100, [rb + flags_hi]
unpack_flags_hi_after_direction:

    lt  0b00000001, [rb + flags_hi], [flag_interrupt]
    jz  [flag_interrupt], unpack_flags_hi_after_interrupt
    add [rb + flags_hi], -0b00000010, [rb + flags_hi]
unpack_flags_hi_after_interrupt:

    lt  0, [rb + flags_hi], [flag_trap]

    arb 1
    ret 1
.ENDFRAME

.EOF
