.EXPORT execute_adc
.EXPORT execute_sbc

.EXPORT execute_cmp
.EXPORT execute_cpx
.EXPORT execute_cpy

# From error.s
# TODO remove after decimal support
.IMPORT report_error

# From memory.s
.IMPORT read

# From state.s
.IMPORT flag_carry
.IMPORT flag_decimal
.IMPORT flag_negative
.IMPORT flag_overflow
.IMPORT flag_zero
.IMPORT reg_a
.IMPORT reg_x
.IMPORT reg_y

# From util
.IMPORT mod_8bit
.IMPORT split_16_8_8

##########
execute_adc:
.FRAME addr; b, sum, a_lo, a_hi, b_lo, b_hi
    arb -6

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + b]

    # Decimal flag?
    jz [flag_decimal], execute_adc_not_decimal

    #db  -42  # TODO remove

    # Split a into high and low part
    add [reg_a], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 3], 0, [rb + a_hi]
    add [rb - 4], 0, [rb + a_lo]

    # Split b into high and low part
    add [rb + b], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 3], 0, [rb + b_hi]
    add [rb - 4], 0, [rb + b_lo]

    # Sum the lo parts plus carry -> a_lo
    add [rb + a_lo], [rb + b_lo], [rb + a_lo]
    add [rb + a_lo], [flag_carry], [rb + a_lo]

    # Carry from a_lo -> flag_carry (temporarily)
    lt  9, [rb + a_lo], [flag_carry]

    # If carry, reduce a_lo by 10
    jz  [flag_carry], execute_adc_bcd_lo_no_carry
    add [rb + a_lo], -10, [rb + a_lo]

execute_adc_bcd_lo_no_carry:
    # Sum the hi parts plus lo carry -> a_hi
    add [rb + a_hi], [rb + b_hi], [rb + a_hi]
    add [rb + a_hi], [flag_carry], [rb + a_hi]

    # Carry from a_hi -> flag_carry
    lt  9, [rb + a_hi], [flag_carry]

    # If carry, reduce a_hi by 10
    jz  [flag_carry], execute_adc_bcd_hi_no_carry
    add [rb + a_hi], -10, [rb + a_hi]

execute_adc_bcd_hi_no_carry:
    # Sum the lo and hi parts
    mul [rb + a_hi], 16, [rb + sum]
    add [rb + sum], [rb + a_lo], [rb + sum]

    jz 0, execute_adc_update_flags

execute_adc_not_decimal:
    # Sum [reg_a] + [b] + [flag_carry]
    add [reg_a], [rb + b], [rb + sum]
    add [rb + sum], [flag_carry], [rb + sum]

    # Set carry flag if sum > 255
    lt 255, [rb + sum], [flag_carry]

    # Wrap around sum to 8 bits
    add [rb + sum], 0, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + sum]

execute_adc_update_flags:
    # Update overflow flag
    add [reg_a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    add [rb + sum], 0, [rb - 3]
    arb -3
    call update_overflow

    # Save the result and update rest of flags
    add [rb + sum], 0, [reg_a]

    lt  127, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 6
    ret 1
.ENDFRAME

##########
execute_sbc:
.FRAME addr; tmp, b, diff
    arb -3

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + b]

    # Decimal flag?
    jz [flag_decimal], execute_sbc_not_decimal

    # Decimal sbc, TODO implement
    add decimal_error, 0, [rb - 1]
    arb -1
    call report_error

    # const diffLo = (this.a & 0b0000_1111) - (b & 0b0000_1111) + (this.carry ? 1 : 0) - 1;
    # const carryLo = diffLo >= 0x00 && diffLo <= 0x09;
    #
    # const diffHi = ((this.a & 0b1111_0000) >> 4) - ((b & 0b1111_0000) >> 4) + (carryLo ? 1 : 0) - 1;
    # this.carry = diffHi >= 0x00 && diffHi <= 0x09;
    #
    # const res = ((diffLo + 10) % 10) | (((diffHi + 10) % 10) << 4);
    # this.updateOverflow(b, res, this.a);      // TODO what does the real processor do?
    #
    # this.a = res;
    # this.updateNegativeZero(this.a);

    jz 0, execute_sbc_done

execute_sbc_not_decimal:
    # Subtract [reg_a] - [b] + [flag_carry] - 1
    mul [rb + b], -1, [rb + diff]
    add [rb + diff], [reg_a], [rb + diff]
    add [rb + diff], [flag_carry], [rb + diff]
    add [rb + diff], -1, [rb + diff]

    # Set carry flag if diff >= 0 && diff <= 255
    add 0, 0, [flag_carry]

    lt  [rb + diff], 0, [rb + tmp]
    jnz [rb + tmp], execute_sbc_carry_false
    lt  255, [rb + diff], [rb + tmp]
    jnz [rb + tmp], execute_sbc_carry_false

    add 1, 0, [flag_carry]

execute_sbc_carry_false:
    # Wrap around diff to 8 bits
    add [rb + diff], 0, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + diff]

    # Update overflow flag
    add [rb + b], 0, [rb - 1]
    add [rb + diff], 0, [rb - 2]
    add [reg_a], 0, [rb - 3]
    arb -3
    call update_overflow

    # Save the result and update rest of flags
    add [rb + diff], 0, [reg_a]

    lt  127, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

execute_sbc_done:
    arb 3
    ret 1
.ENDFRAME

##########
.FRAME addr; reg, b, diff
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

execute_cpx:
    arb -3
    add [reg_x], 0, [rb + reg]
    jz  0, execute_cmp_cpr_generic

execute_cpy:
    arb -3
    add [reg_y], 0, [rb + reg]
    jz  0, execute_cmp_cpr_generic

execute_cmp:
    arb -3
    add [reg_a], 0, [rb + reg]
    jz  0, execute_cmp_cpr_generic

execute_cmp_cpr_generic:
    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + b]

    # Subtract [reg] - [b]
    mul [rb + b], -1, [rb + diff]
    add [rb + diff], [rb + reg], [rb + diff]

    # Set carry flag if diff >= 0
    lt  [rb + diff], 0, [flag_carry]
    eq  [flag_carry], 0, [flag_carry]

    # Wrap around diff to 8 bits
    add [rb + diff], 0, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + diff]

    # Update flags
    lt  127, [rb + diff], [flag_negative]
    eq  [rb + diff], 0, [flag_zero]

    arb 3
    ret 1
.ENDFRAME

##########
update_overflow:
.FRAME op1, op2, res; tmp
    arb -1

    lt  127, [rb + op1], [rb + op1]
    lt  127, [rb + op2], [rb + op2]
    lt  127, [rb + res], [rb + res]

    eq  [rb + op1], [rb + op2], [rb + tmp]
    jnz [rb + tmp], update_overflow_same_sign

    # When operands are different signs, overflow is always false
    add 0, 0, [flag_overflow]
    jz  0, update_overflow_done

update_overflow_same_sign:
    # When operands are the same sign but different than the result, overflow is true
    eq  [rb + op1], [rb + res], [rb + tmp]
    eq  [rb + tmp], 0, [flag_overflow]

update_overflow_done:
    arb 1
    ret 3
.ENDFRAME

##########
# TODO remove after decimal support
decimal_error:
    db  "decimal operations not supported", 0

.EOF
