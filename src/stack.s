.EXPORT push_w
.EXPORT pop_w

# TODO .EXPORT pushf
# TODO .EXPORT popf

# From memory.s
.IMPORT read_seg_off_w
.IMPORT write_seg_off_w

# From state.s
.IMPORT reg_ss
.IMPORT reg_sp

##########
# Increment sp by 2 with wrap around
inc_2_sp:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_sp + 0], 2, [reg_sp + 0]

    # Check for carry out of low byte
    lt  [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_2_sp_done

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_2_sp_done

    # Overflow
    add [reg_sp + 1], -0x100, [reg_sp + 1]

inc_2_sp_done:
    arb 1
    ret 0
.ENDFRAME

##########
# Decrement sp by 2 with wrap around
dec_2_sp:
.FRAME tmp
    arb -1

    # Decrement the low byte
    add [reg_sp + 0], -2, [reg_sp + 0]

    # Check for borrow into low byte
    lt  [reg_sp + 0], 0, [rb + tmp]
    jz  [rb + tmp], dec_2_sp_done

    add [reg_sp + 0], 0x100, [reg_sp + 0]
    add [reg_sp + 1], -1, [reg_sp + 1]

    # Check for borrow into high byte
    lt  [reg_sp + 1], 0, [rb + tmp]
    jz  [rb + tmp], dec_2_sp_done

    # Underflow
    add [reg_sp + 1], 0x100, [reg_sp + 1]

dec_2_sp_done:
    arb 1
    ret 0
.ENDFRAME

##########
push_w:
.FRAME value_lo, value_hi;
    # Decrement sp by 2
    call dec_2_sp

    # Store the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 1], [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    ret 2
.ENDFRAME

##########
pop_w:
.FRAME value_lo, value_hi                                   # returns value_lo, value_hi
    arb -2

    # Read the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Increment sp by 2
    call inc_2_sp

    arb 2
    ret 0
.ENDFRAME

.EOF





##########
pack_sr: # TODO rename sr
.FRAME sr                                           # returns sr
    arb -1

    add 0b00110000, 0, [rb + sr]

    jz  [flag_carry], pack_sr_after_carry
    add [rb + sr], 0b00000001, [rb + sr]
pack_sr_after_carry:

    jz  [flag_zero], pack_sr_after_zero
    add [rb + sr], 0b00000010, [rb + sr]
pack_sr_after_zero:

    jz  [flag_interrupt], pack_sr_after_interrupt
    add [rb + sr], 0b00000100, [rb + sr]
pack_sr_after_interrupt:

    jz  [flag_decimal], pack_sr_after_decimal
    add [rb + sr], 0b00001000, [rb + sr]
pack_sr_after_decimal:

    jz  [flag_overflow], pack_sr_after_overflow
    add [rb + sr], 0b01000000, [rb + sr]
pack_sr_after_overflow:

    jz  [flag_negative], pack_sr_after_negative
    add [rb + sr], 0b10000000, [rb + sr]
pack_sr_after_negative:


    arb 1
    ret 0
.ENDFRAME

##########
unpack_sr: # TODO rename sr
.FRAME sr;
    lt  0b01111111, [rb + sr], [flag_negative]
    jz  [flag_negative], unpack_sr_after_negative
    add [rb + sr], -0b10000000, [rb + sr]
unpack_sr_after_negative:

    lt  0b00111111, [rb + sr], [flag_overflow]
    jz  [flag_overflow], unpack_sr_after_overflow
    add [rb + sr], -0b01000000, [rb + sr]
unpack_sr_after_overflow:

    lt  0b00011111, [rb + sr], [flag_decimal]               # flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_ignored
    add [rb + sr], -0b00100000, [rb + sr]
unpack_sr_after_ignored:

    lt  0b00001111, [rb + sr], [flag_decimal]               # flag_decimal used as tmp
    jz  [flag_decimal], unpack_sr_after_break
    add [rb + sr], -0b00010000, [rb + sr]
unpack_sr_after_break:

    lt  0b00000111, [rb + sr], [flag_decimal]
    jz  [flag_decimal], unpack_sr_after_decimal
    add [rb + sr], -0b00001000, [rb + sr]
unpack_sr_after_decimal:

    lt  0b00000011, [rb + sr], [flag_interrupt]
    jz  [flag_interrupt], unpack_sr_after_interrupt
    add [rb + sr], -0b00000100, [rb + sr]
unpack_sr_after_interrupt:

    lt  0b00000001, [rb + sr], [flag_zero]
    jz  [flag_zero], unpack_sr_after_zero
    add [rb + sr], -0b00000010, [rb + sr]
unpack_sr_after_zero:

    lt  0, [rb + sr], [flag_carry]

    ret 1
.ENDFRAME
