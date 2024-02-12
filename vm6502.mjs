import fs from 'fs/promises';

// http://www.6502.org/tutorials/6502opcodes.html

// TODO check and fix this.pc handling
//
// When the 6502 is ready for the next instruction it increments the program counter before fetching the instruction.
// Once it has the op code, it increments the program counter by the length of the operand, if any.
// This must be accounted for when calculating branches or when pushing bytes to create a false return address
// (i.e. jump table addresses are made up of addresses-1 when it is intended to use an RTS rather than a JMP).
//
// The program counter is loaded least signifigant byte first.
// Therefore the most signifigant byte must be pushed first when creating a false return address.
//
// When calculating branches a forward branch of 6 skips the following 6 bytes so, effectively the program counter
// points to the address that is 8 bytes beyond the address of the branch opcode; and a backward branch of $FA (256-6)
// goes to an address 4 bytes before the branch instruction.

class Vm6502 {
    constructor(mem = []) {
        // TODO program counter (PC) is read from the address provided in the 16-bit reset vector at $FFFC (LB-HB)

        this.pc = 0;
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

        this.mem = mem;
    }

    immediate() {
        return this.pc++;
    }

    zeropage(reg = 0) {
        return (this.mem[this.pc++] + reg) % 256;
    }

    absolute(reg = 0) {
        return this.mem[this.pc++] + 256 * this.mem[this.pc++] + reg;
    }

    indirect(pre = 0, post = 0) {
        const addr = this.mem[this.pc++] + 256 * this.mem[this.pc++] + pre;
        return this.mem[addr] + 256 * this.mem[addr + 1] + post;
    }

    relative() {
        const rel = this.mem[this.pc++];
        return this.pc + this.signed(rel);
    }

    signed(val) {
        return val > 127 ? val - 256 : val;
    }

    unsigned(val) {
        if (val > 127) {
            return [val - 256, true];
        } else if (val < 128) {
            return [val + 256, true];
        } else {
            return [val, false];
        }
    }

    push(val) {
        this.mem[0x0100 + this.sp--] = val;
    }

    pop() {
        return this.mem[0x0100 + ++this.sp];
    }

    packSr() {
        return (this.carry ?     0b0000_0001 : 0)
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
        this.negative = (val > 127);
        this.zero = (val === 0);
    }

    adc(addr) {
        if (this.decimal) {
            // TODO BCD
            throw new Error('ADC with BCD not implemented');
        } else {
            const sum = this.signed(this.a) + this.signed(this.mem[addr]) + (this.carry ? 1 : 0);
            [this.a, this.overflow] = this.unsigned(sum);

            // TODO carry probably works differently than overflow
            this.carry = this.overflow;
            this.updateNegativeZero(this.a);
        }
    }

    and(addr) {
        this.a = this.a & this.mem[addr];
        this.updateNegativeZero(this.a);
    }

    asl(addr) {
        const alg = (val) => {
            this.carry = (val & 0b1000_0000) !== 0;
            val = (val << 1) & 0b1111_1111;
            this.updateNegativeZero(val);
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.mem[addr] = alg(this.mem[addr]);
        }
    }

    bit(addr) {
        this.negative = (this.mem[addr] & 0b1000_0000) !== 0;
        this.overflow = (this.mem[addr] & 0b0100_0000) !== 0;
        this.zero = (this.a & this.mem[addr]) === 0;
    }

    branch(cond, addr) {
        if (cond) {
            this.pc = addr;
        }
    }

    brk() {
        this.push(((this.pc + 1) & 0xff00) >> 8);
        this.push((this.pc + 1) & 0xff);
        this.push(this.packSr() & 0b0001_0000);

        this.interrupt = true;
        this.pc = 0xfffe;
    }

    cmp(reg, addr) {
        const difference = this.signed(reg) - this.signed(this.mem[addr]);
        const [res, overflow] = this.unsigned(difference);

        // TODO carry probably works differently than overflow
        this.carry = overflow;
        this.updateNegativeZero(res);
    }

    dec(addr) {
        this.mem[addr] = this.mem[addr] - 1;
        this.updateNegativeZero(this.mem[addr]);
    }

    eor(addr) {
        this.a = this.a ^ this.mem[addr];
        this.updateNegativeZero(this.a);
    }

    inc(addr) {
        this.mem[addr] = this.mem[addr] + 1;
        this.updateNegativeZero(this.mem[addr]);
    }

