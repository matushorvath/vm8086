export const OPCODES = {

    0x69: { name: 'ADC', code: 0x69, params: '#$44', mode: 'Immediate', length: 2 },
    0x65: { name: 'ADC', code: 0x65, params: '$44', mode: 'Zero Page', length: 2 },
    0x75: { name: 'ADC', code: 0x75, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x6D: { name: 'ADC', code: 0x6D, params: '$4400', mode: 'Absolute', length: 3 },
    0x7D: { name: 'ADC', code: 0x7D, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0x79: { name: 'ADC', code: 0x79, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0x61: { name: 'ADC', code: 0x61, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0x71: { name: 'ADC', code: 0x71, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0x29: { name: 'AND', code: 0x29, params: '#$44', mode: 'Immediate', length: 2 },
    0x25: { name: 'AND', code: 0x25, params: '$44', mode: 'Zero Page', length: 2 },
    0x35: { name: 'AND', code: 0x35, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x2D: { name: 'AND', code: 0x2D, params: '$4400', mode: 'Absolute', length: 3 },
    0x3D: { name: 'AND', code: 0x3D, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0x39: { name: 'AND', code: 0x39, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0x21: { name: 'AND', code: 0x21, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0x31: { name: 'AND', code: 0x31, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0x0A: { name: 'ASL', code: 0x0A, params: 'A', mode: 'Accumulator', length: 1 },
    0x06: { name: 'ASL', code: 0x06, params: '$44', mode: 'Zero Page', length: 2 },
    0x16: { name: 'ASL', code: 0x16, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x0E: { name: 'ASL', code: 0x0E, params: '$4400', mode: 'Absolute', length: 3 },
    0x1E: { name: 'ASL', code: 0x1E, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x24: { name: 'BIT', code: 0x24, params: '$44', mode: 'Zero Page', length: 2 },
    0x2C: { name: 'BIT', code: 0x2C, params: '$4400', mode: 'Absolute', length: 3 },

    0x10: { name: 'BPL', code: 0x10, mode: 'Relative', length: 2 },
    0x30: { name: 'BMI', code: 0x30, mode: 'Relative', length: 2 },
    0x50: { name: 'BVC', code: 0x50, mode: 'Relative', length: 2 },
    0x70: { name: 'BVS', code: 0x70, mode: 'Relative', length: 2 },
    0x90: { name: 'BCC', code: 0x90, mode: 'Relative', length: 2 },
    0xB0: { name: 'BCS', code: 0xB0, mode: 'Relative', length: 2 },
    0xD0: { name: 'BNE', code: 0xD0, mode: 'Relative', length: 2 },
    0xF0: { name: 'BEQ', code: 0xF0, mode: 'Relative', length: 2 },

    0x00: { name: 'BRK', code: 0x00, mode: 'Implied', length: 1 },

    0xC9: { name: 'CMP', code: 0xC9, params: '#$44', mode: 'Immediate', length: 2 },
    0xC5: { name: 'CMP', code: 0xC5, params: '$44', mode: 'Zero Page', length: 2 },
    0xD5: { name: 'CMP', code: 0xD5, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xCD: { name: 'CMP', code: 0xCD, params: '$4400', mode: 'Absolute', length: 3 },
    0xDD: { name: 'CMP', code: 0xDD, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0xD9: { name: 'CMP', code: 0xD9, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0xC1: { name: 'CMP', code: 0xC1, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0xD1: { name: 'CMP', code: 0xD1, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0xE0: { name: 'CPX', code: 0xE0, params: '#$44', mode: 'Immediate', length: 2 },
    0xE4: { name: 'CPX', code: 0xE4, params: '$44', mode: 'Zero Page', length: 2 },
    0xEC: { name: 'CPX', code: 0xEC, params: '$4400', mode: 'Absolute', length: 3 },

    0xC0: { name: 'CPY', code: 0xC0, params: '#$44', mode: 'Immediate', length: 2 },
    0xC4: { name: 'CPY', code: 0xC4, params: '$44', mode: 'Zero Page', length: 2 },
    0xCC: { name: 'CPY', code: 0xCC, params: '$4400', mode: 'Absolute', length: 3 },

    0xC6: { name: 'DEC', code: 0xC6, params: '$44', mode: 'Zero Page', length: 2 },
    0xD6: { name: 'DEC', code: 0xD6, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xCE: { name: 'DEC', code: 0xCE, params: '$4400', mode: 'Absolute', length: 3 },
    0xDE: { name: 'DEC', code: 0xDE, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x49: { name: 'EOR', code: 0x49, params: '#$44', mode: 'Immediate', length: 2 },
    0x45: { name: 'EOR', code: 0x45, params: '$44', mode: 'Zero Page', length: 2 },
    0x55: { name: 'EOR', code: 0x55, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x4D: { name: 'EOR', code: 0x4D, params: '$4400', mode: 'Absolute', length: 3 },
    0x5D: { name: 'EOR', code: 0x5D, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0x59: { name: 'EOR', code: 0x59, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0x41: { name: 'EOR', code: 0x41, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0x51: { name: 'EOR', code: 0x51, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0x18: { name: 'CLC', code: 0x18, mode: 'Implied', length: 1 },
    0x38: { name: 'SEC', code: 0x38, mode: 'Implied', length: 1 },
    0x58: { name: 'CLI', code: 0x58, mode: 'Implied', length: 1 },
    0x78: { name: 'SEI', code: 0x78, mode: 'Implied', length: 1 },
    0xB8: { name: 'CLV', code: 0xB8, mode: 'Implied', length: 1 },
    0xD8: { name: 'CLD', code: 0xD8, mode: 'Implied', length: 1 },
    0xF8: { name: 'SED', code: 0xF8, mode: 'Implied', length: 1 },

    0xE6: { name: 'INC', code: 0xE6, params: '$44', mode: 'Zero Page', length: 2 },
    0xF6: { name: 'INC', code: 0xF6, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xEE: { name: 'INC', code: 0xEE, params: '$4400', mode: 'Absolute', length: 3 },
    0xFE: { name: 'INC', code: 0xFE, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x4C: { name: 'JMP', code: 0x4C, params: '$5597', mode: 'Absolute', length: 3 },
    0x6C: { name: 'JMP', code: 0x6C, params: '($5597)', mode: 'Indirect', length: 3 },

    0x20: { name: 'JSR', code: 0x20, params: '$5597', mode: 'Absolute', length: 3 },

    0xA9: { name: 'LDA', code: 0xA9, params: '#$44', mode: 'Immediate', length: 2 },
    0xA5: { name: 'LDA', code: 0xA5, params: '$44', mode: 'Zero Page', length: 2 },
    0xB5: { name: 'LDA', code: 0xB5, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xAD: { name: 'LDA', code: 0xAD, params: '$4400', mode: 'Absolute', length: 3 },
    0xBD: { name: 'LDA', code: 0xBD, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0xB9: { name: 'LDA', code: 0xB9, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0xA1: { name: 'LDA', code: 0xA1, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0xB1: { name: 'LDA', code: 0xB1, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0xA2: { name: 'LDX', code: 0xA2, params: '#$44', mode: 'Immediate', length: 2 },
    0xA6: { name: 'LDX', code: 0xA6, params: '$44', mode: 'Zero Page', length: 2 },
    0xB6: { name: 'LDX', code: 0xB6, params: '$44,Y', mode: 'Zero Page,Y', length: 2 },
    0xAE: { name: 'LDX', code: 0xAE, params: '$4400', mode: 'Absolute', length: 3 },
    0xBE: { name: 'LDX', code: 0xBE, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },

    0xA0: { name: 'LDY', code: 0xA0, params: '#$44', mode: 'Immediate', length: 2 },
    0xA4: { name: 'LDY', code: 0xA4, params: '$44', mode: 'Zero Page', length: 2 },
    0xB4: { name: 'LDY', code: 0xB4, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xAC: { name: 'LDY', code: 0xAC, params: '$4400', mode: 'Absolute', length: 3 },
    0xBC: { name: 'LDY', code: 0xBC, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x4A: { name: 'LSR', code: 0x4A, params: 'A', mode: 'Accumulator', length: 1 },
    0x46: { name: 'LSR', code: 0x46, params: '$44', mode: 'Zero Page', length: 2 },
    0x56: { name: 'LSR', code: 0x56, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x4E: { name: 'LSR', code: 0x4E, params: '$4400', mode: 'Absolute', length: 3 },
    0x5E: { name: 'LSR', code: 0x5E, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0xEA: { name: 'NOP', code: 0xEA, mode: 'Implied', length: 1 },

    0x09: { name: 'ORA', code: 0x09, params: '#$44', mode: 'Immediate', length: 2 },
    0x05: { name: 'ORA', code: 0x05, params: '$44', mode: 'Zero Page', length: 2 },
    0x15: { name: 'ORA', code: 0x15, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x0D: { name: 'ORA', code: 0x0D, params: '$4400', mode: 'Absolute', length: 3 },
    0x1D: { name: 'ORA', code: 0x1D, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0x19: { name: 'ORA', code: 0x19, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0x01: { name: 'ORA', code: 0x01, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0x11: { name: 'ORA', code: 0x11, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0xAA: { name: 'TAX', code: 0xAA, mode: 'Implied', length: 1 },
    0x8A: { name: 'TXA', code: 0x8A, mode: 'Implied', length: 1 },
    0xCA: { name: 'DEX', code: 0xCA, mode: 'Implied', length: 1 },
    0xE8: { name: 'INX', code: 0xE8, mode: 'Implied', length: 1 },
    0xA8: { name: 'TAY', code: 0xA8, mode: 'Implied', length: 1 },
    0x98: { name: 'TYA', code: 0x98, mode: 'Implied', length: 1 },
    0x88: { name: 'DEY', code: 0x88, mode: 'Implied', length: 1 },
    0xC8: { name: 'INY', code: 0xC8, mode: 'Implied', length: 1 },

    0x2A: { name: 'ROL', code: 0x2A, params: 'A', mode: 'Accumulator', length: 1 },
    0x26: { name: 'ROL', code: 0x26, params: '$44', mode: 'Zero Page', length: 2 },
    0x36: { name: 'ROL', code: 0x36, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x2E: { name: 'ROL', code: 0x2E, params: '$4400', mode: 'Absolute', length: 3 },
    0x3E: { name: 'ROL', code: 0x3E, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x6A: { name: 'ROR', code: 0x6A, params: 'A', mode: 'Accumulator', length: 1 },
    0x66: { name: 'ROR', code: 0x66, params: '$44', mode: 'Zero Page', length: 2 },
    0x76: { name: 'ROR', code: 0x76, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x6E: { name: 'ROR', code: 0x6E, params: '$4400', mode: 'Absolute', length: 3 },
    0x7E: { name: 'ROR', code: 0x7E, params: '$4400,X', mode: 'Absolute,X', length: 3 },

    0x40: { name: 'RTI', code: 0x40, mode: 'Implied', length: 1 },
    0x60: { name: 'RTS', code: 0x60, mode: 'Implied', length: 1 },

    0xE9: { name: 'SBC', code: 0xE9, params: '#$44', mode: 'Immediate', length: 2 },
    0xE5: { name: 'SBC', code: 0xE5, params: '$44', mode: 'Zero Page', length: 2 },
    0xF5: { name: 'SBC', code: 0xF5, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0xED: { name: 'SBC', code: 0xED, params: '$4400', mode: 'Absolute', length: 3 },
    0xFD: { name: 'SBC', code: 0xFD, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0xF9: { name: 'SBC', code: 0xF9, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0xE1: { name: 'SBC', code: 0xE1, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0xF1: { name: 'SBC', code: 0xF1, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0x85: { name: 'STA', code: 0x85, params: '$44', mode: 'Zero Page', length: 2 },
    0x95: { name: 'STA', code: 0x95, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x8D: { name: 'STA', code: 0x8D, params: '$4400', mode: 'Absolute', length: 3 },
    0x9D: { name: 'STA', code: 0x9D, params: '$4400,X', mode: 'Absolute,X', length: 3 },
    0x99: { name: 'STA', code: 0x99, params: '$4400,Y', mode: 'Absolute,Y', length: 3 },
    0x81: { name: 'STA', code: 0x81, params: '($44,X)', mode: 'Indirect,X', length: 2 },
    0x91: { name: 'STA', code: 0x91, params: '($44),Y', mode: 'Indirect,Y', length: 2 },

    0x9A: { name: 'TXS', code: 0x9A, mode: 'Implied', length: 1 },
    0xBA: { name: 'TSX', code: 0xBA, mode: 'Implied', length: 1 },
    0x48: { name: 'PHA', code: 0x48, mode: 'Implied', length: 1 },
    0x68: { name: 'PLA', code: 0x68, mode: 'Implied', length: 1 },
    0x08: { name: 'PHP', code: 0x08, mode: 'Implied', length: 1 },
    0x28: { name: 'PLP', code: 0x28, mode: 'Implied', length: 1 },

    0x86: { name: 'STX', code: 0x86, params: '$44', mode: 'Zero Page', length: 2 },
    0x96: { name: 'STX', code: 0x96, params: '$44,Y', mode: 'Zero Page,Y', length: 2 },
    0x8E: { name: 'STX', code: 0x8E, params: '$4400', mode: 'Absolute', length: 3 },

    0x84: { name: 'STY', code: 0x84, params: '$44', mode: 'Zero Page', length: 2 },
    0x94: { name: 'STY', code: 0x94, params: '$44,X', mode: 'Zero Page,X', length: 2 },
    0x8C: { name: 'STY', code: 0x8C, params: '$4400', mode: 'Absolute', length: 3 }
};

//([\w,]+|Zero Page|Zero Page,X|Zero Page,Y)\s+(\w+)\s+([^\s]+)\s+\$([\dA-F]+)\s+(\d+)\s+[\d+]+
//    0x$4: { name: '$2', code: 0x$4, params: '$3', mode: '$1', length: $5 },

//(\w+) \(.*\)\s+\$([\dA-Z]+)\s*(\d+)?
//    0x$2: { name: '$1', code: 0x$2, length: $3 },
