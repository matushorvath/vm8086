.EXPORT execute_add_b
.EXPORT execute_adc_b
.EXPORT execute_add_w
.EXPORT execute_adc_w

# TODO BCD support

# From bits.s
.IMPORT bits

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

# From parity.s
.IMPORT parity

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
execute_add_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_adc_b

    ret 4
.ENDFRAME

##########
execute_adc_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, r, tmp
    arb -4

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + a]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + b]

    # Add the 8-bit numbers
    add [rb + a], [rb + b], [rb + r]
    add [rb + r], [flag_carry], [rb + r]

    # Check for carry
    lt  [rb + r], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_adc_b_after_carry

    add [rb + r], -0x100, [rb + r]
    add 1, 0, [flag_carry]

execute_adc_b_after_carry:
    # Update flags
    lt  0x7f, [rb + r], [flag_sign]
    eq  [rb + r], 0, [flag_zero]

    add parity, [rb + r], [ip + 1]
    add [0], 0, [flag_parity]

    # Auxiliary carry
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    add [rb + r], 0, [rb - 3]
    arb -3
    call update_auxiliary_carry

    # Overflow
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    add [rb + r], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + r], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 4
    ret 4
.ENDFRAME

##########
execute_add_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_adc_w

    ret 4
.ENDFRAME

##########
execute_adc_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a_lo, a_hi, b_lo, b_hi, r_lo, r_hi, tmp
    arb -7

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + a_lo]
    add [rb - 5], 0, [rb + a_hi]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + b_lo]
    add [rb - 5], 0, [rb + b_hi]

    # Add the 16-bit numbers
    add [rb + a_lo], [rb + b_lo], [rb + r_lo]
    add [rb + r_lo], [flag_carry], [rb + r_lo]
    add [rb + a_hi], [rb + b_hi], [rb + r_hi]

    # Check for carry out of low byte
    lt  [rb + r_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_adc_w_after_carry_lo

    add [rb + r_lo], -0x100, [rb + r_lo]
    add [rb + r_hi], 1, [rb + r_hi]

execute_adc_w_after_carry_lo:
    # Check for carry out of high byte
    lt  [rb + r_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_adc_w_after_carry_hi

    add [rb + r_hi], -0x100, [rb + r_hi]
    add 1, 0, [flag_carry]

execute_adc_w_after_carry_hi:
    # Update flags
    lt  0x7f, [rb + r_hi], [flag_sign]

    add [rb + r_lo], [rb + r_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + r_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Auxiliary carry
    add [rb + a_lo], 0, [rb - 1]
    add [rb + b_lo], 0, [rb - 2]
    add [rb + r_lo], 0, [rb - 3]
    arb -3
    call update_auxiliary_carry

    # Overflow
    add [rb + a_hi], 0, [rb - 1]
    add [rb + b_hi], 0, [rb - 2]
    add [rb + r_hi], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + r_lo], 0, [rb - 3]
    add [rb + r_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 7
    ret 4
.ENDFRAME

##########
update_auxiliary_carry:
.FRAME a, b, r; a_bit4, b_bit4, r_bit4, tmp
    arb -4

    # Inspect bit 4 of both operands and the result. If they don't match, there was carry into bit 4.

    mul [rb + a], 8, [rb + tmp]                             # tmp = index if a in bits
    add [rb + tmp], 4, [rb + tmp]                           # tmp = index of a[bit 4] in bits
    add bits, [rb + tmp], [ip + 1]
    add [0], 0, [rb + a_bit4]

    mul [rb + b], 8, [rb + tmp]                             # tmp = index if b in bits
    add [rb + tmp], 4, [rb + tmp]                           # tmp = index of b[bit 4] in bits
    add bits, [rb + tmp], [ip + 1]
    add [0], 0, [rb + b_bit4]

    mul [rb + r], 8, [rb + tmp]                             # tmp = index if r in bits
    add [rb + tmp], 4, [rb + tmp]                           # tmp = index of r[bit 4] in bits
    add bits, [rb + tmp], [ip + 1]
    add [0], 0, [rb + r_bit4]

    eq  [rb + a_bit4], [rb + b_bit4], [rb + tmp]            # tmp = 1 + a[bit 4] + b[bit 4] (mod 2)
    eq  [rb + tmp], [rb + r_bit4], [flag_auxiliary_carry]   # af = (a[bit 4] + b[bit 4] !== r[bit 4]) (mod 2)

    arb 4
    ret 3
.ENDFRAME

##########
update_overflow:
.FRAME a, b, r; tmp
    arb -1

    # TODO This is copied from 6502, verify that it's the same for 8086
    # TODO Check if this could be done in a more simple way

    lt  0x7f, [rb + a], [rb + a]
    lt  0x7f, [rb + b], [rb + b]
    lt  0x7f, [rb + r], [rb + r]

    eq  [rb + a], [rb + b], [rb + tmp]
    jnz [rb + tmp], update_overflow_same_sign

    # When operands are different signs, overflow is always false
    add 0, 0, [flag_overflow]
    jz  0, update_overflow_done

update_overflow_same_sign:
    # When operands are the same sign but different than the result, overflow is true
    eq  [rb + a], [rb + r], [rb + tmp]
    eq  [rb + tmp], 0, [flag_overflow]

update_overflow_done:
    arb 1
    ret 3
.ENDFRAME

.EOF

TODO test:

0x00 ADD REG8/MEM8, REG8
0x01 ADD REG16/MEM16, REG16
0x02 ADD REG8, REG8/MEM8
0x03 ADD REG16, REG16/MEM16
0x04 ADD AL, IMMED8
0x05 ADD AX, IMMED16

0x10 ADC REG8/MEM8, REG8
0x11 ADC REG16/MEM16, REG16
0x12 ADC REG8, REG8/MEM8
0x13 ADC REG16, REG16/MEM16
0x14 ADC AL, IMMED8
0x15 ADC AX, IMMED16

0x80+0b000 ADD REG8/MEM8, IMMED8
0x81+0b000 ADD REG16/MEM16, IMMED16
0x82+0b000 ADD REG8/MEM8, IMMED8
0x83+0b000 ADD REG16/MEM16, IMMED8 (sign extended)

0x80+0b010 ADC REG8/MEM8, IMMED8
0x81+0b010 ADC REG16/MEM16, IMMED16
0x82+0b010 ADC REG8/MEM8, IMMED8
0x83+0b010 ADC REG16/MEM16, IMMED8 (sign extended)