    jmp(addr) {
        // TODO handle indirect jump through the page border
        // For example if address $3000 contains $40, $30FF contains $80, and $3100 contains $50, the result
        // of JMP ($30FF) will be a transfer of control to $4080 rather than $5080 as you intended
        // i.e. the 6502 took the low byte of the address from $30FF and the high byte from $3000.
        this.pc = addr;
    }

    jsr(addr) {
        this.push(this.pc - 1);
        this.pc = addr;
    }

    lda(addr) {
        this.a = this.mem[addr];
        this.updateNegativeZero(this.a);
    }

    ldx(addr) {
        this.x = this.mem[addr];
        this.updateNegativeZero(this.x);
    }

    ldy(addr) {
        this.y = this.mem[addr];
        this.updateNegativeZero(this.y);
    }

    lsr(addr) {
        const alg = (val) => {
            this.carry = (val & 0b0000_0001) !== 0;
            val = val >>> 1;
            this.updateNegativeZero(val);
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.mem[addr] = alg(this.mem[addr]);
        }
    }

    ora(addr) {
        this.a = this.a | this.mem[addr];
        this.updateNegativeZero(this.a);
    }

    run() {
        while (true) {
            const op = this.mem[this.pc++];

            switch (op) {
            case 0x69: this.adc(this.immediate()); break;
            case 0x65: this.adc(this.zeropage()); break;
            case 0x75: this.adc(this.zeropage(this.x)); break;
            case 0x6d: this.adc(this.absolute()); break;
            case 0x7d: this.adc(this.absolute(this.x)); break;
            case 0x79: this.adc(this.absolute(this.y)); break;
            case 0x61: this.adc(this.indirect(this.x)); break;
            case 0x71: this.adc(this.indirect(0, this.y)); break;

            case 0x29: this.add(this.immediate()); break;
            case 0x25: this.add(this.zeropage()); break;
            case 0x35: this.add(this.zeropage(this.x)); break;
            case 0x2d: this.add(this.absolute()); break;
            case 0x3d: this.add(this.absolute(this.x)); break;
            case 0x39: this.add(this.absolute(this.y)); break;
            case 0x21: this.add(this.indirect(this.x)); break;
            case 0x31: this.add(this.indirect(0, this.y)); break;

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
            case 0xc1: this.cmp(this.a, this.indirect(this.x)); break;
            case 0xd1: this.cmp(this.a, this.indirect(0, this.y)); break;

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
            case 0x41: this.eor(this.indirect(this.x)); break;
            case 0x51: this.eor(this.indirect(0, this.y)); break;

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
            case 0x6c: this.jmp(this.indirect()); break;

            case 0x20: this.jsr(this.absolute()); break;

            case 0xa9: this.lda(this.immediate()); break;
            case 0xa5: this.lda(this.zeropage()); break;
            case 0xb5: this.lda(this.zeropage(this.x)); break;
            case 0xad: this.lda(this.absolute()); break;
            case 0xbd: this.lda(this.absolute(this.x)); break;
            case 0xb9: this.lda(this.absolute(this.y)); break;
            case 0xa1: this.lda(this.indirect(this.x)); break;
            case 0xb1: this.lda(this.indirect(0, this.y)); break;

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
            case 0x01: this.ora(this.indirect(this.x)); break;
            case 0x11: this.ora(this.indirect(0, this.y)); break;

            case 0xAA: this.x = this.a; this.updateNegativeZero(this.x); break;         // TAX
            case 0x8A: this.a = this.x; this.updateNegativeZero(this.a); break;         // TXA
            case 0xCA: this.x--; this.updateNegativeZero(this.x); break;                // DEX
            case 0xE8: this.x++; this.updateNegativeZero(this.x); break;                // INX
            case 0xA8: this.y = this.a; this.updateNegativeZero(this.y); break;         // TAY
            case 0x98: this.a = this.y; this.updateNegativeZero(this.a); break;         // TYA
            case 0x88: this.y--; this.updateNegativeZero(this.y); break;                // DEY
            case 0xC8: this.y++; this.updateNegativeZero(this.y); break;                // INY

            }
        }
    }
}

/* eslint-disable max-len */
// ROL (ROtate Left)

// Affects Flags: N Z C

// MODE           SYNTAX       HEX LEN TIM
// Accumulator   ROL A         $2A  1   2
// zeropage()     ROL $44       $26  2   5
// zeropage(this.x)   ROL $44,X     $36  2   6
// absolute()     ROL $4400     $2E  3   6
// absolute(this.x)    ROL $4400,X   $3E  3   7

// ROL shifts all bits left one position. The Carry is shifted into bit 0 and the original bit 7 is shifted into the Carry.
 
