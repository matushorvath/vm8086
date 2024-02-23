execute_brk
execute_jmp
execute_jsr
execute_rti
execute_rts

execute_bcc
execute_bcs
execute_beq
execute_bmi
execute_bne
execute_bpl
execute_bvc
execute_bvs


    branch(cond, addr) {
        if (cond) {
            this.pc = addr;
        }
    }

    brk() {
        this.push(((this.pc + 1) & 0xff00) >> 8);
        this.push((this.pc + 1) & 0xff);
        this.push(this.packSr());

        this.interrupt = true;
        this.pc = this.read(0xfffe) + 0x100 * this.read(0xffff);
    }

    jmp(addr) {
        this.pc = addr;
    }

    jsr(addr) {
        const ret = (this.pc - 1 + 0x10000) % 0x10000;
        this.push((ret & 0xff00) >> 8);
        this.push(ret & 0xff);

        this.pc = addr;
    }

    rti() {
        this.unpackSr(this.pull() & 0b1100_1111);
        this.pc = this.pull() + 0x100 * this.pull();
    }

    rts() {
        this.pc = this.pull() + 0x100 * this.pull() + 1;
    }
