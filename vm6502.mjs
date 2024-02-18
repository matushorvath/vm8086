// http://www.6502.org/tutorials/6502opcodes.html
// https://www.masswerk.at/6502/6502_instruction_set.html
//
// Functional tests:
// https://github.com/amb5l/6502_65C02_functional_tests
// set disable_decimal = 1
// node main.mjs --trace pc --start 0400 ../6502_65C02_functional_tests/ca65/6502_functional_test.bin
// if it loops at 336d, tests passed (exact address will depend on the 6502_functional_test.bin binary)

import { OPCODES } from './opcodes.mjs';
import fs from 'node:fs';

let inputSimulate0D = false;

const input = () => {
    if (inputSimulate0D) {
        // If the last character we got was 0x0a, simulate a following 0x0d
        inputSimulate0D = false;
        return 0x0d;
    } else {
        const buffer = Buffer.alloc(1);

        // Ignore 0x0d characters, we simulate them automatically after each 0x0a
        while (buffer[0] === 0x00 || buffer[0] === 0x0d) {
            fs.readSync(0, buffer, 0, 1);
        }

        // Make sure a 0x0d always follows a 0x0a
        if (buffer[0] === 0x0a) {
            inputSimulate0D = true;
        }

        //console.log('in', buffer[0]);
        return buffer[0];
    }
};

const output = (val) => {
    const ch = String.fromCharCode(val);
    //console.log('out', this.format8(val), ch);
    process.stdout.write(ch);
};

export class Vm6502 {
    constructor(mem = [], symbols = [], io = { input, output }) {
        this.mem = mem;
        this.symbols = symbols;

        // Load initial address from the reset vector
        this.pc = this.read(0xfffc) + 0x100 * this.read(0xfffd);

        this.a = 0;
        this.x = 0;
        this.y = 0;
        this.sp = 0xff;

        this.negative = false;      // N
        this.overflow = false;      // V
        this.decimal = false;       // D
        this.interrupt = false;     // I
        this.zero = false;          // Z
        this.carry = false;         // C

        this.trace = undefined;

        this.io = io;
        this.ioport = 0xfff0;
    }

    read(addr) {
        if (addr === this.ioport) {
            return this.io.input();
        } else {
            return this.mem[addr] ?? 0;
        }
    }

    write(addr, val) {
        if (val < 0x00 || val > 0xff) {
            throw new Error(`range error; value ${this.format8(val)}, addr ${this.format16(this.pc)}`);
        }

        if (addr === this.ioport) {
            this.io.output(val);
        } else {
            this.mem[addr] = val;
        }
    }

    incpc() {
        const pc = this.pc;
        this.pc = (this.pc + 1) % 0x10000;
        return pc;
    }

    immediate() {
        return this.incpc();
    }

    zeropage(reg = 0) {
        return (this.read(this.incpc()) + reg) % 0x100;
    }

    absolute(reg = 0) {
        return (this.read(this.incpc()) + 0x100 * this.read(this.incpc()) + reg) % 0x10000;
    }

    indirect8(pre = 0, post = 0) {
        const addr = (this.read(this.incpc()) + pre) % 0x100;
        return (this.read(addr) + 0x100 * this.read(addr + 1) + post) % 0x10000;
    }

    indirect16() {
        // Special way of incrementing the address to get the second byte:
        // Increment the low byte without carry to the high byte
        const addrLo = this.read(this.incpc()) + 0x100 * this.read(this.incpc());
        const addrHi = (addrLo & 0xff00) | ((addrLo + 1) & 0x00ff);

        return this.read(addrLo) + 0x100 * this.read(addrHi);
    }

    relative() {
        const rel = this.read(this.incpc());
        return (this.pc + (rel > 0x7f ? rel - 0x100 : rel) + 0x10000) % 0x10000;
    }

    push(val) {
        this.write(0x100 + this.sp, val);
        this.sp = (this.sp - 1 + 0x100) % 0x100;
    }

    pull() {
        this.sp = (this.sp + 1) % 0x100;
        return this.read(0x100 + this.sp);
    }

