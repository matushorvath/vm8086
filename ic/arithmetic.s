.EXPORT execute_adc

# From error.s
# TODO probably not needed
.IMPORT report_error

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_carry
.IMPORT flag_decimal
.IMPORT flag_negative
.IMPORT flag_overflow
.IMPORT flag_zero
.IMPORT reg_a

# From util
.IMPORT mod_8bit

##########
execute_adc:
.FRAME addr; tmp, b, sum
    arb -3

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + b]

    # Decimal flag?
    jz [flag_decimal], execute_adc_not_decimal

    # Decimal adc, TODO implement
    add [decimal_error], 0, [rb - 1]
    arb -1
    call report_error

    # const sumLo = (this.a & 0b0000_1111) + (b & 0b0000_1111) + (this.carry ? 1 : 0);
    # const carryLo = sumLo > 0x09;
    #
    # const sumHi = ((this.a & 0b1111_0000) >> 4) + ((b & 0b1111_0000) >> 4) + (carryLo ? 1 : 0);
    # this.carry = sumHi > 0x09;
    #
    # const res = (sumLo % 10) | ((sumHi % 10) << 4);
    # this.updateOverflow(this.a, b, res);      // TODO what does the real processor do?
    #
    # this.a = res;
    # this.updateNegativeZero(this.a);

    jz 0, execute_adc_done

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

execute_adc_done:
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
# TODO remove
decimal_error:
    db  "decimal operations not supported", 0

.EOF


execute_sbc

execute_cmp
execute_cpx
execute_cpy




    sbc(addr) {
        const b = this.read(addr);

        if (this.decimal) {
            const diffLo = (this.a & 0b0000_1111) - (b & 0b0000_1111) + (this.carry ? 1 : 0) - 1;
            const carryLo = diffLo >= 0x00 && diffLo <= 0x09;

            const diffHi = ((this.a & 0b1111_0000) >> 4) - ((b & 0b1111_0000) >> 4) + (carryLo ? 1 : 0) - 1;
            this.carry = diffHi >= 0x00 && diffHi <= 0x09;

            const res = ((diffLo + 10) % 10) | (((diffHi + 10) % 10) << 4);
            this.updateOverflow(b, res, this.a);      // TODO what does the real processor do?

            this.a = res;
            this.updateNegativeZero(this.a);
        } else {
            const diff = this.a - b + (this.carry ? 1 : 0) - 1;
            this.carry = diff >= 0x00 && diff <= 0xff;

            const res = (diff + 0x100) % 0x100;
            this.updateOverflow(b, res, this.a);

            this.a = res;
            this.updateNegativeZero(this.a);
        }
    }

    cmp(reg, addr) {
        const diff = reg - this.read(addr);
        this.carry = diff >= 0x00;

        const res = (diff + 0x100) % 0x100;
        this.updateNegativeZero(res);
    }
