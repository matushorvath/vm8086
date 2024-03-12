.EXPORT instructions

# From exec.s
# TODO .IMPORT execute_nop
# TODO .IMPORT invalid_opcode

# From params.s
# TODO .IMPORT immediate
# TODO .IMPORT zeropage

# iAPX 86, 88 User's Manual; August 1981; pages 4-27 to 4-35

instructions:
    db  exec_add_b, arg_reg_mod_rm_sb               # 0x00 ADD REG8/MEM8, REG8
    db  exec_add_w, arg_reg_mod_rm_sw               # 0x01 ADD REG16/MEM16, REG16
    db  exec_add_b, arg_reg_mod_rm_db               # 0x02 ADD REG8, REG8/MEM8
    db  exec_add_w, arg_reg_mod_rm_dw               # 0x03 ADD REG16, REG16/MEM16
    db  exec_add_b, arg_al_data_b                   # 0x04 ADD AL, IMMED8
    db  exec_add_w, arg_ax_data_w                   # 0x05 ADD AX, IMMED16

    db  exec_push_w, arg_reg_es                     # 0x06 PUSH ES
    db  exec_pop_w, arg_reg_es                      # 0x07 POP ES

    db  exec_or_b, arg_reg_mod_rm_sb                # 0x08 OR REG8/MEM8, REG8
    db  exec_or_w, arg_reg_mod_rm_sw                # 0x09 OR REG16/MEM16, REG16
    db  exec_or_b, arg_reg_mod_rm_db                # 0x0a OR REG8, REG8/MEM8
    db  exec_or_w, arg_reg_mod_rm_dw                # 0x0b OR REG16, REG16/MEM16
    db  exec_or_b, arg_al_data_b                    # 0x0c OR AL, IMMED8
    db  exec_or_w, arg_ax_data_w                    # 0x0d OR AX, IMMED16

    db  exec_push_w, arg_reg_cs                     # 0x0e PUSH CS
    db  invalid_opcode, 0                           # 0x0f

    db  exec_adc_b, arg_reg_mod_rm_sb               # 0x10 ADC REG8/MEM8, REG8
    db  exec_adc_w, arg_reg_mod_rm_sw               # 0x11 ADC REG16/MEM16, REG16
    db  exec_adc_b, arg_reg_mod_rm_db               # 0x12 ADC REG8, REG8/MEM8
    db  exec_adc_w, arg_reg_mod_rm_dw               # 0x13 ADC REG16, REG16/MEM16
    db  exec_adc_b, arg_al_data_b                   # 0x14 ADC AL, IMMED8
    db  exec_adc_w, arg_ax_data_w                   # 0x15 ADC AX, IMMED16

    db  exec_push_w, arg_reg_ss                     # 0x16 PUSH SS
    db  exec_pop_w, arg_reg_ss                      # 0x17 POP SS

    db  exec_sbb_b, arg_reg_mod_rm_sb               # 0x18 SBB REG8/MEM8, REG8
    db  exec_sbb_w, arg_reg_mod_rm_sw               # 0x19 SBB REG16/MEM16, REG16
    db  exec_sbb_b, arg_reg_mod_rm_db               # 0x1a SBB REG8, REG8/MEM8
    db  exec_sbb_w, arg_reg_mod_rm_dw               # 0x1b SBB REG16, REG16/MEM16
    db  exec_sbb_b, arg_al_data_b                   # 0x1c SBB AL, IMMED8
    db  exec_sbb_w, arg_ax_data_w                   # 0x1d SBB AX, IMMED16

    db  exec_push_w, arg_reg_ds                     # 0x1e PUSH SDS
    db  exec_pop_w, arg_reg_ds                      # 0x1f POP DS

    db  exec_and_b, arg_reg_mod_rm_sb               # 0x20 AND REG8/MEM8, REG8
    db  exec_and_w, arg_reg_mod_rm_sw               # 0x21 AND REG16/MEM16, REG16
    db  exec_and_b, arg_reg_mod_rm_db               # 0x22 AND REG8, REG8/MEM8
    db  exec_and_w, arg_reg_mod_rm_dw               # 0x23 AND REG16, REG16/MEM16
    db  exec_and_b, arg_al_data_b                   # 0x24 AND AL, IMMED8
    db  exec_and_w, arg_ax_data_w                   # 0x25 AND AX, IMMED16

    db  exec_segment_prefix, arg_reg_es             # 0x26, ES: (segment override prefix)
    db  exec_daa, 0                                 # 0x27, DAA

    db  exec_sub_b, arg_reg_mod_rm_sb               # 0x28 SUB REG8/MEM8, REG8
    db  exec_sub_w, arg_reg_mod_rm_sw               # 0x29 SUB REG16/MEM16, REG16
    db  exec_sub_b, arg_reg_mod_rm_db               # 0x2a SUB REG8, REG8/MEM8
    db  exec_sub_w, arg_reg_mod_rm_dw               # 0x2b SUB REG16, REG16/MEM16
    db  exec_sub_b, arg_al_data_b                   # 0x2c SUB AL, IMMED8
    db  exec_sub_w, arg_ax_data_w                   # 0x2d SUB AX, IMMED16

    db  exec_segment_prefix, arg_reg_cs             # 0x2e, CS: (segment override prefix)
    db  exec_das, 0                                 # 0x2f, DAS

    db  exec_xor_b, arg_reg_mod_rm_sb               # 0x30 XOR REG8/MEM8, REG8
    db  exec_xor_w, arg_reg_mod_rm_sw               # 0x31 XOR REG16/MEM16, REG16
    db  exec_xor_b, arg_reg_mod_rm_db               # 0x32 XOR REG8, REG8/MEM8
    db  exec_xor_w, arg_reg_mod_rm_dw               # 0x33 XOR REG16, REG16/MEM16
    db  exec_xor_b, arg_al_data_b                   # 0x34 XOR AL, IMMED8
    db  exec_xor_w, arg_ax_data_w                   # 0x35 XOR AX, IMMED16

    db  exec_segment_prefix, arg_reg_ss             # 0x36, SS: (segment override prefix)
    db  exec_aaa, 0                                 # 0x37, AAA

    db  exec_cmp_b, arg_reg_mod_rm_sb               # 0x38 CMP REG8/MEM8, REG8
    db  exec_cmp_w, arg_reg_mod_rm_sw               # 0x39 CMP REG16/MEM16, REG16
    db  exec_cmp_b, arg_reg_mod_rm_db               # 0x3a CMP REG8, REG8/MEM8
    db  exec_cmp_w, arg_reg_mod_rm_dw               # 0x3b CMP REG16, REG16/MEM16
    db  exec_cmp_b, arg_al_data_b                   # 0x3c CMP AL, IMMED8
    db  exec_cmp_w, arg_ax_data_w                   # 0x3d CMP AX, IMMED16

    db  exec_segment_prefix, arg_reg_ds             # 0x3e, DS: (segment override prefix)
    db  exec_aas, 0                                 # 0x3f, AAS

    db  exec_inc_w, arg_reg_ax                      # 0x40, INC AX
    db  exec_inc_w, arg_reg_cx                      # 0x41, INC CX
    db  exec_inc_w, arg_reg_dx                      # 0x42, INC DX
    db  exec_inc_w, arg_reg_bx                      # 0x43, INC BX
    db  exec_inc_w, arg_reg_sp                      # 0x44, INC SP
    db  exec_inc_w, arg_reg_bp                      # 0x45, INC BP
    db  exec_inc_w, arg_reg_si                      # 0x46, INC SI
    db  exec_inc_w, arg_reg_di                      # 0x47, INC DI

    db  exec_dec_w, arg_reg_ax                      # 0x48, DEC AX
    db  exec_dec_w, arg_reg_cx                      # 0x49, DEC CX
    db  exec_dec_w, arg_reg_dx                      # 0x4a, DEC DX
    db  exec_dec_w, arg_reg_bx                      # 0x4b, DEC BX
    db  exec_dec_w, arg_reg_sp                      # 0x4c, DEC SP
    db  exec_dec_w, arg_reg_bp                      # 0x4d, DEC BP
    db  exec_dec_w, arg_reg_si                      # 0x4e, DEC SI
    db  exec_dec_w, arg_reg_di                      # 0x4f, DEC DI

    db  exec_push_w, arg_reg_ax                     # 0x50, PUSH AX
    db  exec_push_w, arg_reg_cx                     # 0x51, PUSH CX
    db  exec_push_w, arg_reg_dx                     # 0x52, PUSH DX
    db  exec_push_w, arg_reg_bx                     # 0x53, PUSH BX
    db  exec_push_w, arg_reg_sp                     # 0x54, PUSH SP
    db  exec_push_w, arg_reg_bp                     # 0x55, PUSH BP
    db  exec_push_w, arg_reg_si                     # 0x56, PUSH SI
    db  exec_push_w, arg_reg_di                     # 0x57, PUSH DI

    db  exec_pop_w, arg_reg_ax                      # 0x58, POP AX
    db  exec_pop_w, arg_reg_cx                      # 0x59, POP CX
    db  exec_pop_w, arg_reg_dx                      # 0x5a, POP DX
    db  exec_pop_w, arg_reg_bx                      # 0x5b, POP BX
    db  exec_pop_w, arg_reg_sp                      # 0x5c, POP SP
    db  exec_pop_w, arg_reg_bp                      # 0x5d, POP BP
    db  exec_pop_w, arg_reg_si                      # 0x5e, POP SI
    db  exec_pop_w, arg_reg_di                      # 0x5f, POP DI

    db  invalid_opcode, 0                           # 0x60
    db  invalid_opcode, 0                           # 0x61
    db  invalid_opcode, 0                           # 0x62
    db  invalid_opcode, 0                           # 0x63
    db  invalid_opcode, 0                           # 0x64
    db  invalid_opcode, 0                           # 0x65
    db  invalid_opcode, 0                           # 0x66
    db  invalid_opcode, 0                           # 0x67

    db  invalid_opcode, 0                           # 0x68
    db  invalid_opcode, 0                           # 0x69
    db  invalid_opcode, 0                           # 0x6a
    db  invalid_opcode, 0                           # 0x6b
    db  invalid_opcode, 0                           # 0x6c
    db  invalid_opcode, 0                           # 0x6d
    db  invalid_opcode, 0                           # 0x6e
    db  invalid_opcode, 0                           # 0x6f