// ROR (ROtate Right)

// Affects Flags: N Z C

// MODE           SYNTAX       HEX LEN TIM
// Accumulator   ROR A         $6A  1   2
// zeropage()     ROR $44       $66  2   5
// zeropage(this.x)   ROR $44,X     $76  2   6
// absolute()     ROR $4400     $6E  3   6
// absolute(this.x)    ROR $4400,X   $7E  3   7

// ROR shifts all bits right one position. The Carry is shifted into bit 7 and the original bit 0 is shifted into the Carry.

 
// RTI (ReTurn from Interrupt)

// Affects Flags: all

// MODE           SYNTAX       HEX LEN TIM
// Implied       RTI           $40  1   6

// RTI retrieves the Processor Status Word (flags) and the Program Counter from the stack in that order (interrupts push the PC first and then the PSW).

// Note that unlike RTS, the return address on the stack is the actual address rather than the address-1.

 
// RTS (ReTurn from Subroutine)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Implied       RTS           $60  1   6

// RTS pulls the top two bytes off the stack (low byte first) and transfers program control to that address+1. It is used, as expected, to exit a subroutine invoked via JSR which pushed the address-1.

// RTS is frequently used to implement a jump table where addresses-1 are pushed onto the stack and accessed via RTS eg. to access the second of four routines:

//  LDX #1
//  JSR EXEC
//  JMP SOMEWHERE

// LOBYTE
//  .BYTE <ROUTINE0-1,<ROUTINE1-1
//  .BYTE <ROUTINE2-1,<ROUTINE3-1

// HIBYTE
//  .BYTE >ROUTINE0-1,>ROUTINE1-1
//  .BYTE >ROUTINE2-1,>ROUTINE3-1

// EXEC
//  LDA HIBYTE,X
//  PHA
//  LDA LOBYTE,X
//  PHA
//  RTS

 
// SBC (SuBtract with Carry)

// Affects Flags: N V Z C

// MODE           SYNTAX       HEX LEN TIM
// immediate()     SBC #$44      $E9  2   2
// zeropage()     SBC $44       $E5  2   3
// zeropage(this.x)   SBC $44,X     $F5  2   4
// absolute()     SBC $4400     $ED  3   4
// absolute(this.x)    SBC $4400,X   $FD  3   4+
// absolute(this.y)    SBC $4400,Y   $F9  3   4+
// indirect(this.x)    SBC ($44,X)   $E1  2   6
// indirect(0, this.y)    SBC ($44),Y   $F1  2   5+

// + add 1 cycle if page boundary crossed

// SBC results are dependant on the setting of the decimal flag. In decimal mode, subtraction is carried out on the assumption that the values involved are packed BCD (Binary Coded Decimal).

// There is no way to subtract without the carry which works as an inverse borrow. i.e, to subtract you set the carry before the operation. If the carry is cleared by the operation, it indicates a borrow occurred.

 
// STA (STore Accumulator)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// zeropage()     STA $44       $85  2   3
// zeropage(this.x)   STA $44,X     $95  2   4
// absolute()     STA $4400     $8D  3   4
// absolute(this.x)    STA $4400,X   $9D  3   5
// absolute(this.y)    STA $4400,Y   $99  3   5
// indirect(this.x)    STA ($44,X)   $81  2   6
// indirect(0, this.y)    STA ($44),Y   $91  2   6

             
// Stack Instructions

// These instructions are implied mode, have a length of one byte and require machine cycles as indicated. The "PuLl" operations are known as "POP" on most other microprocessors. With the 6502, the stack is always on page one ($100-$1FF) and works top down.

// MNEMONIC                        HEX TIM
// TXS (Transfer X to Stack ptr)   $9A  2
// TSX (Transfer Stack ptr to X)   $BA  2
// PHA (PusH Accumulator)          $48  3
// PLA (PuLl Accumulator)          $68  4
// PHP (PusH Processor status)     $08  3
// PLP (PuLl Processor status)     $28  4

 
// STX (STore X register)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// zeropage()     STX $44       $86  2   3
// zeropage(this.y)   STX $44,Y     $96  2   4
// absolute()     STX $4400     $8E  3   4

 
// STY (STore Y register)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// zeropage()     STY $44       $84  2   3
// zeropage(this.x)   STY $44,X     $94  2   4
// absolute()     STY $4400     $8C  3   4

// Last Updated Oct 17, 2020.

const main = async () => {
    const mem = [...await fs.readFile(process.argv[2])];

    const vm = new Vm6502(mem);
    vm.run();
};

await main();
