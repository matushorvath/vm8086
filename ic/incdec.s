
execute_inc
execute_inx
execute_iny

execute_dec
execute_dex
execute_dey


    dec(addr) {
        this.write(addr, (this.read(addr) - 1 + 0x100) % 0x100);
        this.updateNegativeZero(this.read(addr));
    }

    inc(addr) {
        this.write(addr, (this.read(addr) + 1) % 0x100);
        this.updateNegativeZero(this.read(addr));
    }

    der(val) {
        const res = (val - 1 + 0x100) % 0x100;
        this.updateNegativeZero(res);
        return res;
    }

    inr(val) {
        const res = (val + 1) % 0x100;
        this.updateNegativeZero(res);
        return res;
    }