.EOF

70 0111 0000 IP-INC8 JO SHORT-LABEL
71 0111 0001 IP-INC8 JNO SHORT-LABEL
72 0111 0010 IP-INC8 JB/JNAEI SHORT-LABEL
JC
73 0111 0011 IP-INC8 JNB/JAEI SHORT-LABEL
JNC
74 0111 0100 IP-INC8 JE/JZ SHORT-LABEL
75 0111 0101 IP-INC8 JNE/JNZ SHORT-LABEL
76 0111 0110 IP-INC8 JBE/JNA SHORT-LABEL
77 0111 0111 IP-INC8 JNBE/JA SHORT-LABEL
78 0111 1000 IP-INC8 JS SHORT-LABEL
79 0111 1001 IP-INC8 JNS SHORT-LABEL
7A 0111 1010 IP-INC8 JP/JPE SHORT-LABEL
7B 0111 1011 IP-INC8 JNP/JPO SHORT-LABEL
7C 0111 1100 IP-INC8 JLlJNGE SHORT-LABEL
70 0111 1101 IP-INC8 JNLlJGE SHORT-LABEL
7E 0111 1110 IP-INC8 JLE/JNG SHORT-LABEL
7F 0111 1111 IP-INC8 JNLE/JG SHORT-LABEL
80 1000 0000 MOD 000 RIM (DISP-LO),(OISP-HI), ADD REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD 001 RIM (DISP-LO),(DISP-HI), OR REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD010 RIM (DISP-LO),(DISP-HI), ADC REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD 011 RIM (DISP-LO),(DISP-HI), SBB REG8/MEM8,IMMED8
OATA-8
80 1000 0000 MOD100 RIM (DISP-LO),(DISP-HI), AND REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD 101 RIM (DISP-LO),(DISP-HI), SUB REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD110 RIM (DISP-LO),(DISP-HI), XOR REG8/MEM8,IMMED8
DATA-8
80 1000 0000 MOD 111 RIM (DISP-LO),(OISP-HI), CMP REG8/MEM8,IMMED8
DATA-8
81 1000 0001 MODOOO RIM (DISP-LO),(OISP-HI), ADD REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MOD 001 RIM (DISP-LO),(DISP-HI), OR REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MOD010 RIM (DISP-LO),(DISP-HI), AOC REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MODOll RIM (DISP-LO),(OISP-HI), SBB REG16/MEM16,IMMED16


