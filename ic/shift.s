TODO instructions

execute_asl
execute_asl_a
execute_lsr
execute_lsr_a
execute_rol
execute_rol_a
execute_ror
execute_ror_a


    asl(addr) {
        const alg = (val) => {
            this.carry = (val & 0b1000_0000) !== 0;
            val = (val << 1) & 0b1111_1111;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }

    lsr(addr) {
        const alg = (val) => {
            this.carry = (val & 0b0000_0001) !== 0;
            val = val >>> 1;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }

    rol(addr) {
        const alg = (val) => {
            const newCarry = (val & 0b1000_0000) !== 0;
            val = ((val << 1) & 0b1111_1111) | (this.carry ? 0b0000_0001 : 0);
            this.carry = newCarry;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }

    ror(addr) {
        const alg = (val) => {
            const newCarry = (val & 0b0000_0001) !== 0;
            val = (val >>> 1) | (this.carry ? 0b1000_0000 : 0);
            this.carry = newCarry;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }
