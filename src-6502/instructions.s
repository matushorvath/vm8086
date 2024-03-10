.EXPORT instructions

# From arithmetic.s
.IMPORT execute_adc
.IMPORT execute_sbc

.IMPORT execute_cmp
.IMPORT execute_cpx
.IMPORT execute_cpy

# From bitwise.s
.IMPORT execute_and
.IMPORT execute_bit
.IMPORT execute_eor
.IMPORT execute_ora

# From branch.s
.IMPORT execute_brk
.IMPORT execute_jmp
.IMPORT execute_jsr
.IMPORT execute_rti
.IMPORT execute_rts

.IMPORT execute_bcc
.IMPORT execute_bcs
.IMPORT execute_bne
.IMPORT execute_beq
.IMPORT execute_bpl
.IMPORT execute_bmi
.IMPORT execute_bvc
.IMPORT execute_bvs

# From exec.s
.IMPORT execute_nop
.IMPORT invalid_opcode

# From flags.s
.IMPORT execute_clc
.IMPORT execute_cld
.IMPORT execute_cli
.IMPORT execute_clv

.IMPORT execute_sec
.IMPORT execute_sed
.IMPORT execute_sei

# From incdec.s
.IMPORT execute_inc
.IMPORT execute_inx
.IMPORT execute_iny

.IMPORT execute_dec
.IMPORT execute_dex
.IMPORT execute_dey

# From loadstore.s
.IMPORT execute_lda
.IMPORT execute_ldx
.IMPORT execute_ldy

.IMPORT execute_sta
.IMPORT execute_stx
.IMPORT execute_sty

.IMPORT execute_tax
.IMPORT execute_tay
.IMPORT execute_txa
.IMPORT execute_tya
.IMPORT execute_txs
.IMPORT execute_tsx

# From params.s
.IMPORT immediate
.IMPORT zeropage
.IMPORT zeropage_x
.IMPORT zeropage_y
.IMPORT absolute
.IMPORT absolute_x
.IMPORT absolute_y
.IMPORT indirect8_x
.IMPORT indirect8_y
.IMPORT indirect16
.IMPORT relative

# From pushpull.s
.IMPORT execute_php
.IMPORT execute_plp
.IMPORT execute_pha
.IMPORT execute_pla

# From shift.s
.IMPORT execute_asl
.IMPORT execute_asl_a
.IMPORT execute_lsr
.IMPORT execute_lsr_a
.IMPORT execute_rol
.IMPORT execute_rol_a
.IMPORT execute_ror
.IMPORT execute_ror_a