    packSr() {
        return 0b0011_0000
            | (this.carry ?     0b0000_0001 : 0)
            | (this.zero ?      0b0000_0010 : 0)
            | (this.interrupt ? 0b0000_0100 : 0)
            | (this.decimal ?   0b0000_1000 : 0)
            | (this.overflow ?  0b0100_0000 : 0)
            | (this.negative ?  0b1000_0000 : 0);
    }

    unpackSr(sr) {
        this.carry =     (sr & 0b0000_0001) !== 0;
        this.zero =      (sr & 0b0000_0010) !== 0;
        this.interrupt = (sr & 0b0000_0100) !== 0;
        this.decimal =   (sr & 0b0000_1000) !== 0;
        this.overflow =  (sr & 0b0100_0000) !== 0;
        this.negative =  (sr & 0b1000_0000) !== 0;
    }

    updateNegativeZero(val) {
        this.negative = (val > 0x7f);
        this.zero = (val === 0);
    }

    updateOverflow(op1, op2, res) {
        if ((op1 & 0b1000_0000) !== (op2 & 0b1000_0000)) {
            // When operands are different signs, overflow is always false
            this.overflow = false;
        } else {
            // When operands are the same sign but different than the result, overflow is true
            this.overflow = (op1 & 0b1000_0000) !== (res & 0b1000_0000);
        }
    }

    adc(addr) {
        if (this.decimal) {
            // TODO BCD
            throw new Error('ADC with BCD not implemented');
        } else {
            const sum = this.a + this.read(addr) + (this.carry ? 1 : 0);

            this.carry = sum > 0xff;
            const res = sum % 0x100;
            this.updateOverflow(this.a, this.read(addr), res);

            this.a = res;
            this.updateNegativeZero(this.a);
        }
    }

    and(addr) {
        this.a = this.a & this.read(addr);
        this.updateNegativeZero(this.a);
    }

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

    bit(addr) {
        this.negative = (this.read(addr) & 0b1000_0000) !== 0;
        this.overflow = (this.read(addr) & 0b0100_0000) !== 0;
        this.zero = (this.a & this.read(addr)) === 0;
    }

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

    cmp(reg, addr) {
        const diff = reg - this.read(addr);

        this.carry = diff >= 0x00;
        const res = (diff + 0x100) % 0x100;

        this.updateNegativeZero(res);
    }

    dec(addr) {
        this.write(addr, (this.read(addr) - 1 + 0x100) % 0x100);
        this.updateNegativeZero(this.read(addr));
    }

    eor(addr) {
        this.a = this.a ^ this.read(addr);
        this.updateNegativeZero(this.a);
    }

