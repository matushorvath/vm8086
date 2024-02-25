TODO instructions

execute_and
execute_bit
execute_eor
execute_ora


    and(addr) {
        this.a = this.a & this.read(addr);
        this.updateNegativeZero(this.a);
    }

    bit(addr) {
        this.negative = (this.read(addr) & 0b1000_0000) !== 0;
        this.overflow = (this.read(addr) & 0b0100_0000) !== 0;
        this.zero = (this.a & this.read(addr)) === 0;
    }

    eor(addr) {
        this.a = this.a ^ this.read(addr);
        this.updateNegativeZero(this.a);
    }

    ora(addr) {
        this.a = this.a | this.read(addr);
        this.updateNegativeZero(this.a);
    }
