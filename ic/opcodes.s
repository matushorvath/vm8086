.EXPORT opcodes

# Metadata on 6502 opcodes for tracing purposes
# Generated using js/gen-opcodes.mjs

opcodes:
    # 0 = 0x00, BRK (Implied)
    db  "BRK", 0
    db  1

    # 1 = 0x01, ORA (Indirect,X)
    db  "ORA", 0
    db  2

    # 2 = 0x02, HLT
    db  "HLT", 0
    db  1

    # 3 = 0x03
    ds  5, 0

    # 4 = 0x04
    ds  5, 0

    # 5 = 0x05, ORA (Zero Page)
    db  "ORA", 0
    db  2

    # 6 = 0x06, ASL (Zero Page)
    db  "ASL", 0
    db  2

    # 7 = 0x07
    ds  5, 0

    # 8 = 0x08, PHP (Implied)
    db  "PHP", 0
    db  1

    # 9 = 0x09, ORA (Immediate)
    db  "ORA", 0
    db  2

    # 10 = 0x0a, ASL (Accumulator)
    db  "ASL", 0
    db  1

    # 11 = 0x0b
    ds  5, 0

    # 12 = 0x0c
    ds  5, 0

    # 13 = 0x0d, ORA (Absolute)
    db  "ORA", 0
    db  3

    # 14 = 0x0e, ASL (Absolute)
    db  "ASL", 0
    db  3

    # 15 = 0x0f
    ds  5, 0

    # 16 = 0x10, BPL (Relative)
    db  "BPL", 0
    db  2

    # 17 = 0x11, ORA (Indirect,Y)
    db  "ORA", 0
    db  2

    # 18 = 0x12
    ds  5, 0

    # 19 = 0x13
    ds  5, 0

    # 20 = 0x14
    ds  5, 0

    # 21 = 0x15, ORA (Zero Page,X)
    db  "ORA", 0
    db  2

    # 22 = 0x16, ASL (Zero Page,X)
    db  "ASL", 0
    db  2

    # 23 = 0x17
    ds  5, 0

    # 24 = 0x18, CLC (Implied)
    db  "CLC", 0
    db  1

    # 25 = 0x19, ORA (Absolute,Y)
    db  "ORA", 0
    db  3

    # 26 = 0x1a
    ds  5, 0

    # 27 = 0x1b
    ds  5, 0

    # 28 = 0x1c
    ds  5, 0

    # 29 = 0x1d, ORA (Absolute,X)
    db  "ORA", 0
    db  3

    # 30 = 0x1e, ASL (Absolute,X)
    db  "ASL", 0
    db  3

    # 31 = 0x1f
    ds  5, 0

    # 32 = 0x20, JSR (Absolute)
    db  "JSR", 0
    db  3

    # 33 = 0x21, AND (Indirect,X)
    db  "AND", 0
    db  2

    # 34 = 0x22
    ds  5, 0

    # 35 = 0x23
    ds  5, 0

    # 36 = 0x24, BIT (Zero Page)
    db  "BIT", 0
    db  2

    # 37 = 0x25, AND (Zero Page)
    db  "AND", 0
    db  2

    # 38 = 0x26, ROL (Zero Page)
    db  "ROL", 0
    db  2

    # 39 = 0x27
    ds  5, 0

    # 40 = 0x28, PLP (Implied)
    db  "PLP", 0
    db  1

    # 41 = 0x29, AND (Immediate)
    db  "AND", 0
    db  2

    # 42 = 0x2a, ROL (Accumulator)
    db  "ROL", 0
    db  1

    # 43 = 0x2b
    ds  5, 0

    # 44 = 0x2c, BIT (Absolute)
    db  "BIT", 0
    db  3

    # 45 = 0x2d, AND (Absolute)
    db  "AND", 0
    db  3

    # 46 = 0x2e, ROL (Absolute)
    db  "ROL", 0
    db  3

    # 47 = 0x2f
    ds  5, 0

    # 48 = 0x30, BMI (Relative)
    db  "BMI", 0
    db  2

    # 49 = 0x31, AND (Indirect,Y)
    db  "AND", 0
    db  2

    # 50 = 0x32
    ds  5, 0

    # 51 = 0x33
    ds  5, 0

    # 52 = 0x34
    ds  5, 0

    # 53 = 0x35, AND (Zero Page,X)
    db  "AND", 0
    db  2

    # 54 = 0x36, ROL (Zero Page,X)
    db  "ROL", 0
    db  2

    # 55 = 0x37
    ds  5, 0

    # 56 = 0x38, SEC (Implied)
    db  "SEC", 0
    db  1

    # 57 = 0x39, AND (Absolute,Y)
    db  "AND", 0
    db  3

    # 58 = 0x3a
    ds  5, 0

    # 59 = 0x3b
    ds  5, 0

    # 60 = 0x3c
    ds  5, 0

    # 61 = 0x3d, AND (Absolute,X)
    db  "AND", 0
    db  3

    # 62 = 0x3e, ROL (Absolute,X)
    db  "ROL", 0
    db  3

    # 63 = 0x3f
    ds  5, 0

    # 64 = 0x40, RTI (Implied)
    db  "RTI", 0
    db  1

    # 65 = 0x41, EOR (Indirect,X)
    db  "EOR", 0
    db  2

    # 66 = 0x42
    ds  5, 0

    # 67 = 0x43
    ds  5, 0

    # 68 = 0x44
    ds  5, 0

    # 69 = 0x45, EOR (Zero Page)
    db  "EOR", 0
    db  2

    # 70 = 0x46, LSR (Zero Page)
    db  "LSR", 0
    db  2

    # 71 = 0x47
    ds  5, 0

    # 72 = 0x48, PHA (Implied)
    db  "PHA", 0
    db  1

    # 73 = 0x49, EOR (Immediate)
    db  "EOR", 0
    db  2

    # 74 = 0x4a, LSR (Accumulator)
    db  "LSR", 0
    db  1

    # 75 = 0x4b
    ds  5, 0

    # 76 = 0x4c, JMP (Absolute)
    db  "JMP", 0
    db  3

    # 77 = 0x4d, EOR (Absolute)
    db  "EOR", 0
    db  3

    # 78 = 0x4e, LSR (Absolute)
    db  "LSR", 0
    db  3

    # 79 = 0x4f
    ds  5, 0

    # 80 = 0x50, BVC (Relative)
    db  "BVC", 0
    db  2

    # 81 = 0x51, EOR (Indirect,Y)
    db  "EOR", 0
    db  2

    # 82 = 0x52
    ds  5, 0

    # 83 = 0x53
    ds  5, 0

    # 84 = 0x54
    ds  5, 0

    # 85 = 0x55, EOR (Zero Page,X)
    db  "EOR", 0
    db  2

    # 86 = 0x56, LSR (Zero Page,X)
    db  "LSR", 0
    db  2

    # 87 = 0x57
    ds  5, 0

    # 88 = 0x58, CLI (Implied)
    db  "CLI", 0
    db  1

    # 89 = 0x59, EOR (Absolute,Y)
    db  "EOR", 0
    db  3

    # 90 = 0x5a
    ds  5, 0

    # 91 = 0x5b
    ds  5, 0

    # 92 = 0x5c
    ds  5, 0

    # 93 = 0x5d, EOR (Absolute,X)
    db  "EOR", 0
    db  3

    # 94 = 0x5e, LSR (Absolute,X)
    db  "LSR", 0
    db  3

    # 95 = 0x5f
    ds  5, 0

    # 96 = 0x60, RTS (Implied)
    db  "RTS", 0
    db  1

    # 97 = 0x61, ADC (Indirect,X)
    db  "ADC", 0
    db  2

    # 98 = 0x62
    ds  5, 0

    # 99 = 0x63
    ds  5, 0

    # 100 = 0x64
    ds  5, 0

    # 101 = 0x65, ADC (Zero Page)
    db  "ADC", 0
    db  2

    # 102 = 0x66, ROR (Zero Page)
    db  "ROR", 0
    db  2

    # 103 = 0x67
    ds  5, 0

    # 104 = 0x68, PLA (Implied)
    db  "PLA", 0
    db  1

    # 105 = 0x69, ADC (Immediate)
    db  "ADC", 0
    db  2

    # 106 = 0x6a, ROR (Accumulator)
    db  "ROR", 0
    db  1

    # 107 = 0x6b
    ds  5, 0

    # 108 = 0x6c, JMP (Indirect)
    db  "JMP", 0
    db  3

    # 109 = 0x6d, ADC (Absolute)
    db  "ADC", 0
    db  3

    # 110 = 0x6e, ROR (Absolute)
    db  "ROR", 0
    db  3

    # 111 = 0x6f
    ds  5, 0

    # 112 = 0x70, BVS (Relative)
    db  "BVS", 0
    db  2

    # 113 = 0x71, ADC (Indirect,Y)
    db  "ADC", 0
    db  2

    # 114 = 0x72
    ds  5, 0

    # 115 = 0x73
    ds  5, 0

    # 116 = 0x74
    ds  5, 0

    # 117 = 0x75, ADC (Zero Page,X)
    db  "ADC", 0
    db  2

    # 118 = 0x76, ROR (Zero Page,X)
    db  "ROR", 0
    db  2

    # 119 = 0x77
    ds  5, 0

    # 120 = 0x78, SEI (Implied)
    db  "SEI", 0
    db  1

    # 121 = 0x79, ADC (Absolute,Y)
    db  "ADC", 0
    db  3

    # 122 = 0x7a
    ds  5, 0

    # 123 = 0x7b
    ds  5, 0

    # 124 = 0x7c
    ds  5, 0

    # 125 = 0x7d, ADC (Absolute,X)
    db  "ADC", 0
    db  3

    # 126 = 0x7e, ROR (Absolute,X)
    db  "ROR", 0
    db  3

    # 127 = 0x7f
    ds  5, 0

    # 128 = 0x80
    ds  5, 0

    # 129 = 0x81, STA (Indirect,X)
    db  "STA", 0
    db  2

    # 130 = 0x82
    ds  5, 0

    # 131 = 0x83
    ds  5, 0

    # 132 = 0x84, STY (Zero Page)
    db  "STY", 0
    db  2

    # 133 = 0x85, STA (Zero Page)
    db  "STA", 0
    db  2

    # 134 = 0x86, STX (Zero Page)
    db  "STX", 0
    db  2

    # 135 = 0x87
    ds  5, 0

    # 136 = 0x88, DEY (Implied)
    db  "DEY", 0
    db  1

    # 137 = 0x89
    ds  5, 0

    # 138 = 0x8a, TXA (Implied)
    db  "TXA", 0
    db  1

    # 139 = 0x8b
    ds  5, 0

    # 140 = 0x8c, STY (Absolute)
    db  "STY", 0
    db  3

    # 141 = 0x8d, STA (Absolute)
    db  "STA", 0
    db  3

    # 142 = 0x8e, STX (Absolute)
    db  "STX", 0
    db  3

    # 143 = 0x8f
    ds  5, 0

    # 144 = 0x90, BCC (Relative)
    db  "BCC", 0
    db  2

    # 145 = 0x91, STA (Indirect,Y)
    db  "STA", 0
    db  2

    # 146 = 0x92
    ds  5, 0

    # 147 = 0x93
    ds  5, 0

    # 148 = 0x94, STY (Zero Page,X)
    db  "STY", 0
    db  2

    # 149 = 0x95, STA (Zero Page,X)
    db  "STA", 0
    db  2

    # 150 = 0x96, STX (Zero Page,Y)
    db  "STX", 0
    db  2

    # 151 = 0x97
    ds  5, 0

    # 152 = 0x98, TYA (Implied)
    db  "TYA", 0
    db  1

    # 153 = 0x99, STA (Absolute,Y)
    db  "STA", 0
    db  3

    # 154 = 0x9a, TXS (Implied)
    db  "TXS", 0
    db  1

    # 155 = 0x9b
    ds  5, 0

    # 156 = 0x9c
    ds  5, 0

    # 157 = 0x9d, STA (Absolute,X)
    db  "STA", 0
    db  3

    # 158 = 0x9e
    ds  5, 0

    # 159 = 0x9f
    ds  5, 0

    # 160 = 0xa0, LDY (Immediate)
    db  "LDY", 0
    db  2

    # 161 = 0xa1, LDA (Indirect,X)
    db  "LDA", 0
    db  2

    # 162 = 0xa2, LDX (Immediate)
    db  "LDX", 0
    db  2

    # 163 = 0xa3
    ds  5, 0

    # 164 = 0xa4, LDY (Zero Page)
    db  "LDY", 0
    db  2

    # 165 = 0xa5, LDA (Zero Page)
    db  "LDA", 0
    db  2

    # 166 = 0xa6, LDX (Zero Page)
    db  "LDX", 0
    db  2

    # 167 = 0xa7
    ds  5, 0

    # 168 = 0xa8, TAY (Implied)
    db  "TAY", 0
    db  1

    # 169 = 0xa9, LDA (Immediate)
    db  "LDA", 0
    db  2

    # 170 = 0xaa, TAX (Implied)
    db  "TAX", 0
    db  1

    # 171 = 0xab
    ds  5, 0

    # 172 = 0xac, LDY (Absolute)
    db  "LDY", 0
    db  3

    # 173 = 0xad, LDA (Absolute)
    db  "LDA", 0
    db  3

    # 174 = 0xae, LDX (Absolute)
    db  "LDX", 0
    db  3

    # 175 = 0xaf
    ds  5, 0

    # 176 = 0xb0, BCS (Relative)
    db  "BCS", 0
    db  2

    # 177 = 0xb1, LDA (Indirect,Y)
    db  "LDA", 0
    db  2

    # 178 = 0xb2
    ds  5, 0

    # 179 = 0xb3
    ds  5, 0

    # 180 = 0xb4, LDY (Zero Page,X)
    db  "LDY", 0
    db  2

    # 181 = 0xb5, LDA (Zero Page,X)
    db  "LDA", 0
    db  2

    # 182 = 0xb6, LDX (Zero Page,Y)
    db  "LDX", 0
    db  2

    # 183 = 0xb7
    ds  5, 0

    # 184 = 0xb8, CLV (Implied)
    db  "CLV", 0
    db  1

    # 185 = 0xb9, LDA (Absolute,Y)
    db  "LDA", 0
    db  3

    # 186 = 0xba, TSX (Implied)
    db  "TSX", 0
    db  1

    # 187 = 0xbb
    ds  5, 0

    # 188 = 0xbc, LDY (Absolute,X)
    db  "LDY", 0
    db  3

    # 189 = 0xbd, LDA (Absolute,X)
    db  "LDA", 0
    db  3

    # 190 = 0xbe, LDX (Absolute,Y)
    db  "LDX", 0
    db  3

    # 191 = 0xbf
    ds  5, 0

    # 192 = 0xc0, CPY (Immediate)
    db  "CPY", 0
    db  2

    # 193 = 0xc1, CMP (Indirect,X)
    db  "CMP", 0
    db  2

    # 194 = 0xc2
    ds  5, 0

    # 195 = 0xc3
    ds  5, 0

    # 196 = 0xc4, CPY (Zero Page)
    db  "CPY", 0
    db  2

    # 197 = 0xc5, CMP (Zero Page)
    db  "CMP", 0
    db  2

    # 198 = 0xc6, DEC (Zero Page)
    db  "DEC", 0
    db  2

    # 199 = 0xc7
    ds  5, 0

    # 200 = 0xc8, INY (Implied)
    db  "INY", 0
    db  1

    # 201 = 0xc9, CMP (Immediate)
    db  "CMP", 0
    db  2

    # 202 = 0xca, DEX (Implied)
    db  "DEX", 0
    db  1

    # 203 = 0xcb
    ds  5, 0

    # 204 = 0xcc, CPY (Absolute)
    db  "CPY", 0
    db  3

    # 205 = 0xcd, CMP (Absolute)
    db  "CMP", 0
    db  3

    # 206 = 0xce, DEC (Absolute)
    db  "DEC", 0
    db  3

    # 207 = 0xcf
    ds  5, 0

    # 208 = 0xd0, BNE (Relative)
    db  "BNE", 0
    db  2

    # 209 = 0xd1, CMP (Indirect,Y)
    db  "CMP", 0
    db  2

    # 210 = 0xd2
    ds  5, 0

    # 211 = 0xd3
    ds  5, 0

    # 212 = 0xd4
    ds  5, 0

    # 213 = 0xd5, CMP (Zero Page,X)
    db  "CMP", 0
    db  2

    # 214 = 0xd6, DEC (Zero Page,X)
    db  "DEC", 0
    db  2

    # 215 = 0xd7
    ds  5, 0

    # 216 = 0xd8, CLD (Implied)
    db  "CLD", 0
    db  1

    # 217 = 0xd9, CMP (Absolute,Y)
    db  "CMP", 0
    db  3

    # 218 = 0xda
    ds  5, 0

    # 219 = 0xdb
    ds  5, 0

    # 220 = 0xdc
    ds  5, 0

    # 221 = 0xdd, CMP (Absolute,X)
    db  "CMP", 0
    db  3

    # 222 = 0xde, DEC (Absolute,X)
    db  "DEC", 0
    db  3

    # 223 = 0xdf
    ds  5, 0

    # 224 = 0xe0, CPX (Immediate)
    db  "CPX", 0
    db  2

    # 225 = 0xe1, SBC (Indirect,X)
    db  "SBC", 0
    db  2

    # 226 = 0xe2
    ds  5, 0

    # 227 = 0xe3
    ds  5, 0

    # 228 = 0xe4, CPX (Zero Page)
    db  "CPX", 0
    db  2

    # 229 = 0xe5, SBC (Zero Page)
    db  "SBC", 0
    db  2

    # 230 = 0xe6, INC (Zero Page)
    db  "INC", 0
    db  2

    # 231 = 0xe7
    ds  5, 0

    # 232 = 0xe8, INX (Implied)
    db  "INX", 0
    db  1

    # 233 = 0xe9, SBC (Immediate)
    db  "SBC", 0
    db  2

    # 234 = 0xea, NOP (Implied)
    db  "NOP", 0
    db  1

    # 235 = 0xeb
    ds  5, 0

    # 236 = 0xec, CPX (Absolute)
    db  "CPX", 0
    db  3

    # 237 = 0xed, SBC (Absolute)
    db  "SBC", 0
    db  3

    # 238 = 0xee, INC (Absolute)
    db  "INC", 0
    db  3

    # 239 = 0xef
    ds  5, 0

    # 240 = 0xf0, BEQ (Relative)
    db  "BEQ", 0
    db  2

    # 241 = 0xf1, SBC (Indirect,Y)
    db  "SBC", 0
    db  2

    # 242 = 0xf2
    ds  5, 0

    # 243 = 0xf3
    ds  5, 0

    # 244 = 0xf4
    ds  5, 0

    # 245 = 0xf5, SBC (Zero Page,X)
    db  "SBC", 0
    db  2

    # 246 = 0xf6, INC (Zero Page,X)
    db  "INC", 0
    db  2

    # 247 = 0xf7
    ds  5, 0

    # 248 = 0xf8, SED (Implied)
    db  "SED", 0
    db  1

    # 249 = 0xf9, SBC (Absolute,Y)
    db  "SBC", 0
    db  3

    # 250 = 0xfa
    ds  5, 0

    # 251 = 0xfb
    ds  5, 0

    # 252 = 0xfc
    ds  5, 0

    # 253 = 0xfd, SBC (Absolute,X)
    db  "SBC", 0
    db  3

    # 254 = 0xfe, INC (Absolute,X)
    db  "INC", 0
    db  3

    # 255 = 0xff
    ds  5, 0

.EOF