    inc(addr) {
        this.write(addr, (this.read(addr) + 1) % 0x100);
        this.updateNegativeZero(this.read(addr));
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

    ora(addr) {
        this.a = this.a | this.read(addr);
        this.updateNegativeZero(this.a);
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

    rti() {
        this.unpackSr(this.pull() & 0b1100_1111);
        this.pc = this.pull() + 0x100 * this.pull();
    }

    rts() {
        this.pc = this.pull() + 0x100 * this.pull() + 1;
    }

    sbc(addr) {
        if (this.decimal) {
            // TODO BCD
            throw new Error('SBC with BCD not implemented');
        } else {
            const diff = this.a - this.read(addr) + (this.carry ? 1 : 0) - 1;

            this.carry = diff >= 0x00 && diff < 0x100;
            const res = (diff + 0x100) % 0x100;
            this.updateOverflow(this.read(addr), res, this.a);

            this.a = res;
            this.updateNegativeZero(this.a);
        }
    }

    str(val, addr) {
        this.write(addr, val);
    }

    format8(val) {
        return val.toString(16).padStart(2, '0');
    }

    format16(val) {
        return val.toString(16).padStart(4, '0');
    }

    getDataSymbol(opinfo) {
        switch (opinfo?.mode) {
        case 'Zero Page':
        case 'Zero Page,X':
        case 'Zero Page,Y':
        case 'Indirect,X':
        case 'Indirect,Y':
            return this.symbols?.[this.read((this.pc + 1) % 0x10000)];

        case 'Indirect':
        case 'Absolute':
        case 'Absolute,Y':
        case 'Absolute,X':
            return this.symbols?.[this.read((this.pc + 1)  % 0x10000) + 0x100 * this.read((this.pc + 2) % 0x10000)];

        default:
            return undefined;
        }
    }

    printFullTrace() {
        const opcode = this.read(this.pc);
        const opinfo = OPCODES[opcode];

        const opname = opinfo?.name ?? '???';
        const oplength = opinfo?.length ?? 5;

        const addr = this.format16(this.pc);
        const addrSymbol = this.symbols?.[this.pc];

        const data = [];
        for (let i = 1; i < oplength; i++) {
            data.push(this.format8(this.read((this.pc + i) % 0x10000)));
        }
        const dataSymbol = this.getDataSymbol(opinfo);

        const opStr = `${opname}(${this.format8(opcode)})`;
        const dataStr = dataSymbol ? `${dataSymbol}(${data.join(' ')})`: data.join(' ');

        if (addrSymbol !== undefined) {
            console.log(`${addrSymbol}:`);
        }
        console.log(`${addr}: ${opStr} ${dataStr}`);
    }

    printPcTrace() {
        if (this.cnt === undefined) {
            this.cnt = 0;
        }
        if (this.cnt++ === 100000) {
            console.log(this.format16(this.pc));
            this.cnt = 0;
        }
    }

    run() {
        while (true) {
            if (this.trace === 'full') {
                this.printFullTrace();
            } else if (this.trace === 'pc') {
                this.printPcTrace();
            }

            const op = this.read(this.incpc());

            switch (op) {
            case 0x69: this.adc(this.immediate()); break;
            case 0x65: this.adc(this.zeropage()); break;
            case 0x75: this.adc(this.zeropage(this.x)); break;
            case 0x6d: this.adc(this.absolute()); break;
            case 0x7d: this.adc(this.absolute(this.x)); break;
            case 0x79: this.adc(this.absolute(this.y)); break;
            case 0x61: this.adc(this.indirect8(this.x)); break;
            case 0x71: this.adc(this.indirect8(0, this.y)); break;

            case 0x29: this.and(this.immediate()); break;
            case 0x25: this.and(this.zeropage()); break;
            case 0x35: this.and(this.zeropage(this.x)); break;
            case 0x2d: this.and(this.absolute()); break;
            case 0x3d: this.and(this.absolute(this.x)); break;
            case 0x39: this.and(this.absolute(this.y)); break;
            case 0x21: this.and(this.indirect8(this.x)); break;
            case 0x31: this.and(this.indirect8(0, this.y)); break;

            case 0x0a: this.asl(); break;
            case 0x06: this.asl(this.zeropage()); break;
            case 0x16: this.asl(this.zeropage(this.x)); break;
            case 0x0e: this.asl(this.absolute()); break;
            case 0x1e: this.asl(this.absolute(this.x)); break;

            case 0x24: this.bit(this.zeropage()); break;
            case 0x2c: this.bit(this.absolute()); break;

            case 0x10: this.branch(!this.negative, this.relative()); break;     // BPL (Branch on PLus)
            case 0x30: this.branch(this.negative, this.relative()); break;      // BMI (Branch on MInus)
            case 0x50: this.branch(!this.overflow, this.relative()); break;     // BVC (Branch on oVerflow Clear)
            case 0x70: this.branch(this.overflow, this.relative()); break;      // BVS (Branch on oVerflow Set)
            case 0x90: this.branch(!this.carry, this.relative()); break;        // BCC (Branch on Carry Clear)
            case 0xb0: this.branch(this.carry, this.relative()); break;         // BCS (Branch on Carry Set)
            case 0xd0: this.branch(!this.zero, this.relative()); break;         // BNE (Branch on Not Equal)
            case 0xf0: this.branch(this.zero, this.relative()); break;          // BEQ (Branch on EQual)

            case 0x00: this.brk(); break;

            case 0xc9: this.cmp(this.a, this.immediate()); break;
            case 0xc5: this.cmp(this.a, this.zeropage()); break;
            case 0xd5: this.cmp(this.a, this.zeropage(this.x)); break;
            case 0xcd: this.cmp(this.a, this.absolute()); break;
            case 0xdd: this.cmp(this.a, this.absolute(this.x)); break;
            case 0xd9: this.cmp(this.a, this.absolute(this.y)); break;
            case 0xc1: this.cmp(this.a, this.indirect8(this.x)); break;
            case 0xd1: this.cmp(this.a, this.indirect8(0, this.y)); break;

            case 0xe0: this.cmp(this.x, this.immediate()); break;           // CPX
            case 0xe4: this.cmp(this.x, this.zeropage()); break;            // CPX
            case 0xec: this.cmp(this.x, this.absolute()); break;            // CPX
            case 0xc0: this.cmp(this.y, this.immediate()); break;           // CPY
            case 0xc4: this.cmp(this.y, this.zeropage()); break;            // CPY
            case 0xcc: this.cmp(this.y, this.absolute()); break;            // CPY

            case 0xc6: this.dec(this.zeropage()); break;
            case 0xd6: this.dec(this.zeropage(this.x)); break;
            case 0xce: this.dec(this.absolute()); break;
            case 0xde: this.dec(this.absolute(this.x)); break;

            case 0x49: this.eor(this.immediate()); break;
            case 0x45: this.eor(this.zeropage()); break;
            case 0x55: this.eor(this.zeropage(this.x)); break;
            case 0x4D: this.eor(this.absolute()); break;
            case 0x5D: this.eor(this.absolute(this.x)); break;
            case 0x59: this.eor(this.absolute(this.y)); break;
            case 0x41: this.eor(this.indirect8(this.x)); break;
            case 0x51: this.eor(this.indirect8(0, this.y)); break;

            case 0x18: this.carry = false; break;           // CLC (CLear Carry)
            case 0x38: this.carry = true; break;            // SEC (SEt Carry)
            case 0x58: this.interrupt = false; break;       // CLI (CLear Interrupt)
            case 0x78: this.interrupt = true; break;        // SEI (SEt Interrupt)
            case 0xb8: this.overflow = false; break;        // CLV (CLear oVerflow)
            case 0xd8: this.decimal = false; break;         // CLD (CLear Decimal)
            case 0xf8: this.decimal = true; break;          // SED (SEt Decimal)

            case 0xe6: this.inc(this.zeropage()); break;
            case 0xf6: this.inc(this.zeropage(this.x)); break;
            case 0xee: this.inc(this.absolute()); break;
            case 0xfe: this.inc(this.absolute(this.x)); break;

            case 0x4c: this.jmp(this.absolute()); break;
            case 0x6c: this.jmp(this.indirect16()); break;
            case 0x20: this.jsr(this.absolute()); break;

            case 0xa9: this.lda(this.immediate()); break;
            case 0xa5: this.lda(this.zeropage()); break;
            case 0xb5: this.lda(this.zeropage(this.x)); break;
            case 0xad: this.lda(this.absolute()); break;
            case 0xbd: this.lda(this.absolute(this.x)); break;
            case 0xb9: this.lda(this.absolute(this.y)); break;
            case 0xa1: this.lda(this.indirect8(this.x)); break;
            case 0xb1: this.lda(this.indirect8(0, this.y)); break;

            case 0xa2: this.ldx(this.immediate()); break;
            case 0xa6: this.ldx(this.zeropage()); break;
            case 0xb6: this.ldx(this.zeropage(this.y)); break;
            case 0xae: this.ldx(this.absolute()); break;
            case 0xbe: this.ldx(this.absolute(this.y)); break;

            case 0xa0: this.ldy(this.immediate()); break;
            case 0xa4: this.ldy(this.zeropage()); break;
            case 0xb4: this.ldy(this.zeropage(this.x)); break;
            case 0xac: this.ldy(this.absolute()); break;
            case 0xbc: this.ldy(this.absolute(this.x)); break;

            case 0x4a: this.lsr(); break;
            case 0x46: this.lsr(this.zeropage()); break;
            case 0x56: this.lsr(this.zeropage(this.x)); break;
            case 0x4e: this.lsr(this.absolute()); break;
            case 0x5e: this.lsr(this.absolute(this.x)); break;

            case 0xea: break;               // NOP

            case 0x09: this.ora(this.immediate()); break;
            case 0x05: this.ora(this.zeropage()); break;
            case 0x15: this.ora(this.zeropage(this.x)); break;
            case 0x0d: this.ora(this.absolute()); break;
            case 0x1d: this.ora(this.absolute(this.x)); break;
            case 0x19: this.ora(this.absolute(this.y)); break;
            case 0x01: this.ora(this.indirect8(this.x)); break;
            case 0x11: this.ora(this.indirect8(0, this.y)); break;

            case 0xaa: this.x = this.a; this.updateNegativeZero(this.x); break;         // TAX
            case 0x8a: this.a = this.x; this.updateNegativeZero(this.a); break;         // TXA
            case 0xca: this.x = this.der(this.x); break;                                // DEX
            case 0xe8: this.x = this.inr(this.x); break;                                // INX
            case 0xa8: this.y = this.a; this.updateNegativeZero(this.y); break;         // TAY
            case 0x98: this.a = this.y; this.updateNegativeZero(this.a); break;         // TYA
            case 0x88: this.y = this.der(this.y); break;                                // DEY
            case 0xc8: this.y = this.inr(this.y); break;                                // INY

            case 0x2a: this.rol(); break;
            case 0x26: this.rol(this.zeropage()); break;
            case 0x36: this.rol(this.zeropage(this.x)); break;
            case 0x2e: this.rol(this.absolute()); break;
            case 0x3e: this.rol(this.absolute(this.x)); break;

            case 0x6a: this.ror(); break;
            case 0x66: this.ror(this.zeropage()); break;
            case 0x76: this.ror(this.zeropage(this.x)); break;
            case 0x6e: this.ror(this.absolute()); break;
            case 0x7e: this.ror(this.absolute(this.x)); break;

            case 0x40: this.rti(); break;
            case 0x60: this.rts(); break;

            case 0xe9: this.sbc(this.immediate()); break;
            case 0xe5: this.sbc(this.zeropage()); break;
            case 0xf5: this.sbc(this.zeropage(this.x)); break;
            case 0xed: this.sbc(this.absolute()); break;
            case 0xfd: this.sbc(this.absolute(this.x)); break;
            case 0xf9: this.sbc(this.absolute(this.y)); break;
            case 0xe1: this.sbc(this.indirect8(this.x)); break;
            case 0xf1: this.sbc(this.indirect8(0, this.y)); break;

            case 0x85: this.str(this.a, this.zeropage()); break;                 // STA
            case 0x95: this.str(this.a, this.zeropage(this.x)); break;           // STA
            case 0x8d: this.str(this.a, this.absolute()); break;                 // STA
            case 0x9d: this.str(this.a, this.absolute(this.x)); break;           // STA
            case 0x99: this.str(this.a, this.absolute(this.y)); break;           // STA
            case 0x81: this.str(this.a, this.indirect8(this.x)); break;           // STA
            case 0x91: this.str(this.a, this.indirect8(0, this.y)); break;        // STA

            case 0x9a: this.sp = this.x; break;                                         // TXS
            case 0xba: this.x = this.sp; this.updateNegativeZero(this.x); break;        // TSX
            case 0x48: this.push(this.a); break;                                        // PHA
            case 0x68: this.a = this.pull(); this.updateNegativeZero(this.a); break;    // PLA
            case 0x08: this.push(this.packSr()); break;                   // PHP
            case 0x28: this.unpackSr(this.pull()); break;                               // PLP

            case 0x86: this.str(this.x, this.zeropage()); break;                 // STX
            case 0x96: this.str(this.x, this.zeropage(this.y)); break;           // STX
            case 0x8E: this.str(this.x, this.absolute()); break;                 // STX

            case 0x84: this.str(this.y, this.zeropage()); break;                 // STY
            case 0x94: this.str(this.y, this.zeropage(this.x)); break;           // STY
            case 0x8C: this.str(this.y, this.absolute()); break;                 // STY

            // These are not official instructions, but we need them
            case 0x02: return;              // HLT

            default: throw new Error(`invalid opcode ${this.format8(op)} at ${this.format16((this.pc - 1 + 0x10000) % 0x10000)}`);
            }
        }
    }
}
