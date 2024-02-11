import fs from 'fs/promises';

class Vm6502 {
    constructor(mem = []) {
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

    zeropage() {
        return this.mem[this.pc++];
    }

    zeropageIndexed(reg) {
        return (this.mem[this.pc++] + reg) % 256;
    }

    absolute() {
        return this.mem[this.pc++] + 256 * this.mem[this.pc++];
    }

    absoluteIndexed(reg) {
        return this.mem[this.pc++] + 256 * this.mem[this.pc++] + reg;
    }

    indirect() {
        const addr = this.mem[this.pc++] + 256 * this.mem[this.pc++];
        return this.mem[addr] + 256 * this.mem[addr + 1];
    }

    indirectPreIndexed(reg) {
        const addr = this.mem[this.pc++] + 256 * this.mem[this.pc++] + reg;
        return this.mem[addr] + 256 * this.mem[addr + 1];
    }

    indirectPostIndexed(reg) {
        const addr = this.mem[this.pc++] + 256 * this.mem[this.pc++];
        return this.mem[addr] + 256 * this.mem[addr + 1] + reg;
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

    adc(addr) {
        if (this.decimal) {
            // TODO BCD
            throw new Error('ADC with BCD not implemented');
        } else {
            const sum = this.signed(this.a) + this.signed(this.mem[addr]) + (this.carry ? 1 : 0);
            [this.a, this.overflow] = this.unsigned(sum);

            // TODO carry probably works differently than overflow
            this.carry = this.overflow;
            this.negative = (this.a > 127);
            this.zero = (this.a === 0);
        }
    }

    and(addr) {
        this.a = this.a & this.mem[addr];

        this.negative = (this.a > 127);
        this.zero = (this.a === 0);
    }

    asl(addr) {
        if (addr === undefined) {
            this.a = this.aslInt(this.a);
        } else {
            this.mem[addr] = this.aslInt(this.mem[addr]);
        }
    }

    aslInt(val) {
        val = val << 1;
        this.carry = (val & 0b1_0000_0000) !== 0;
        val = val & 0b1111_1111;

        this.negative = (val > 127);
        this.zero = (val === 0);
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
        this.negative = (res > 127);
        this.zero = (res === 0);
    }

    dec(addr) {
        this.mem[addr] = this.mem[addr] - 1;
        this.negative = (this.mem[addr] > 127);
        this.zero = (this.mem[addr] === 0);
    }

    run() {
        // TODO
        // As the reset line goes high, the processor performs a start sequence of 7 cycles, at the end of which the
        // program counter (PC) is read from the address provided in the 16-bit reset vector at $FFFC (LB-HB).
        // Then, at the eighth cycle, the processor transfers control by performing a JMP to the provided address.

        while (true) {
            const op = this.mem[this.pc++];

            switch (op) {
            case 0x69: this.adc(this.immediate()); break;
            case 0x65: this.adc(this.zeropage()); break;
            case 0x75: this.adc(this.zeropageIndexed(this.x)); break;
            case 0x6d: this.adc(this.absolute()); break;
            case 0x7d: this.adc(this.absoluteIndexed(this.x)); break;
            case 0x79: this.adc(this.absoluteIndexed(this.y)); break;
            case 0x61: this.adc(this.indirectPreIndexed(this.x)); break;
            case 0x71: this.adc(this.indirectPostIndexed(this.y)); break;

            case 0x29: this.add(this.immediate()); break;
            case 0x25: this.add(this.zeropage()); break;
            case 0x35: this.add(this.zeropageIndexed(this.x)); break;
            case 0x2d: this.add(this.absolute()); break;
            case 0x3d: this.add(this.absoluteIndexed(this.x)); break;
            case 0x39: this.add(this.absoluteIndexed(this.y)); break;
            case 0x21: this.add(this.indirectPreIndexed(this.x)); break;
            case 0x31: this.add(this.indirectPostIndexed(this.y)); break;

            case 0x0a: this.asl(); break;
            case 0x06: this.asl(this.zeropage()); break;
            case 0x16: this.asl(this.zeropageIndexed(this.x)); break;
            case 0x0e: this.asl(this.absolute()); break;
            case 0x1e: this.asl(this.absoluteIndexed(this.x)); break;

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
            case 0xd5: this.cmp(this.a, this.zeropageIndexed(this.x)); break;
            case 0xcd: this.cmp(this.a, this.absolute()); break;
            case 0xdd: this.cmp(this.a, this.absoluteIndexed(this.x)); break;
            case 0xd9: this.cmp(this.a, this.absoluteIndexed(this.y)); break;
            case 0xc1: this.cmp(this.a, this.indirectPreIndexed(this.x)); break;
            case 0xd1: this.cmp(this.a, this.indirectPostIndexed(this.y)); break;

            case 0xe0: this.cmp(this.x, this.immediate()); break;           // CPX
            case 0xe4: this.cmp(this.x, this.zeropage()); break;            // CPX
            case 0xec: this.cmp(this.x, this.absolute()); break;            // CPX
            case 0xc0: this.cmp(this.y, this.immediate()); break;           // CPY
            case 0xc4: this.cmp(this.y, this.zeropage()); break;            // CPY
            case 0xcc: this.cmp(this.y, this.absolute()); break;            // CPY

            case 0xc6: this.dec(this.zeropage()); break;
            case 0xd6: this.dec(this.zeropageIndexed(this.x)); break;
            case 0xce: this.dec(this.absolute()); break;
            case 0xde: this.dec(this.absoluteIndexed(this.x)); break;

            case 0x49: this.eor(this.immediate()); break;
            case 0x45: this.eor(this.zeropage()); break;
            case 0x55: this.eor(this.zeropageIndexed(this.x)); break;
            case 0x4D: this.eor(this.absolute()); break;
            case 0x5D: this.eor(this.absoluteIndexed(this.x)); break;
            case 0x59: this.eor(this.absoluteIndexed(this.y)); break;
            case 0x41: this.eor(this.indirectPreIndexed(this.x)); break;
            case 0x51: this.eor(this.indirectPostIndexed(this.y)); break;

            case 0x18: this.carry = false; break;           // CLC (CLear Carry)
            case 0x38: this.carry = true; break;            // SEC (SEt Carry)
            case 0x58: this.interrupt = false; break;       // CLI (CLear Interrupt)
            case 0x78: this.interrupt = true; break;        // SEI (SEt Interrupt)
            case 0xb8: this.overflow = false; break;        // CLV (CLear oVerflow)
            case 0xd8: this.decimal = false; break;         // CLD (CLear Decimal)
            case 0xf8: this.decimal = true; break;          // SED (SEt Decimal)
            }
        }
    }
}

/* eslint-disable max-len */
// INC (INCrement memory)

// Affects Flags: N Z

// MODE           SYNTAX       HEX LEN TIM
// Zero Page     INC $44       $E6  2   5
// Zero Page,X   INC $44,X     $F6  2   6
// Absolute      INC $4400     $EE  3   6
// Absolute,X    INC $4400,X   $FE  3   7

 
// JMP (JuMP)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Absolute      JMP $5597     $4C  3   3
// Indirect      JMP ($5597)   $6C  3   5

// JMP transfers program execution to the following address (absolute) or to the location contained in the following address (indirect). Note that there is no carry associated with the indirect jump so:

// AN INDIRECT JUMP MUST NEVER USE A
// VECTOR BEGINNING ON THE LAST BYTE
// OF A PAGE

// For example if address $3000 contains $40, $30FF contains $80, and $3100 contains $50, the result of JMP ($30FF) will be a transfer of control to $4080 rather than $5080 as you intended i.e. the 6502 took the low byte of the address from $30FF and the high byte from $3000.

 
// JSR (Jump to SubRoutine)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Absolute      JSR $5597     $20  3   6

// JSR pushes the address-1 of the next operation on to the stack before transferring program control to the following address. Subroutines are normally terminated by a RTS op code.

 
// LDA (LoaD Accumulator)

// Affects Flags: N Z

// MODE           SYNTAX       HEX LEN TIM
// Immediate     LDA #$44      $A9  2   2
// Zero Page     LDA $44       $A5  2   3
// Zero Page,X   LDA $44,X     $B5  2   4
// Absolute      LDA $4400     $AD  3   4
// Absolute,X    LDA $4400,X   $BD  3   4+
// Absolute,Y    LDA $4400,Y   $B9  3   4+
// Indirect,X    LDA ($44,X)   $A1  2   6
// Indirect,Y    LDA ($44),Y   $B1  2   5+

// + add 1 cycle if page boundary crossed

 
// LDX (LoaD X register)

// Affects Flags: N Z

// MODE           SYNTAX       HEX LEN TIM
// Immediate     LDX #$44      $A2  2   2
// Zero Page     LDX $44       $A6  2   3
// Zero Page,Y   LDX $44,Y     $B6  2   4
// Absolute      LDX $4400     $AE  3   4
// Absolute,Y    LDX $4400,Y   $BE  3   4+

// + add 1 cycle if page boundary crossed

 
// LDY (LoaD Y register)

// Affects Flags: N Z

// MODE           SYNTAX       HEX LEN TIM
// Immediate     LDY #$44      $A0  2   2
// Zero Page     LDY $44       $A4  2   3
// Zero Page,X   LDY $44,X     $B4  2   4
// Absolute      LDY $4400     $AC  3   4
// Absolute,X    LDY $4400,X   $BC  3   4+

// + add 1 cycle if page boundary crossed

 
// LSR (Logical Shift Right)

// Affects Flags: N Z C

// MODE           SYNTAX       HEX LEN TIM
// Accumulator   LSR A         $4A  1   2
// Zero Page     LSR $44       $46  2   5
// Zero Page,X   LSR $44,X     $56  2   6
// Absolute      LSR $4400     $4E  3   6
// Absolute,X    LSR $4400,X   $5E  3   7

// LSR shifts all bits right one position. 0 is shifted into bit 7 and the original bit 0 is shifted into the Carry.

 
// Wrap-Around

// Use caution with indexed zero page operations as they are subject to wrap-around. For example, if the X register holds $FF and you execute LDA $80,X you will not access $017F as you might expect; instead you access $7F i.e. $80-1. This characteristic can be used to advantage but make sure your code is well commented.

// It is possible, however, to access $017F when X = $FF by using the Absolute,X addressing mode of LDA $80,X. That is, instead of:

//   LDA $80,X    ; ZeroPage,X - the resulting object code is: B5 80

// which accesses $007F when X=$FF, use:

//   LDA $0080,X  ; Absolute,X - the resulting object code is: BD 80 00

// which accesses $017F when X = $FF (a at cost of one additional byte and one additional cycle). All of the ZeroPage,X and ZeroPage,Y instructions except STX ZeroPage,Y and STY ZeroPage,X have a corresponding Absolute,X and Absolute,Y instruction. Unfortunately, a lot of 6502 assemblers don't have an easy way to force Absolute addressing, i.e. most will assemble a LDA $0080,X as B5 80. One way to overcome this is to insert the bytes using the .BYTE pseudo-op (on some 6502 assemblers this pseudo-op is called DB or DFB, consult the assembler documentation) as follows:

//   .BYTE $BD,$80,$00  ; LDA $0080,X (absolute,X addressing mode)

// The comment is optional, but highly recommended for clarity.

// In cases where you are writing code that will be relocated you must consider wrap-around when assigning dummy values for addresses that will be adjusted. Both zero and the semi-standard $FFFF should be avoided for dummy labels. The use of zero or zero page values will result in assembled code with zero page opcodes when you wanted absolute codes. With $FFFF, the problem is in addresses+1 as you wrap around to page 0.

 
// Program Counter

// When the 6502 is ready for the next instruction it increments the program counter before fetching the instruction. Once it has the op code, it increments the program counter by the length of the operand, if any. This must be accounted for when calculating branches or when pushing bytes to create a false return address (i.e. jump table addresses are made up of addresses-1 when it is intended to use an RTS rather than a JMP).

// The program counter is loaded least signifigant byte first. Therefore the most signifigant byte must be pushed first when creating a false return address.

// When calculating branches a forward branch of 6 skips the following 6 bytes so, effectively the program counter points to the address that is 8 bytes beyond the address of the branch opcode; and a backward branch of $FA (256-6) goes to an address 4 bytes before the branch instruction.

 
// Execution Times

// Op code execution times are measured in machine cycles; one machine cycle equals one clock cycle. Many instructions require one extra cycle for execution if a page boundary is crossed; these are indicated by a + following the time values shown.

 
// NOP (No OPeration)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Implied       NOP           $EA  1   2

// NOP is used to reserve space for future modifications or effectively REM out existing code.

 
// ORA (bitwise OR with Accumulator)

// Affects Flags: N Z

// MODE           SYNTAX       HEX LEN TIM
// Immediate     ORA #$44      $09  2   2
// Zero Page     ORA $44       $05  2   3
// Zero Page,X   ORA $44,X     $15  2   4
// Absolute      ORA $4400     $0D  3   4
// Absolute,X    ORA $4400,X   $1D  3   4+
// Absolute,Y    ORA $4400,Y   $19  3   4+
// Indirect,X    ORA ($44,X)   $01  2   6
// Indirect,Y    ORA ($44),Y   $11  2   5+

// + add 1 cycle if page boundary crossed

               
// Register Instructions

// Affect Flags: N Z

// These instructions are implied mode, have a length of one byte and require two machine cycles.

// MNEMONIC                 HEX
// TAX (Transfer A to X)    $AA
// TXA (Transfer X to A)    $8A
// DEX (DEcrement X)        $CA
// INX (INcrement X)        $E8
// TAY (Transfer A to Y)    $A8
// TYA (Transfer Y to A)    $98
// DEY (DEcrement Y)        $88
// INY (INcrement Y)        $C8

 
// ROL (ROtate Left)

// Affects Flags: N Z C

// MODE           SYNTAX       HEX LEN TIM
// Accumulator   ROL A         $2A  1   2
// Zero Page     ROL $44       $26  2   5
// Zero Page,X   ROL $44,X     $36  2   6
// Absolute      ROL $4400     $2E  3   6
// Absolute,X    ROL $4400,X   $3E  3   7

// ROL shifts all bits left one position. The Carry is shifted into bit 0 and the original bit 7 is shifted into the Carry.

 
// ROR (ROtate Right)

// Affects Flags: N Z C

// MODE           SYNTAX       HEX LEN TIM
// Accumulator   ROR A         $6A  1   2
// Zero Page     ROR $44       $66  2   5
// Zero Page,X   ROR $44,X     $76  2   6
// Absolute      ROR $4400     $6E  3   6
// Absolute,X    ROR $4400,X   $7E  3   7

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
// Immediate     SBC #$44      $E9  2   2
// Zero Page     SBC $44       $E5  2   3
// Zero Page,X   SBC $44,X     $F5  2   4
// Absolute      SBC $4400     $ED  3   4
// Absolute,X    SBC $4400,X   $FD  3   4+
// Absolute,Y    SBC $4400,Y   $F9  3   4+
// Indirect,X    SBC ($44,X)   $E1  2   6
// Indirect,Y    SBC ($44),Y   $F1  2   5+

// + add 1 cycle if page boundary crossed

// SBC results are dependant on the setting of the decimal flag. In decimal mode, subtraction is carried out on the assumption that the values involved are packed BCD (Binary Coded Decimal).

// There is no way to subtract without the carry which works as an inverse borrow. i.e, to subtract you set the carry before the operation. If the carry is cleared by the operation, it indicates a borrow occurred.

 
// STA (STore Accumulator)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Zero Page     STA $44       $85  2   3
// Zero Page,X   STA $44,X     $95  2   4
// Absolute      STA $4400     $8D  3   4
// Absolute,X    STA $4400,X   $9D  3   5
// Absolute,Y    STA $4400,Y   $99  3   5
// Indirect,X    STA ($44,X)   $81  2   6
// Indirect,Y    STA ($44),Y   $91  2   6

             
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
// Zero Page     STX $44       $86  2   3
// Zero Page,Y   STX $44,Y     $96  2   4
// Absolute      STX $4400     $8E  3   4

 
// STY (STore Y register)

// Affects Flags: none

// MODE           SYNTAX       HEX LEN TIM
// Zero Page     STY $44       $84  2   3
// Zero Page,X   STY $44,X     $94  2   4
// Absolute      STY $4400     $8C  3   4

// Last Updated Oct 17, 2020.

const main = async () => {
    const mem = [...await fs.readFile(process.argv[2])];

    const vm = new Vm6502(mem);
    vm.run();
};

await main();