81 1000 0001 MOD100 RIM (DISP-LO),(DISP-HI), AND REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MOD 101 RIM (DISP-LO),(DISP-HI), SUB REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MOD110R/M (DISP-LO),(DISP-HI), XOR REG16/MEM16,IMMED16
DATA-LO,DATA-HI
81 1000 0001 MOD111 RIM (DISP-LO),(DISP-HI), CMP REG16/MEM16,IMMED16
DATA-LO,DATA-HI
82 1000 0010 MODOOOR/M (DISP-LO),(DISP-HI), ADD REG8/MEM8,IMMED8
DATA-8
82 1000 0010 MOD 001 RIM (not used)
82 1000 0010 MOD 010 RIM (DISP-LO),(DISP-HI), ADC REG8/MEM8,IMMED8
DATA-8
82 1000 0010 MOD 011 RIM (DISP-LO),(DISP.HI), SBB REG8/MEM8,IMMED8
DATA-8
82 1000 0010 MOD 100 RIM (not used)
82 1000 0010 MOD 101 RIM (DISP-LO),(DISP-HI), SUB REG8/MEM8,IMMED8
DATA-8
82 1000 0010 MOD110 RIM (not used)
82 1000 0010 MOD111 RIM (DISP-LO),(DISP-HI), CMP REG8/MEM8,IMMED8
DATA-8
83 1000 0011 MOD 000 RIM (DISP-LO),(DISP-HI), ADD REG16/MEM16,IMtylED8
DATA-SX
83 1000 0011 MOD 001 RIM (not used)
83 1000 0011 MOD 010 RIM (DISP-LO), (DISP-HI), ADC REG16/MEM16,IMMED8
DATA-SX
83 1000 0011 MOD011 RIM (DISP-LO),(DISP-HI), SBB REG16/MEM16,IMMED8
DATA-SX
83 1000 0011 MOD100 RIM (not used)
83 1000 0011 MOD101 RIM (DISP-LO),(DISP-HI), SUB REG16/MEM16,IMMED8
DATA-SX
83 1000 0011 MOD110 RIM (not used)
83 1000 0011 MOD 111 RIM (DISP-LO),(DISP-HI), CMP REG16/MEM16,IMMED8
DATA-SX
84 1000 0100 MOD REG RIM (DISP-LO),(DISP-HI) TEST REG8/MEM8,REG8
85 1000 0101 MOD REG RIM (DISP-LO),(DISP-HI) TEST REG16/MEM16,REG16
86 1000 0110 MOD REG RIM (DISP-LO),(DISP-HI) XCHG REG8,REG8/MEM8
87 1000 0111 MOD REG RIM (DISP-LO),(DISP-HI) XCHG REG16,REG16/MEM16
88 1000 1000 MOD REG RIM (DISP-LO),(DISP-HI) MOV REG8/MEM8,REG8
89 1000 1001 .MOD REG RIM (DISP-LO),(DISP-HI) MOV REG16/MEM16/REG16
8A 1000 1010 MOD REG RIM (DISP-LO),(DISP-HI) MOV REG8,REG8/MEM8
8B 1000 1011 MOD REG RIM (DISP-LO),(DISP-HI) MOV REG16,REG16/MEM16
8C 1000 1100 MODOSRR/M (DISP-LO),(DISP-HI) MOV REG16/MEM16,SEGREG·
8C 1000 1100 MOD1-R/M (not used)
8D 1000 1101 MOD REG RIM (DISP-LO),(DISP-HI) LEA REG16,MEM16
8E 1000 1110 MODOSRR/M (DISP-LO),(DISP-HI) MOV SEGREG,REG16/MEM16
8E 1000 1110 MOD1-R/M (not used)
8F 1000 1111 MOD 000 RIM (DISP-LO),(DISP-HI) POP REG16/MEM16
8F 1000 1111 MOD 001 RIM (not used)
8F 1000 1111 MOD 010 RIM (not used)