instructions:
    db  "BRK", 0, 1,    execute_brk, 0                      #   0 = 0x00, BRK (Implied)
    db  "ORA", 0, 2,    execute_ora, indirect8_x            #   1 = 0x01, ORA (Indirect,X)
    db  "HLT", 0, 1,    invalid_opcode, 0                   #   2 = 0x02, HLT
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #   3 = 0x03
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #   4 = 0x04
    db  "ORA", 0, 2,    execute_ora, zeropage               #   5 = 0x05, ORA (Zero Page)
    db  "ASL", 0, 2,    execute_asl, zeropage               #   6 = 0x06, ASL (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #   7 = 0x07
    db  "PHP", 0, 1,    execute_php, 0                      #   8 = 0x08, PHP (Implied)
    db  "ORA", 0, 2,    execute_ora, immediate              #   9 = 0x09, ORA (Immediate)
    db  "ASL", 0, 1,    execute_asl_a, 0                    #  10 = 0x0a, ASL (Accumulator)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  11 = 0x0b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  12 = 0x0c
    db  "ORA", 0, 3,    execute_ora, absolute               #  13 = 0x0d, ORA (Absolute)
    db  "ASL", 0, 3,    execute_asl, absolute               #  14 = 0x0e, ASL (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  15 = 0x0f
    db  "BPL", 0, 2,    execute_bpl, relative               #  16 = 0x10, BPL (Relative)
    db  "ORA", 0, 2,    execute_ora, indirect8_y            #  17 = 0x11, ORA (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  18 = 0x12
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  19 = 0x13
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  20 = 0x14
    db  "ORA", 0, 2,    execute_ora, zeropage_x             #  21 = 0x15, ORA (Zero Page,X)
    db  "ASL", 0, 2,    execute_asl, zeropage_x             #  22 = 0x16, ASL (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  23 = 0x17
    db  "CLC", 0, 1,    execute_clc, 0                      #  24 = 0x18, CLC (Implied)
    db  "ORA", 0, 3,    execute_ora, absolute_y             #  25 = 0x19, ORA (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  26 = 0x1a
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  27 = 0x1b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  28 = 0x1c
    db  "ORA", 0, 3,    execute_ora, absolute_x             #  29 = 0x1d, ORA (Absolute,X)
    db  "ASL", 0, 3,    execute_asl, absolute_x             #  30 = 0x1e, ASL (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  31 = 0x1f
    db  "JSR", 0, 3,    execute_jsr, absolute               #  32 = 0x20, JSR (Absolute)
    db  "AND", 0, 2,    execute_and, indirect8_x            #  33 = 0x21, AND (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  34 = 0x22
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  35 = 0x23
    db  "BIT", 0, 2,    execute_bit, zeropage               #  36 = 0x24, BIT (Zero Page)
    db  "AND", 0, 2,    execute_and, zeropage               #  37 = 0x25, AND (Zero Page)
    db  "ROL", 0, 2,    execute_rol, zeropage               #  38 = 0x26, ROL (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  39 = 0x27
    db  "PLP", 0, 1,    execute_plp, 0                      #  40 = 0x28, PLP (Implied)
    db  "AND", 0, 2,    execute_and, immediate              #  41 = 0x29, AND (Immediate)
    db  "ROL", 0, 1,    execute_rol_a, 0                    #  42 = 0x2a, ROL (Accumulator)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  43 = 0x2b
    db  "BIT", 0, 3,    execute_bit, absolute               #  44 = 0x2c, BIT (Absolute)
    db  "AND", 0, 3,    execute_and, absolute               #  45 = 0x2d, AND (Absolute)
    db  "ROL", 0, 3,    execute_rol, absolute               #  46 = 0x2e, ROL (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  47 = 0x2f
    db  "BMI", 0, 2,    execute_bmi, relative               #  48 = 0x30, BMI (Relative)
    db  "AND", 0, 2,    execute_and, indirect8_y            #  49 = 0x31, AND (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  50 = 0x32
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  51 = 0x33
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  52 = 0x34
    db  "AND", 0, 2,    execute_and, zeropage_x             #  53 = 0x35, AND (Zero Page,X)
    db  "ROL", 0, 2,    execute_rol, zeropage_x             #  54 = 0x36, ROL (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  55 = 0x37
    db  "SEC", 0, 1,    execute_sec, 0                      #  56 = 0x38, SEC (Implied)
    db  "AND", 0, 3,    execute_and, absolute_y             #  57 = 0x39, AND (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  58 = 0x3a
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  59 = 0x3b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  60 = 0x3c
    db  "AND", 0, 3,    execute_and, absolute_x             #  61 = 0x3d, AND (Absolute,X)
    db  "ROL", 0, 3,    execute_rol, absolute_x             #  62 = 0x3e, ROL (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  63 = 0x3f
    db  "RTI", 0, 1,    execute_rti, 0                      #  64 = 0x40, RTI (Implied)
    db  "EOR", 0, 2,    execute_eor, indirect8_x            #  65 = 0x41, EOR (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  66 = 0x42
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  67 = 0x43
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  68 = 0x44
    db  "EOR", 0, 2,    execute_eor, zeropage               #  69 = 0x45, EOR (Zero Page)
    db  "LSR", 0, 2,    execute_lsr, zeropage               #  70 = 0x46, LSR (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  71 = 0x47
    db  "PHA", 0, 1,    execute_pha, 0                      #  72 = 0x48, PHA (Implied)
    db  "EOR", 0, 2,    execute_eor, immediate              #  73 = 0x49, EOR (Immediate)
    db  "LSR", 0, 1,    execute_lsr_a, 0                    #  74 = 0x4a, LSR (Accumulator)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  75 = 0x4b
    db  "JMP", 0, 3,    execute_jmp, absolute               #  76 = 0x4c, JMP (Absolute)
    db  "EOR", 0, 3,    execute_eor, absolute               #  77 = 0x4d, EOR (Absolute)
    db  "LSR", 0, 3,    execute_lsr, absolute               #  78 = 0x4e, LSR (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  79 = 0x4f
    db  "BVC", 0, 2,    execute_bvc, relative               #  80 = 0x50, BVC (Relative)
    db  "EOR", 0, 2,    execute_eor, indirect8_y            #  81 = 0x51, EOR (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  82 = 0x52
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  83 = 0x53
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  84 = 0x54
    db  "EOR", 0, 2,    execute_eor, zeropage_x             #  85 = 0x55, EOR (Zero Page,X)
    db  "LSR", 0, 2,    execute_lsr, zeropage_x             #  86 = 0x56, LSR (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  87 = 0x57
    db  "CLI", 0, 1,    execute_cli, 0                      #  88 = 0x58, CLI (Implied)
    db  "EOR", 0, 3,    execute_eor, absolute_y             #  89 = 0x59, EOR (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  90 = 0x5a
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  91 = 0x5b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  92 = 0x5c
    db  "EOR", 0, 3,    execute_eor, absolute_x             #  93 = 0x5d, EOR (Absolute,X)
    db  "LSR", 0, 3,    execute_lsr, absolute_x             #  94 = 0x5e, LSR (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  95 = 0x5f
    db  "RTS", 0, 1,    execute_rts, 0                      #  96 = 0x60, RTS (Implied)
    db  "ADC", 0, 2,    execute_adc, indirect8_x            #  97 = 0x61, ADC (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  98 = 0x62
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   #  99 = 0x63
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 100 = 0x64
    db  "ADC", 0, 2,    execute_adc, zeropage               # 101 = 0x65, ADC (Zero Page)
    db  "ROR", 0, 2,    execute_ror, zeropage               # 102 = 0x66, ROR (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 103 = 0x67
    db  "PLA", 0, 1,    execute_pla, 0                      # 104 = 0x68, PLA (Implied)
    db  "ADC", 0, 2,    execute_adc, immediate              # 105 = 0x69, ADC (Immediate)
    db  "ROR", 0, 1,    execute_ror_a, 0                    # 106 = 0x6a, ROR (Accumulator)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 107 = 0x6b
    db  "JMP", 0, 3,    execute_jmp, indirect16             # 108 = 0x6c, JMP (Indirect)
    db  "ADC", 0, 3,    execute_adc, absolute               # 109 = 0x6d, ADC (Absolute)
    db  "ROR", 0, 3,    execute_ror, absolute               # 110 = 0x6e, ROR (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 111 = 0x6f
    db  "BVS", 0, 2,    execute_bvs, relative               # 112 = 0x70, BVS (Relative)
    db  "ADC", 0, 2,    execute_adc, indirect8_y            # 113 = 0x71, ADC (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 114 = 0x72
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 115 = 0x73
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 116 = 0x74
    db  "ADC", 0, 2,    execute_adc, zeropage_x             # 117 = 0x75, ADC (Zero Page,X)
    db  "ROR", 0, 2,    execute_ror, zeropage_x             # 118 = 0x76, ROR (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 119 = 0x77
    db  "SEI", 0, 1,    execute_sei, 0                      # 120 = 0x78, SEI (Implied)
    db  "ADC", 0, 3,    execute_adc, absolute_y             # 121 = 0x79, ADC (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 122 = 0x7a
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 123 = 0x7b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 124 = 0x7c
    db  "ADC", 0, 3,    execute_adc, absolute_x             # 125 = 0x7d, ADC (Absolute,X)
    db  "ROR", 0, 3,    execute_ror, absolute_x             # 126 = 0x7e, ROR (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 127 = 0x7f
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 128 = 0x80
    db  "STA", 0, 2,    execute_sta, indirect8_x            # 129 = 0x81, STA (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 130 = 0x82
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 131 = 0x83
    db  "STY", 0, 2,    execute_sty, zeropage               # 132 = 0x84, STY (Zero Page)
    db  "STA", 0, 2,    execute_sta, zeropage               # 133 = 0x85, STA (Zero Page)
    db  "STX", 0, 2,    execute_stx, zeropage               # 134 = 0x86, STX (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 135 = 0x87
    db  "DEY", 0, 1,    execute_dey, 0                      # 136 = 0x88, DEY (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 137 = 0x89
    db  "TXA", 0, 1,    execute_txa, 0                      # 138 = 0x8a, TXA (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 139 = 0x8b
    db  "STY", 0, 3,    execute_sty, absolute               # 140 = 0x8c, STY (Absolute)
    db  "STA", 0, 3,    execute_sta, absolute               # 141 = 0x8d, STA (Absolute)
    db  "STX", 0, 3,    execute_stx, absolute               # 142 = 0x8e, STX (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 143 = 0x8f
    db  "BCC", 0, 2,    execute_bcc, relative               # 144 = 0x90, BCC (Relative)
    db  "STA", 0, 2,    execute_sta, indirect8_y            # 145 = 0x91, STA (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 146 = 0x92
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 147 = 0x93
    db  "STY", 0, 2,    execute_sty, zeropage_x             # 148 = 0x94, STY (Zero Page,X)
    db  "STA", 0, 2,    execute_sta, zeropage_x             # 149 = 0x95, STA (Zero Page,X)
    db  "STX", 0, 2,    execute_stx, zeropage_y             # 150 = 0x96, STX (Zero Page,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 151 = 0x97
    db  "TYA", 0, 1,    execute_tya, 0                      # 152 = 0x98, TYA (Implied)
    db  "STA", 0, 3,    execute_sta, absolute_y             # 153 = 0x99, STA (Absolute,Y)
    db  "TXS", 0, 1,    execute_txs, 0                      # 154 = 0x9a, TXS (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 155 = 0x9b
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 156 = 0x9c
    db  "STA", 0, 3,    execute_sta, absolute_x             # 157 = 0x9d, STA (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 158 = 0x9e
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 159 = 0x9f
    db  "LDY", 0, 2,    execute_ldy, immediate              # 160 = 0xa0, LDY (Immediate)
    db  "LDA", 0, 2,    execute_lda, indirect8_x            # 161 = 0xa1, LDA (Indirect,X)
    db  "LDX", 0, 2,    execute_ldx, immediate              # 162 = 0xa2, LDX (Immediate)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 163 = 0xa3
    db  "LDY", 0, 2,    execute_ldy, zeropage               # 164 = 0xa4, LDY (Zero Page)
    db  "LDA", 0, 2,    execute_lda, zeropage               # 165 = 0xa5, LDA (Zero Page)
    db  "LDX", 0, 2,    execute_ldx, zeropage               # 166 = 0xa6, LDX (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 167 = 0xa7
    db  "TAY", 0, 1,    execute_tay, 0                      # 168 = 0xa8, TAY (Implied)
    db  "LDA", 0, 2,    execute_lda, immediate              # 169 = 0xa9, LDA (Immediate)
    db  "TAX", 0, 1,    execute_tax, 0                      # 170 = 0xaa, TAX (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 171 = 0xab
    db  "LDY", 0, 3,    execute_ldy, absolute               # 172 = 0xac, LDY (Absolute)
    db  "LDA", 0, 3,    execute_lda, absolute               # 173 = 0xad, LDA (Absolute)
    db  "LDX", 0, 3,    execute_ldx, absolute               # 174 = 0xae, LDX (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 175 = 0xaf
    db  "BCS", 0, 2,    execute_bcs, relative               # 176 = 0xb0, BCS (Relative)
    db  "LDA", 0, 2,    execute_lda, indirect8_y            # 177 = 0xb1, LDA (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 178 = 0xb2
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 179 = 0xb3
    db  "LDY", 0, 2,    execute_ldy, zeropage_x             # 180 = 0xb4, LDY (Zero Page,X)
    db  "LDA", 0, 2,    execute_lda, zeropage_x             # 181 = 0xb5, LDA (Zero Page,X)
    db  "LDX", 0, 2,    execute_ldx, zeropage_y             # 182 = 0xb6, LDX (Zero Page,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 183 = 0xb7
    db  "CLV", 0, 1,    execute_clv, 0                      # 184 = 0xb8, CLV (Implied)
    db  "LDA", 0, 3,    execute_lda, absolute_y             # 185 = 0xb9, LDA (Absolute,Y)
    db  "TSX", 0, 1,    execute_tsx, 0                      # 186 = 0xba, TSX (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 187 = 0xbb
    db  "LDY", 0, 3,    execute_ldy, absolute_x             # 188 = 0xbc, LDY (Absolute,X)
    db  "LDA", 0, 3,    execute_lda, absolute_x             # 189 = 0xbd, LDA (Absolute,X)
    db  "LDX", 0, 3,    execute_ldx, absolute_y             # 190 = 0xbe, LDX (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 191 = 0xbf
    db  "CPY", 0, 2,    execute_cpy, immediate              # 192 = 0xc0, CPY (Immediate)
    db  "CMP", 0, 2,    execute_cmp, indirect8_x            # 193 = 0xc1, CMP (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 194 = 0xc2
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 195 = 0xc3
    db  "CPY", 0, 2,    execute_cpy, zeropage               # 196 = 0xc4, CPY (Zero Page)
    db  "CMP", 0, 2,    execute_cmp, zeropage               # 197 = 0xc5, CMP (Zero Page)
    db  "DEC", 0, 2,    execute_dec, zeropage               # 198 = 0xc6, DEC (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 199 = 0xc7
    db  "INY", 0, 1,    execute_iny, 0                      # 200 = 0xc8, INY (Implied)
    db  "CMP", 0, 2,    execute_cmp, immediate              # 201 = 0xc9, CMP (Immediate)
    db  "DEX", 0, 1,    execute_dex, 0                      # 202 = 0xca, DEX (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 203 = 0xcb
    db  "CPY", 0, 3,    execute_cpy, absolute               # 204 = 0xcc, CPY (Absolute)
    db  "CMP", 0, 3,    execute_cmp, absolute               # 205 = 0xcd, CMP (Absolute)
    db  "DEC", 0, 3,    execute_dec, absolute               # 206 = 0xce, DEC (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 207 = 0xcf
    db  "BNE", 0, 2,    execute_bne, relative               # 208 = 0xd0, BNE (Relative)
    db  "CMP", 0, 2,    execute_cmp, indirect8_y            # 209 = 0xd1, CMP (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 210 = 0xd2
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 211 = 0xd3
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 212 = 0xd4
    db  "CMP", 0, 2,    execute_cmp, zeropage_x             # 213 = 0xd5, CMP (Zero Page,X)
    db  "DEC", 0, 2,    execute_dec, zeropage_x             # 214 = 0xd6, DEC (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 215 = 0xd7
    db  "CLD", 0, 1,    execute_cld, 0                      # 216 = 0xd8, CLD (Implied)
    db  "CMP", 0, 3,    execute_cmp, absolute_y             # 217 = 0xd9, CMP (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 218 = 0xda
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 219 = 0xdb
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 220 = 0xdc
    db  "CMP", 0, 3,    execute_cmp, absolute_x             # 221 = 0xdd, CMP (Absolute,X)
    db  "DEC", 0, 3,    execute_dec, absolute_x             # 222 = 0xde, DEC (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 223 = 0xdf
    db  "CPX", 0, 2,    execute_cpx, immediate              # 224 = 0xe0, CPX (Immediate)
    db  "SBC", 0, 2,    execute_sbc, indirect8_x            # 225 = 0xe1, SBC (Indirect,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 226 = 0xe2
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 227 = 0xe3
    db  "CPX", 0, 2,    execute_cpx, zeropage               # 228 = 0xe4, CPX (Zero Page)
    db  "SBC", 0, 2,    execute_sbc, zeropage               # 229 = 0xe5, SBC (Zero Page)
    db  "INC", 0, 2,    execute_inc, zeropage               # 230 = 0xe6, INC (Zero Page)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 231 = 0xe7
    db  "INX", 0, 1,    execute_inx, 0                      # 232 = 0xe8, INX (Implied)
    db  "SBC", 0, 2,    execute_sbc, immediate              # 233 = 0xe9, SBC (Immediate)
    db  "NOP", 0, 1,    execute_nop, 0                      # 234 = 0xea, NOP (Implied)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 235 = 0xeb
    db  "CPX", 0, 3,    execute_cpx, absolute               # 236 = 0xec, CPX (Absolute)
    db  "SBC", 0, 3,    execute_sbc, absolute               # 237 = 0xed, SBC (Absolute)
    db  "INC", 0, 3,    execute_inc, absolute               # 238 = 0xee, INC (Absolute)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 239 = 0xef
    db  "BEQ", 0, 2,    execute_beq, relative               # 240 = 0xf0, BEQ (Relative)
    db  "SBC", 0, 2,    execute_sbc, indirect8_y            # 241 = 0xf1, SBC (Indirect,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 242 = 0xf2
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 243 = 0xf3
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 244 = 0xf4
    db  "SBC", 0, 2,    execute_sbc, zeropage_x             # 245 = 0xf5, SBC (Zero Page,X)
    db  "INC", 0, 2,    execute_inc, zeropage_x             # 246 = 0xf6, INC (Zero Page,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 247 = 0xf7
    db  "SED", 0, 1,    execute_sed, 0                      # 248 = 0xf8, SED (Implied)
    db  "SBC", 0, 3,    execute_sbc, absolute_y             # 249 = 0xf9, SBC (Absolute,Y)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 250 = 0xfa
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 251 = 0xfb
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 252 = 0xfc
    db  "SBC", 0, 3,    execute_sbc, absolute_x             # 253 = 0xfd, SBC (Absolute,X)
    db  "INC", 0, 3,    execute_inc, absolute_x             # 254 = 0xfe, INC (Absolute,X)
    db  0, 0, 0, 0, 0,  invalid_opcode, 0                   # 255 = 0xff

.EOF
