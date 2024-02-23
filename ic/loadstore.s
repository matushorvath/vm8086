execute_lda
execute_ldx
execute_ldy

execute_sta
execute_stx
execute_sty

execute_tax
execute_tay
execute_tsx
execute_txa
execute_tya


lda(addr) {
        this.a = this.read(addr);
        this.updateNegativeZero(this.a);
    }

    ldx(addr) {
        this.x = this.read(addr);
        this.updateNegativeZero(this.x);
    }

    ldy(addr) {
        this.y = this.read(addr);
        this.updateNegativeZero(this.y);
    }

    str(val, addr) {
        this.write(addr, val);
    }