BF 1000 1111 MOD 011 RIM (not used)
BF 1000 1111 MOD100 RIM (not used)
BF 1000 1111 MOD 101 RIM (not used)
BF 1000 1111 MOD110 RIM (not used)
BF 1000 1111 MOD 111 RIM (not used)
90 1001 0000 NOP (exchange AX,AX)
91 1001 0001 XCHG AX,CX
92 1001 0010 XCHG AX,DX
93 1001 0011 XCHG AX,BX
94 1001 0100 XCHG AX,SP
95 1001 0101 XCHG AX,BP
96 1001 0110 XCHG AX,SI
97 1001 0111 XCHG AX,DI
9B 1001 1000 CBW
99 1001 1001 CWO
9A 1001 1010 DISP-LO DISP-HI,SEG-LO, CALL FAR_PROC
SEG-HI
9B 1001 1011 WAIT
9C 1001 1100 PUSHF
90 1001 1101 POPF
9E 1001 1110 SAHF
9F 1001 1111 LAHF
AD 1010 0000 ADDR-LO ADDR-HI MOV AL,MEMB
A1 1010 0001 ADDR-LO ADDR-HI MOV AX,MEM16
A2 1010 0010 ADDR-LO ADDR-HI MOV MEMB,AL
A3 1010 0011 ADDR-LO ADDR-HI MOV MEM16,AL
A4 1010 0100 MOVS DEST-STRB,SRC-STRB
A5 1010 0101 MOVS DEST -STR16,SRC-STR16
A6 1010 0110 CMPS DEST-STRB,SRC-STRB
A7 1010 0111 CMPS DEST-STR16,SRC-STR16
AB 1010 1000 DATA-B TEST AL,IMMEDB
A9 1010 1001 DATA-LO DATA-HI TEST AX,IMMED16
AA 1010 1010 STOS DEST-STAB
AB 1010 1011 STOS DEST-STR16
AC 1010 1100 LODS SRC-STAB
AO 1010 1101 LODS SRC-STR16
AE 1010 1110 SCAS DEST-STRB
AF 1010 1111 SCAS DEST-STR16
BO 1011 0000 DATA-B MOV AL,IMMEDB
B1 1011 0001 DATA-B MOV CL,IMMEDB
B2 1011 0010 DATA-B MOV DL,IMMEOB
B3 1011 1011 DATA-B MOV BL,IMMEDB
B4 . 1011 0100 DATA-B MOV AH,IMMEDB
B5 1011 0101 DATA-B MOV CH,IMMEDB
B6 1011 0110 DATA-B MOV DH,IMMEDB
B7 1011 0111 DATA-B MOV BH,IMMEDB
BB 1011 1000 DATA-LO DATA-HI MOV AX,IMMED16
B9 1011 1001 DATA-LO DATA-HI MOV CX,IMMED16
BA 1011 1010 DATA-LO DATA-HI MOV DX,IMMED16
BB 1011 1011 DATA-LO DATA-HI MOV BX,IMMED16


