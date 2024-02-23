execute_adc
execute_sbc

execute_cmp
execute_cpx
execute_cpy


##########
execute_adc:
.FRAME op1, op2, res; tmp
    arb -1

# TODO this should be next to arithmetic ops

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


    adc(addr) {
        const b = this.read(addr);

        if (this.decimal) {
            const sumLo = (this.a & 0b0000_1111) + (b & 0b0000_1111) + (this.carry ? 1 : 0);
            const carryLo = sumLo > 0x09;

            const sumHi = ((this.a & 0b1111_0000) >> 4) + ((b & 0b1111_0000) >> 4) + (carryLo ? 1 : 0);
            this.carry = sumHi > 0x09;

            const res = (sumLo % 10) | ((sumHi % 10) << 4);
            this.updateOverflow(this.a, b, res);      // TODO what does the real processor do?

            this.a = res;
            this.updateNegativeZero(this.a);
        } else {
            const sum = this.a + b + (this.carry ? 1 : 0);
            this.carry = sum > 0xff;

            const res = sum % 0x100;
            this.updateOverflow(this.a, b, res);

            this.a = res;
            this.updateNegativeZero(this.a);
        }
    }

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

##########
update_overflow:
.FRAME op1, op2, res; tmp
    arb -1

# TODO this should be next to arithmetic ops

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
