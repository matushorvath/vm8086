.EXPORT execute_sta

# From memory.s
.IMPORT write

# From state.s
.IMPORT reg_a

# TODO remove
.IMPORT print_num

##########
execute_sta:
.FRAME addr;
    arb -0

    # TODO remove
#    add [rb + addr], 0, [rb - 1]
#    arb -1
#    call print_num

    # Write register a to memory
    add [rb + addr], 0, [rb - 1]
    add [reg_a], 0, [rb - 2]
    arb -2
    call write

    arb 0
    ret 1
.ENDFRAME

.EOF

execute_lda
execute_ldx
execute_ldy


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

