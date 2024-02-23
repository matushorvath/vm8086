.EXPORT immediate
.EXPORT zeropage
.EXPORT zeropage_x
.EXPORT zeropage_y
.EXPORT absolute
.EXPORT absolute_x
.EXPORT absolute_y
#.EXPORT indirect8_x
#.EXPORT indirect8_y
#.EXPORT indirect16
#.EXPORT relative

# From util.s
.IMPORT incpc
.IMPORT mod_8bit
.IMPORT mod_16bit

# From state.s
.IMPORT reg_pc
.IMPORT reg_sp

.IMPORT reg_a
.IMPORT reg_x
.IMPORT reg_y

.IMPORT flag_negative
.IMPORT flag_overflow
.IMPORT flag_decimal
.IMPORT flag_interrupt
.IMPORT flag_zero
.IMPORT flag_carry

##########
immediate:
.FRAME addr                                     # addr is returned
    arb -1

    add [reg_pc], 0, [rb + addr]
    call incpc

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr, reg                                # addr is returned
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

zeropage:
    arb -2
    add 0, 0, [rb + reg]
    jz  0, zeropage_generic

zeropage_x:
    arb -2
    add [reg_x], 0, [rb + reg]
    jz  0, zeropage_generic

zeropage_y:
    arb -2
    add [reg_y], 0, [rb + reg]

zeropage_generic:
    add MEM, [reg_pc], [ip + 1]
    add [0], [rb + reg], [rb - 1]               # [MEM + [reg_pc]] + reg -> param0

    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + addr]                # ([MEM + [reg_pc]] + reg) % 0x100 -> addr

    call incpc

    arb 2
    ret 0
.ENDFRAME

##########
.FRAME addr, reg                                # addr is returned
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

absolute:
    arb -2
    add 0, 0, [rb + reg]
    jz  0, absolute_generic

absolute_x:
    arb -2
    add [reg_x], 0, [rb + reg]
    jz  0, absolute_generic

absolute_y:
    arb -2
    add [reg_y], 0, [rb + reg]

absolute_generic:
    add MEM, [reg_pc], [ip + 1]
    add [0], [rb + reg], [rb + addr]                # [MEM + [reg_pc]] + reg -> addr
    call incpc

    add MEM, [reg_pc], [ip + 1]
    mul [0], 256, [rb - 1]                          # [MEM + [reg_pc]] * 0x100 -> param1
    add [rb - 1], [rb + addr], [rb - 1]             # param1 + addr -> param1

    arb -1
    call mod_16bit
    add [rb - 3], 0, [rb + addr]                    # ([MEM + [reg_pc]] + reg + [MEM + [reg_pc]] * 0x100) % 0x10000 -> addr

    call incpc

    arb 2
    ret 0
.ENDFRAME

#indirect8_x
#indirect8_y
#    indirect8(pre = 0, post = 0) {
#        const addr = (this.read(this.incpc()) + pre) % 0x100;
#        return (this.read(addr) + 0x100 * this.read(addr + 1) + post) % 0x10000;
#    }
#
#indirect16
#    indirect16() {
#        // Special way of incrementing the address to get the second byte:
#        // Increment the low byte without carry to the high byte
#        const addrLo = this.read(this.incpc()) + 0x100 * this.read(this.incpc());
#        const addrHi = (addrLo & 0xff00) | ((addrLo + 1) & 0x00ff);
#
#        return this.read(addrLo) + 0x100 * this.read(addrHi);
#    }
#
#relative
#    relative() {
#        const rel = this.read(this.incpc());
#        return (this.pc + (rel > 0x7f ? rel - 0x100 : rel) + 0x10000) % 0x10000;
#    }

.EOF