BC 1011 1100 DATA-LO DATA-HI MOV SP,IMMED16
BD 1011 1101 DATA-LO DATA-HI MOV BP,IMMED16
BE 1011 1110 DATA-LO DATA-HI MOV SI,IMMED16
BF 1011 1111 DATA-LO DATA-HI MOV DI,IMMED16
CO 1100 0000 (not used)
C1 1100 0001 (not used)
C2 1100 0010 DATA-LO DATA-HI RET IMMED16 (intraseg)
C3 1100 0011 RET (intrasegment)
C4 1100 0100 MOD REG RIM (DISP-LO),(DISP-HI) LES REG16,MEM16
C5 1100 0101 MOD REG RIM (DISP-LO),(DISP-HI) LOS REG16,MEM16
C6 1100 0110 MODOOO RIM (DISP-LO),(DISP-HI), MOV MEM8,IMMED8
. DATA-8
C6 1100 0110 MOD001 RIM . (not used)
C6 1100 0110 MOD010 RIM (not used)
C6 1100 0110 MOD 011 RIM (not used)
C6 1100 0110 MOD100 RIM (not used)
C6 1100 0110 MOD101 RIM (not used)
C6 1100 0110 MOD110 RIM (not used)
C6 1100 0110 MOD 111 RIM (not used)
C7 1100 0111 MODOOO RIM (DISP-LO),(DISP-HI), MOV MEM16,IMMED16
DATA-LO,DATA-HI
C7 1100 0111 MOD001 RIM (not used)
C7 1100 0111 MOD010 RIM (not used).
C7 1100 0111 MOD011 RIM (not used)
C7 1100 0111 MOD100 RIM (not used)
C7 1100 0111 MOD101R/M (not used)
C7 1100 0111 MOD 110 RIM (not used)
C7 1100 0111 MOD111 RIM (not used
C8 1100 1000 (not used)
C9 1100 1001 (not used)
CA 1100 1010 DATA-LO DATA-HI RET IMMED16 (intersegment)
CB 1100 1011 RET (intersegment)
CC 1100 1100 INT 3
CD 1100 1101 DATA-8 INT IMMED8
CE 1100 1110 INTO
CF 1100 1111 IRET
DO 1101 0000 MOD 000 RIM (DISP-LO),(DISP-HI) ROL REG8/MEM8,1
DO 1101 0000 MOD 001 RIM (DISP-LO),(DISP-HI) ROR REG8/MEM8,1
DO 1101 0000 MOD010 RIM (DISP-LO),(DISP-HI) RCL REG8/MEM8,1
DO 1101 0000 MOD011 RIM (DISP-LO),(DISP-HI) RCR REG8/MEM8,1
DO 1101 0000 MOD 100 RIM (DISP-LO),(DISP-HI) SALISHL REG8/MEM8,1
DO 1101 0000 MOD101 RIM (DISP-LO),(DISP-HI) SHR REG8/MEM8,1
DO 1101 0000 MOD110R/M (not used)
DO 1101 0000 MOD111 RIM (DISP-LO),(DISP-HI) SAR REG8/MEM8,1
01 1101 0001 MODOOOR/M (DISP-LO),(DISP-HI) ROL REG16/MEM16,1
01 1101 0001 MOD 001 RIM (DISP-LO),(DISP-HI) ROR REG16/MEM16,1
01 1101 0001 MOD 010 RIM (DISP-LO),(DISP-HI) RCL REG16/MEM16,1
01 1101 0001 MOD011 RIM (DISP-LO),(DISP-HI) RCR REG16/MEM16,1
01 1101 0001 MOD 100 RIM (DISP-LO),(DISP-HI) SALISHL REG16/MEM16,1
4


01 1101 0001 MOD101 RIM (DISP-LO),(DISP-HI) SHR REG16/MEM16,1
01 1101 0001 MOD 110 RIM (not used)
01 1101 0001 MOD111 RIM (DISP-LO),(DISP-HI) SAR REG16/MEM16,1
02 1101 0010 MOD 000 RIM . (DISP-LO),(DISP-HI) ROL REG8/MEM8,CL
02 1101 0010 MOD001 RIM (DISP-LO),(DISP-HI) ROR REG8/MEM8,CL
D2 1101 0010 MOD010 RIM (DISP~LO),(DISP~HI) RCL REG8/MEM8,CL
D2 1101 ·0010 MOD011 RIM (DISP-LO),(DISP-HI) RCR REG8/MEM8,CL
D2 1101 0010 MOD100 RIM (DISP-LO),(DISP-HI) SALISHL REG8/MEM8,CL
D2 1101 0010 MOD101 RIM (DISP-LO),(DISP-HI) SHR REG8/MEM8,CL
D2 1101 0010 MOD110 RIM (not used)
D2 1101 0010 MOD11t RIM (DISP-LO) ,(DISP-H I) SAR REG8/MEM8,CL
D3 1101 0011 MOD 000 RIM (DISP-LO),(DISP-HI) ROL REG16/MEM16,CL
D3 1101 0011 MOD 001 RIM (DISP-LO),(DISP-HI) ROR REG16/MEM16,CL
D3 1101 0011 MOD010 RIM (DISP-LO),(DISP-HI) RCL REG16/MEM16,CL
03 1101 0011 MOD011 RIM (DISP~LO),(DISP-HI) RCR REG16/MEM16,CL
03 1101 0011 MOD100 RIM (DISP-LO),(DISP-HI) SALISHL REG16/MEM16,CL
03 1101 0011 MOD101 RIM (DISP-LO),(DISP-HI) SHR REG16/MEM16,CL
03 1101 0011 MOD110 RIM (not used) .
03 1101 0011 MOD 111 RIM (DISP~LO),(DISP-HI) SAR REG16/MEM16,CL
04 1101 0100 00001010 AAM
D5 1101 0101 00001010 AAD
D6 1101 0110 (not used) .
D7 1101 0111 XLAT . SOURCE-TABLE
D8 1101 1000 MOD 000 RIM
1XXX MODYYYR/M (DISP-LO), (DISP-HI) ESC OPCODE;SOURCE
DF 1101 1111 MOD 111 RIM
EO 1110 0000 IP-INC-8 LOOPNEI SHORT~ABEL
LOOPNZ
E1 1110 0001 IP-INC-8 LOOPEI SHORT-LABEL
LOOPZ
E2 1110 0010 IP-INC-B LOOP SHORT-LABEL
E3 1110 0011 IP-INC-8 JCXZ SHORT-LABEL
E4 1110 0100 DATA-8 IN AL,IMMED8 . ,
E5 1110 0101 DATA-8 IN AX,IMMED8
E6 1110 0110 DATA-8 OUT AL,IMMED8
E7 1110 0111 DATA-8 OUT AX,IMMED8
E8 1110 1000 IP-INC-LO IP-INC-HI CALL . NEAR-PROC
E9 1110 1001 IP-INC-LO IP-INC-HI JMP NEAR-LABEL
EA 1110 1010 IP-LO I P-H I, CS-LO, CS-H I JMP FAR-LABEL
EB 1110 1011 IP-INC8 JMP . SHORT-LABEL
EC 1110 1100 IN AL,DX
ED 1110 1101 IN AX,DX
EE 1110 1110 OUT AL,DX
EF 1110 1111 OUT AX,DX
FO 1111 0000 LOCK (prefix)
F1 1111 0001 (not used)
F2 1111 0010 REPNEJREPNZ
F3 1111 0011 REP/REPE/REPZ
F4 1111 0100 HLT
F5 1111 0101 CMC


F6 1111 0110 MOD 000 RIM (DISP-LO),(DISP-HI), TEST REGBI M EMB,IM M EDB
DATA-B
F6 1111 0110 MOD 001 RIM (not used)
F6 1111 0110 MOD010 RIM (DISP-LO),(DISP-HI) NOT REGB/MEMB
F6 1111 0110 MOD011 RIM (DISP-LO),(DISP-HI) NEG REGB/MEMB
F6 1111 0110 MOD100 RIM (DISP-LO) ,(DISP-H I) MUL REGB/MEMB
F6 1111 0110 MOD101 RIM (DISP-LO),(DISP-HI) IMUL REGB/MEMB
F6 1111 0110 MOD110 RIM (DISP-LO),(DISP-HI) DIV REGB/MEMB
F6 1111 0110 MOD 111 RIM (DISP-LO),(DISP-HI) IDIV REGB/MEMB
F7 1111 0111 MODOOOR/M (DISP-LO),(DISP-HI), TEST REG16/MEM16.IMMED16
DATA-LO,DATA-HI
F7 1111 0111 MOD 001 RIM (not used)
F7 1111 0111 MOD010R/M (DISP-LO),(DISP-HI) NOT REG16/MEM16
F7 1111 0111 MOD011 RIM (DISP-LO),(DISP-HI) NEG REG16/MEM16
F7 1111 0111 MOD100 RIM (DISP-LO),(DISP-HI) MUL REG16/MEM16
F7 1111 0111 MOD101 RIM (DISP-LO),(DISP-HI) IMUL REG16/MEM16
F7 1111 0111 MOD110 RIM (DISP-LO),(DISP-HI) DIV REG16/MEM16
F7 1111 0111 MOD111 RIM (DISP-LO),(DISP-HI) IDIV REG16/MEM16
FB 1111 1000 CLC
F9 1111 1001 STC
FA 1111 1010 CLI
FB 1111 1,011 STI
FC 1111 1100 CLD
FD 1111 1101 STD
FE 1111 1110 MOD 000 RIM (DISP-LO),(DISP-HI) INC REGB/MEMB
FE 1111 1110 MOD 001 RIM (DISP-LO),(DISP-HI) DEC REGB/MEMB
FE 1111 1110 MOD010R/M (not used)
FE 1111 1110 MOD011 RIM (not used)
FE 1111 1110 MOD100R/M (not used)
FE 1111 1110 MOD101 RIM (not used)
FE 1111 1110 MOD110R/M (not used)
FE 1111 1110 MOD111 RIM (not used)
FF 1111 1111 MODOOOR/M (DISP-LO),(DISP-HI) INC MEM16
FF 1111 1111 MOD 001 RIM (DISP-LO).(DISP-HI) DEC MEM16
FF 1111 1111 MOD010 RIM (DISP-LO),(DISP-HI) CALL REG16/MEM16 (intra)
FF 1111 1111 MOD011 RIM (DISP-LO),(DISP-HI) CALL MEM16 (intersegment)
FF 1111 1111 MOD100 RIM (DISP-LO),(DISP-HI) JMP REG16/MEM16 (intra)
FF 1111 1111 MOD101 RIM (DISP-LO).(DISP-HI) JMP MEM16 (intersegment)
FF 1111 1111 MOD 110 RIM (DISP-LO).(DISP-HI) PUSH MEM16
FF 1111 1111 MOD 111 RIM (not used)
