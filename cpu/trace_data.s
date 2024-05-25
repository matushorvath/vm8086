.EXPORT trace_data

# these labels just serve as unique (pointer) values
.EXPORT mrr
mrr: db  0          # MOD REG R/M

.EXPORT msr
msr: db  0          # MOD 1SR R/M

.EXPORT m0r
m0r: db  0          # MOD 000 R/M

.EXPORT mo1
mo1: db  0          # MOD op1 R/M

.EXPORT mo2
mo2: db  0          # MOD op2 R/M

.EXPORT mo3
mo3: db  0          # MOD op3 R/M

.EXPORT mo4
mo4: db  0          # MOD op4 R/M

.EXPORT mer
mer: db  0          # MOD esc R/M

.EXPORT dpl
dpl: db  0          # DISP-LO

.EXPORT dph
dph: db  0          # DISP-HI

.EXPORT dat
dat: db  0          # DATA-8

.EXPORT dsx
dsx: db  0          # DATA-SX

.EXPORT dtl
dtl: db  0          # DATA-LO

.EXPORT dth
dth: db  0          # DATA-HI

.EXPORT ip8
ip8: db  0          # IP-INC-8

.EXPORT ipl
ipl: db  0          # IP-INC-LO

.EXPORT iph
iph: db  0          # IP-INC-HI

.EXPORT ofl
ofl: db  0          # OFFSET-LO

.EXPORT ofh
ofh: db  0          # OFFSET-HI

.EXPORT sgl
sgl: db  0          # SEGMENT-LO

.EXPORT sgh
sgh: db  0          # SEGMENT-HI

trace_data:
    db  in_00, mrr, dpl, dph,   0,   0,   0           # ADD REG8/MEM8, REG8
    db  in_01, mrr, dpl, dph,   0,   0,   0           # ADD REG16/MEM16, REG16
    db  in_02, mrr, dpl, dph,   0,   0,   0           # ADD REG8, REG8/MEM8
    db  in_03, mrr, dpl, dph,   0,   0,   0           # ADD REG16, REG16/MEM16
    db  in_04, dat,   0,   0,   0,   0,   0           # ADD AL, IMMED8
    db  in_05, dtl, dth,   0,   0,   0,   0           # ADD AX, IMMED16
    db  in_06,   0,   0,   0,   0,   0,   0           # PUSH ES
    db  in_07,   0,   0,   0,   0,   0,   0           # POP ES

    db  in_08, mrr, dpl, dph,   0,   0,   0           # OR REG8/MEM8, REG8
    db  in_09, mrr, dpl, dph,   0,   0,   0           # OR REG16/MEM16, REG16
    db  in_0a, mrr, dpl, dph,   0,   0,   0           # OR REG8, REG8/MEM8
    db  in_0b, mrr, dpl, dph,   0,   0,   0           # OR REG16, REG16/MEM16
    db  in_0c, dat,   0,   0,   0,   0,   0           # OR AL, IMMED8
    db  in_0d, dtl, dth,   0,   0,   0,   0           # OR AX, IMMED16
    db  in_0e,   0,   0,   0,   0,   0,   0           # PUSH CS
    db  in_0f,   0,   0,   0,   0,   0,   0

    db  in_10, mrr, dpl, dph,   0,   0,   0           # ADC REG8/MEM8, REG8
    db  in_11, mrr, dpl, dph,   0,   0,   0           # ADC REG16/MEM16, REG16
    db  in_12, mrr, dpl, dph,   0,   0,   0           # ADC REG8, REG8/MEM8
    db  in_13, mrr, dpl, dph,   0,   0,   0           # ADC REG16, REG16/MEM16
    db  in_14, dat,   0,   0,   0,   0,   0           # ADC AL, IMMED8
    db  in_15, dtl, dth,   0,   0,   0,   0           # ADC AX, IMMED16
    db  in_16,   0,   0,   0,   0,   0,   0           # PUSH SS
    db  in_17,   0,   0,   0,   0,   0,   0           # POP SS

    db  in_18, mrr, dpl, dph,   0,   0,   0           # SBB REG8/MEM8, REG8
    db  in_19, mrr, dpl, dph,   0,   0,   0           # SBB REG16/MEM16, REG16
    db  in_1a, mrr, dpl, dph,   0,   0,   0           # SBB REG8, REG8/MEM8
    db  in_1b, mrr, dpl, dph,   0,   0,   0           # SBB REG16, REG16/MEM16
    db  in_1c, dat,   0,   0,   0,   0,   0           # SBB AL, IMMED8
    db  in_1d, dtl, dth,   0,   0,   0,   0           # SBB AX, IMMED16
    db  in_1e,   0,   0,   0,   0,   0,   0           # PUSH DS
    db  in_1f,   0,   0,   0,   0,   0,   0           # POP DS

    db  in_20, mrr, dpl, dph,   0,   0,   0           # AND REG8/MEM8, REG8
    db  in_21, mrr, dpl, dph,   0,   0,   0           # AND REG16/MEM16, REG16
    db  in_22, mrr, dpl, dph,   0,   0,   0           # AND REG8, REG8/MEM8
    db  in_23, mrr, dpl, dph,   0,   0,   0           # AND REG16, REG16/MEM16
    db  in_24, dat,   0,   0,   0,   0,   0           # AND AL, IMMED8
    db  in_25, dtl, dth,   0,   0,   0,   0           # AND AX, IMMED16
    db  in_26,   0,   0,   0,   0,   0,   0           # ES:
    db  in_27,   0,   0,   0,   0,   0,   0           # DAA

    db  in_28, mrr, dpl, dph,   0,   0,   0           # SUB REG8/MEM8, REG8
    db  in_29, mrr, dpl, dph,   0,   0,   0           # SUB REG16/MEM16, REG16
    db  in_2a, mrr, dpl, dph,   0,   0,   0           # SUB REG8, REG8/MEM8
    db  in_2b, mrr, dpl, dph,   0,   0,   0           # SUB REG16, REG16/MEM16
    db  in_2c, dat,   0,   0,   0,   0,   0           # SUB AL, IMMED8
    db  in_2d, dtl, dth,   0,   0,   0,   0           # SUB AX, IMMED16
    db  in_2e,   0,   0,   0,   0,   0,   0           # CS:
    db  in_2f,   0,   0,   0,   0,   0,   0           # DAS

    db  in_30, mrr, dpl, dph,   0,   0,   0           # XOR REG8/MEM8, REG8
    db  in_31, mrr, dpl, dph,   0,   0,   0           # XOR REG16/MEM16, REG16
    db  in_32, mrr, dpl, dph,   0,   0,   0           # XOR REG8, REG8/MEM8
    db  in_33, mrr, dpl, dph,   0,   0,   0           # XOR REG16, REG16/MEM16
    db  in_34, dat,   0,   0,   0,   0,   0           # XOR AL, IMMED8
    db  in_35, dtl, dth,   0,   0,   0,   0           # XOR AX, IMMED16
    db  in_36,   0,   0,   0,   0,   0,   0           # SS:
    db  in_37,   0,   0,   0,   0,   0,   0           # AAA

    db  in_38, mrr, dpl, dph,   0,   0,   0           # CMP REG8/MEM8, REG8
    db  in_39, mrr, dpl, dph,   0,   0,   0           # CMP REG16/MEM16, REG16
    db  in_3a, mrr, dpl, dph,   0,   0,   0           # CMP REG8, REG8/MEM8
    db  in_3b, mrr, dpl, dph,   0,   0,   0           # CMP REG16, REG16/MEM16
    db  in_3c, dat,   0,   0,   0,   0,   0           # CMP AL, IMMED8
    db  in_3d, dtl, dth,   0,   0,   0,   0           # CMP AX, IMMED16
    db  in_3e,   0,   0,   0,   0,   0,   0           # DS:
    db  in_3f,   0,   0,   0,   0,   0,   0           # AAS

    db  in_40,   0,   0,   0,   0,   0,   0           # INC AX
    db  in_41,   0,   0,   0,   0,   0,   0           # INC CX
    db  in_42,   0,   0,   0,   0,   0,   0           # INC DX
    db  in_43,   0,   0,   0,   0,   0,   0           # INC BX
    db  in_44,   0,   0,   0,   0,   0,   0           # INC SP
    db  in_45,   0,   0,   0,   0,   0,   0           # INC BP
    db  in_46,   0,   0,   0,   0,   0,   0           # INC SI
    db  in_47,   0,   0,   0,   0,   0,   0           # INC DI

    db  in_48,   0,   0,   0,   0,   0,   0           # DEC AX
    db  in_49,   0,   0,   0,   0,   0,   0           # DEC CX
    db  in_4a,   0,   0,   0,   0,   0,   0           # DEC DX
    db  in_4b,   0,   0,   0,   0,   0,   0           # DEC BX
    db  in_4c,   0,   0,   0,   0,   0,   0           # DEC SP
    db  in_4d,   0,   0,   0,   0,   0,   0           # DEC BP
    db  in_4e,   0,   0,   0,   0,   0,   0           # DEC SI
    db  in_4f,   0,   0,   0,   0,   0,   0           # DEC DI

    db  in_50,   0,   0,   0,   0,   0,   0           # PUSH AX
    db  in_51,   0,   0,   0,   0,   0,   0           # PUSH CX
    db  in_52,   0,   0,   0,   0,   0,   0           # PUSH DX
    db  in_53,   0,   0,   0,   0,   0,   0           # PUSH BX
    db  in_54,   0,   0,   0,   0,   0,   0           # PUSH SP
    db  in_55,   0,   0,   0,   0,   0,   0           # PUSH BP
    db  in_56,   0,   0,   0,   0,   0,   0           # PUSH SI
    db  in_57,   0,   0,   0,   0,   0,   0           # PUSH DI

    db  in_58,   0,   0,   0,   0,   0,   0           # POP AX
    db  in_59,   0,   0,   0,   0,   0,   0           # POP CX
    db  in_5a,   0,   0,   0,   0,   0,   0           # POP DX
    db  in_5b,   0,   0,   0,   0,   0,   0           # POP BX
    db  in_5c,   0,   0,   0,   0,   0,   0           # POP SP
    db  in_5d,   0,   0,   0,   0,   0,   0           # POP BP
    db  in_5e,   0,   0,   0,   0,   0,   0           # POP SI
    db  in_5f,   0,   0,   0,   0,   0,   0           # POP DI

    db  in_60,   0,   0,   0,   0,   0,   0
    db  in_61,   0,   0,   0,   0,   0,   0
    db  in_62,   0,   0,   0,   0,   0,   0
    db  in_63,   0,   0,   0,   0,   0,   0
    db  in_64,   0,   0,   0,   0,   0,   0
    db  in_65,   0,   0,   0,   0,   0,   0
    db  in_66,   0,   0,   0,   0,   0,   0
    db  in_67,   0,   0,   0,   0,   0,   0

    db  in_68,   0,   0,   0,   0,   0,   0
    db  in_69,   0,   0,   0,   0,   0,   0
    db  in_6a,   0,   0,   0,   0,   0,   0
    db  in_6b,   0,   0,   0,   0,   0,   0
    db  in_6c,   0,   0,   0,   0,   0,   0
    db  in_6d,   0,   0,   0,   0,   0,   0
    db  in_6e,   0,   0,   0,   0,   0,   0
    db  in_6f,   0,   0,   0,   0,   0,   0

    db  in_70, ip8,   0,   0,   0,   0,   0           # JO SHORT-LABEL
    db  in_71, ip8,   0,   0,   0,   0,   0           # JNO SHORT-LABEL
    db  in_72, ip8,   0,   0,   0,   0,   0           # JB/JNAEI/JC SHORT-LABEL
    db  in_73, ip8,   0,   0,   0,   0,   0           # JNB/JAEI/JNC SHORT-LABEL
    db  in_74, ip8,   0,   0,   0,   0,   0           # JE/JZ SHORT-LABEL
    db  in_75, ip8,   0,   0,   0,   0,   0           # JNE/JNZ SHORT-LABEL
    db  in_76, ip8,   0,   0,   0,   0,   0           # JBE/JNA SHORT-LABEL
    db  in_77, ip8,   0,   0,   0,   0,   0           # JNBE/JA SHORT-LABEL

    db  in_78, ip8,   0,   0,   0,   0,   0           # JS SHORT-LABEL
    db  in_79, ip8,   0,   0,   0,   0,   0           # JNS SHORT-LABEL
    db  in_7a, ip8,   0,   0,   0,   0,   0           # JP/JPE SHORT-LABEL
    db  in_7b, ip8,   0,   0,   0,   0,   0           # JNP/JPO SHORT-LABEL
    db  in_7c, ip8,   0,   0,   0,   0,   0           # JL/JNGE SHORT-LABEL
    db  in_7d, ip8,   0,   0,   0,   0,   0           # JNL/JGE SHORT-LABEL
    db  in_7e, ip8,   0,   0,   0,   0,   0           # JLE/JNG SHORT-LABEL
    db  in_7f, ip8,   0,   0,   0,   0,   0           # JNLE/JG SHORT-LABEL

    db  in_80, mo1, dpl, dph, dat,   0,   0           # ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8
    db  in_81, mo1, dpl, dph, dtl, dth,   0           # ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG16/MEM16, IMMED16
    db  in_82, mo1, dpl, dph, dat,   0,   0           # ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8
    db  in_83, mo1, dpl, dph, dsx,   0,   0           # ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG16/MEM16, IMMED8
    db  in_84, mrr, dpl, dph,   0,   0,   0           # TEST REG8/MEM8, REG8
    db  in_85, mrr, dpl, dph,   0,   0,   0           # TEST REG16/MEM16, REG16
    db  in_86, mrr, dpl, dph,   0,   0,   0           # XCHG REG8, REG8/MEM8
    db  in_87, mrr, dpl, dph,   0,   0,   0           # XCHG REG16, REG16/MEM16

    db  in_88, mrr, dpl, dph,   0,   0,   0           # MOV REG8/MEM8, REG8
    db  in_89, mrr, dpl, dph,   0,   0,   0           # MOV REG16/MEM16, REG16
    db  in_8a, mrr, dpl, dph,   0,   0,   0           # MOV REG8, REG8/MEM8
    db  in_8b, mrr, dpl, dph,   0,   0,   0           # MOV REG16, REG16/MEM16
    db  in_8c, msr, dpl, dph,   0,   0,   0           # MOV REG16/MEM16, SEGREG
    db  in_8d, mrr, dpl, dph,   0,   0,   0           # LEA REG16, MEM16
    db  in_8e, msr, dpl, dph,   0,   0,   0           # MOV SEGREG, REG16/MEM16
    db  in_8f, m0r, dpl, dph,   0,   0,   0           # POP REG16/MEM16

    db  in_90,   0,   0,   0,   0,   0,   0           # NOP
    db  in_91,   0,   0,   0,   0,   0,   0           # XCHG AX, CX
    db  in_92,   0,   0,   0,   0,   0,   0           # XCHG AX, DX
    db  in_93,   0,   0,   0,   0,   0,   0           # XCHG AX, BX
    db  in_94,   0,   0,   0,   0,   0,   0           # XCHG AX, SP
    db  in_95,   0,   0,   0,   0,   0,   0           # XCHG AX, BP
    db  in_96,   0,   0,   0,   0,   0,   0           # XCHG AX, SI
    db  in_97,   0,   0,   0,   0,   0,   0           # XCHG AX, DI

    db  in_98,   0,   0,   0,   0,   0,   0           # CBW
    db  in_99,   0,   0,   0,   0,   0,   0           # CWD
    db  in_9a, ofl, ofh, sgl, sgh,   0,   0           # CALL FAR-PROC
    db  in_9b,   0,   0,   0,   0,   0,   0           # WAIT
    db  in_9c,   0,   0,   0,   0,   0,   0           # PUSHF
    db  in_9d,   0,   0,   0,   0,   0,   0           # POPF
    db  in_9e,   0,   0,   0,   0,   0,   0           # SAHF
    db  in_9f,   0,   0,   0,   0,   0,   0           # LAHF

    db  in_a0, ofl, ofh,   0,   0,   0,   0           # MOV AL, MEM8
    db  in_a1, ofl, ofh,   0,   0,   0,   0           # MOV AX, MEM16
    db  in_a2, ofl, ofh,   0,   0,   0,   0           # MOV MEM8, AL
    db  in_a3, ofl, ofh,   0,   0,   0,   0           # MOV MEM16, AX
    db  in_a4,   0,   0,   0,   0,   0,   0           # MOVS DEST-STR8, SRC-STR8
    db  in_a5,   0,   0,   0,   0,   0,   0           # MOVS DEST-STR16, SRC-STR16
    db  in_a6,   0,   0,   0,   0,   0,   0           # CMPS DEST-STR8, SRC-STR8
    db  in_a7,   0,   0,   0,   0,   0,   0           # CMPS DEST-STR16, SRC-STR16

    db  in_a8, dat,   0,   0,   0,   0,   0           # TEST AL, IMMED8
    db  in_a9, dtl, dth,   0,   0,   0,   0           # TEST AX, IMMED16
    db  in_aa,   0,   0,   0,   0,   0,   0           # STOS DEST-STR8
    db  in_ab,   0,   0,   0,   0,   0,   0           # STOS DEST-STR16
    db  in_ac,   0,   0,   0,   0,   0,   0           # LODS SRC-STR8
    db  in_ad,   0,   0,   0,   0,   0,   0           # LODS SRC-STR16
    db  in_ae,   0,   0,   0,   0,   0,   0           # SCAS DEST-STR8
    db  in_af,   0,   0,   0,   0,   0,   0           # SCAS DEST-STR16

    db  in_b0, dat,   0,   0,   0,   0,   0           # MOV AL, IMMED8
    db  in_b1, dat,   0,   0,   0,   0,   0           # MOV CL, IMMED8
    db  in_b2, dat,   0,   0,   0,   0,   0           # MOV DL, IMMED8
    db  in_b3, dat,   0,   0,   0,   0,   0           # MOV BL, IMMED8
    db  in_b4, dat,   0,   0,   0,   0,   0           # MOV AH, IMMED8
    db  in_b5, dat,   0,   0,   0,   0,   0           # MOV CH, IMMED8
    db  in_b6, dat,   0,   0,   0,   0,   0           # MOV DH, IMMED8
    db  in_b7, dat,   0,   0,   0,   0,   0           # MOV BH, IMMED8

    db  in_b8, dtl, dth,   0,   0,   0,   0           # MOV AX, IMMED16
    db  in_b9, dtl, dth,   0,   0,   0,   0           # MOV CX, IMMED16
    db  in_ba, dtl, dth,   0,   0,   0,   0           # MOV DX, IMMED16
    db  in_bb, dtl, dth,   0,   0,   0,   0           # MOV BX, IMMED16
    db  in_bc, dtl, dth,   0,   0,   0,   0           # MOV SP, IMMED16
    db  in_bd, dtl, dth,   0,   0,   0,   0           # MOV BP, IMMED16
    db  in_be, dtl, dth,   0,   0,   0,   0           # MOV SI, IMMED16
    db  in_bf, dtl, dth,   0,   0,   0,   0           # MOV DI, IMMED16

    db  in_c0,   0,   0,   0,   0,   0,   0
    db  in_c1,   0,   0,   0,   0,   0,   0
    db  in_c2, dtl, dth,   0,   0,   0,   0           # RETN IMMED16
    db  in_c3,   0,   0,   0,   0,   0,   0           # RETF
    db  in_c4, mrr, dpl, dph,   0,   0,   0           # LES REG16, MEM16
    db  in_c5, mrr, dpl, dph,   0,   0,   0           # LDS REG16, MEM16
    db  in_c6, m0r, dpl, dph, dat,   0,   0           # MOV MEM8, IMMED8
    db  in_c7, m0r, dpl, dph, dtl, dth,   0           # MOV MEM16, IMMED16

    db  in_c8,   0,   0,   0,   0,   0,   0
    db  in_c9,   0,   0,   0,   0,   0,   0
    db  in_ca, dtl, dth,   0,   0,   0,   0           # RETF IMMED16
    db  in_cb,   0,   0,   0,   0,   0,   0           # RETF
    db  in_cc,   0,   0,   0,   0,   0,   0           # INT 3
    db  in_cd, dat,   0,   0,   0,   0,   0           # INT IMMED8
    db  in_ce,   0,   0,   0,   0,   0,   0           # INTO
    db  in_cf,   0,   0,   0,   0,   0,   0           # IRET

    db  in_d0, mo2, dpl, dph,   0,   0,   0           # ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1
    db  in_d1, mo2, dpl, dph,   0,   0,   0           # ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, 1
    db  in_d2, mo2, dpl, dph,   0,   0,   0           # ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, CL
    db  in_d3, mo2, dpl, dph,   0,   0,   0           # ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, CL
    db  in_d4,   0,   0,   0,   0,   0,   0           # AAM
    db  in_d5,   0,   0,   0,   0,   0,   0           # AAD
    db  in_d6,   0,   0,   0,   0,   0,   0
    db  in_d7,   0,   0,   0,   0,   0,   0           # XLAT SOURCE-TABLE

    db  in_d8, mer,   0,   0,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_d9, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_da, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_db, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_dc, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_dd, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_de, mer, dpl, dph,   0,   0,   0           # ESC OPCODE, SOURCE
    db  in_df, mer,   0,   0,   0,   0,   0           # ESC OPCODE, SOURCE

    db  in_e0, ip8,   0,   0,   0,   0,   0           # LOOPNZ SHORT-LABEL
    db  in_e1, ip8,   0,   0,   0,   0,   0           # LOOPZ SHORT-LABEL
    db  in_e2, ip8,   0,   0,   0,   0,   0           # LOOP SHORT-LABEL
    db  in_e3, ip8,   0,   0,   0,   0,   0           # JCXZ SHORT-LABEL
    db  in_e4, dat,   0,   0,   0,   0,   0           # IN AL, IMMED8
    db  in_e5, dat,   0,   0,   0,   0,   0           # IN AX, IMMED8
    db  in_e6, dat,   0,   0,   0,   0,   0           # OUT AL, IMMED8
    db  in_e7, dat,   0,   0,   0,   0,   0           # OUT AX, IMMED8

    db  in_e8, ipl, iph,   0,   0,   0,   0           # CALL NEAR-PROC
    db  in_e9, ipl, iph,   0,   0,   0,   0           # JMP NEAR-LABEL
    db  in_ea, ofl, ofh, sgl, sgh,   0,   0           # JMP FAR-LABEL
    db  in_eb, ip8,   0,   0,   0,   0,   0           # JMP SHORT-LABEL
    db  in_ec,   0,   0,   0,   0,   0,   0           # IN AL, DX
    db  in_ed,   0,   0,   0,   0,   0,   0           # IN AX, DX
    db  in_ee,   0,   0,   0,   0,   0,   0           # OUT AL, DX
    db  in_ef,   0,   0,   0,   0,   0,   0           # OUT AX, DX

    db  in_f0,   0,   0,   0,   0,   0,   0           # LOCK
    db  in_f1,   0,   0,   0,   0,   0,   0
    db  in_f2,   0,   0,   0,   0,   0,   0           # REPNZ
    db  in_f3,   0,   0,   0,   0,   0,   0           # REPZ
    db  in_f4,   0,   0,   0,   0,   0,   0           # HLT
    db  in_f5,   0,   0,   0,   0,   0,   0           # CMC
    db  in_f6, mo3, dpl, dph, dat,   0,   0           # TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG8/MEM8 (IMMED8)
    db  in_f7, mo3, dpl, dph, dtl, dth,   0           # TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG16/MEM16 (IMMED8)

    db  in_f8,   0,   0,   0,   0,   0,   0           # CLC
    db  in_f9,   0,   0,   0,   0,   0,   0           # STC
    db  in_fa,   0,   0,   0,   0,   0,   0           # CLI
    db  in_fb,   0,   0,   0,   0,   0,   0           # STI
    db  in_fc,   0,   0,   0,   0,   0,   0           # CLD
    db  in_fd,   0,   0,   0,   0,   0,   0           # STD
    db  in_fe, mo4, dpl, dph,   0,   0,   0           # INC/DEC REG8/MEM8
    db  in_ff, mo4, dpl, dph,   0,   0,   0           # INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16

in_00: db "ADD REG8/MEM8, REG8", 0
in_01: db "ADD REG16/MEM16, REG16", 0
in_02: db "ADD REG8, REG8/MEM8", 0
in_03: db "ADD REG16, REG16/MEM16", 0
in_04: db "ADD AL, IMMED8", 0
in_05: db "ADD AX, IMMED16", 0
in_06: db "PUSH ES", 0
in_07: db "POP ES", 0

in_08: db "OR REG8/MEM8, REG8", 0
in_09: db "OR REG16/MEM16, REG16", 0
in_0a: db "OR REG8, REG8/MEM8", 0
in_0b: db "OR REG16, REG16/MEM16", 0
in_0c: db "OR AL, IMMED8", 0
in_0d: db "OR AX, IMMED16", 0
in_0e: db "PUSH CS", 0
in_0f: db "(invalid)", 0

in_10: db "ADC REG8/MEM8, REG8", 0
in_11: db "ADC REG16/MEM16, REG16", 0
in_12: db "ADC REG8, REG8/MEM8", 0
in_13: db "ADC REG16, REG16/MEM16", 0
in_14: db "ADC AL, IMMED8", 0
in_15: db "ADC AX, IMMED16", 0
in_16: db "PUSH SS", 0
in_17: db "POP SS", 0

in_18: db "SBB REG8/MEM8, REG8", 0
in_19: db "SBB REG16/MEM16, REG16", 0
in_1a: db "SBB REG8, REG8/MEM8", 0
in_1b: db "SBB REG16, REG16/MEM16", 0
in_1c: db "SBB AL, IMMED8", 0
in_1d: db "SBB AX, IMMED16", 0
in_1e: db "PUSH DS", 0
in_1f: db "POP DS", 0

in_20: db "AND REG8/MEM8, REG8", 0
in_21: db "AND REG16/MEM16, REG16", 0
in_22: db "AND REG8, REG8/MEM8", 0
in_23: db "AND REG16, REG16/MEM16", 0
in_24: db "AND AL, IMMED8", 0
in_25: db "AND AX, IMMED16", 0
in_26: db "ES:", 0
in_27: db "DAA", 0

in_28: db "SUB REG8/MEM8, REG8", 0
in_29: db "SUB REG16/MEM16, REG16", 0
in_2a: db "SUB REG8, REG8/MEM8", 0
in_2b: db "SUB REG16, REG16/MEM16", 0
in_2c: db "SUB AL, IMMED8", 0
in_2d: db "SUB AX, IMMED16", 0
in_2e: db "CS:", 0
in_2f: db "DAS", 0

in_30: db "XOR REG8/MEM8, REG8", 0
in_31: db "XOR REG16/MEM16, REG16", 0
in_32: db "XOR REG8, REG8/MEM8", 0
in_33: db "XOR REG16, REG16/MEM16", 0
in_34: db "XOR AL, IMMED8", 0
in_35: db "XOR AX, IMMED16", 0
in_36: db "SS:", 0
in_37: db "AAA", 0

in_38: db "CMP REG8/MEM8, REG8", 0
in_39: db "CMP REG16/MEM16, REG16", 0
in_3a: db "CMP REG8, REG8/MEM8", 0
in_3b: db "CMP REG16, REG16/MEM16", 0
in_3c: db "CMP AL, IMMED8", 0
in_3d: db "CMP AX, IMMED16", 0
in_3e: db "DS:", 0
in_3f: db "AAS", 0

in_40: db "INC AX", 0
in_41: db "INC CX", 0
in_42: db "INC DX", 0
in_43: db "INC BX", 0
in_44: db "INC SP", 0
in_45: db "INC BP", 0
in_46: db "INC SI", 0
in_47: db "INC DI", 0

in_48: db "DEC AX", 0
in_49: db "DEC CX", 0
in_4a: db "DEC DX", 0
in_4b: db "DEC BX", 0
in_4c: db "DEC SP", 0
in_4d: db "DEC BP", 0
in_4e: db "DEC SI", 0
in_4f: db "DEC DI", 0

in_50: db "PUSH AX", 0
in_51: db "PUSH CX", 0
in_52: db "PUSH DX", 0
in_53: db "PUSH BX", 0
in_54: db "PUSH SP", 0
in_55: db "PUSH BP", 0
in_56: db "PUSH SI", 0
in_57: db "PUSH DI", 0

in_58: db "POP AX", 0
in_59: db "POP CX", 0
in_5a: db "POP DX", 0
in_5b: db "POP BX", 0
in_5c: db "POP SP", 0
in_5d: db "POP BP", 0
in_5e: db "POP SI", 0
in_5f: db "POP DI", 0

in_60: db "(invalid)", 0
in_61: db "(invalid)", 0
in_62: db "(invalid)", 0
in_63: db "(invalid)", 0
in_64: db "(invalid)", 0
in_65: db "(invalid)", 0
in_66: db "(invalid)", 0
in_67: db "(invalid)", 0

in_68: db "(invalid)", 0
in_69: db "(invalid)", 0
in_6a: db "(invalid)", 0
in_6b: db "(invalid)", 0
in_6c: db "(invalid)", 0
in_6d: db "(invalid)", 0
in_6e: db "(invalid)", 0
in_6f: db "(invalid)", 0

in_70: db "JO SHORT-LABEL", 0
in_71: db "JNO SHORT-LABEL", 0
in_72: db "JC SHORT-LABEL", 0
in_73: db "JNC SHORT-LABEL", 0
in_74: db "JZ SHORT-LABEL", 0
in_75: db "JNZ SHORT-LABEL", 0
in_76: db "JNA SHORT-LABEL", 0
in_77: db "JA SHORT-LABEL", 0

in_78: db "JS SHORT-LABEL", 0
in_79: db "JNS SHORT-LABEL", 0
in_7a: db "JP SHORT-LABEL", 0
in_7b: db "JNP SHORT-LABEL", 0
in_7c: db "JL SHORT-LABEL", 0
in_7d: db "JNL SHORT-LABEL", 0
in_7e: db "JNG SHORT-LABEL", 0
in_7f: db "JG SHORT-LABEL", 0

in_80: db "ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8", 0
in_81: db "ADD/OR/ADC/SBB/AND/SUB/XOR/CMP", " REG16/MEM16, IMMED16", 0
in_82: db "ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8", 0
in_83: db "ADD/OR/ADC/SBB/AND/SUB/XOR/CMP", " REG16/MEM16, IMMED8", 0
in_84: db "TEST REG8/MEM8, REG8", 0
in_85: db "TEST REG16/MEM16, REG16", 0
in_86: db "XCHG REG8, REG8/MEM8", 0
in_87: db "XCHG REG16, REG16/MEM16", 0

in_88: db "MOV REG8/MEM8, REG8", 0
in_89: db "MOV REG16/MEM16, REG16", 0
in_8a: db "MOV REG8, REG8/MEM8", 0
in_8b: db "MOV REG16, REG16/MEM16", 0
in_8c: db "MOV REG16/MEM16, SEGREG", 0
in_8d: db "LEA REG16, MEM16", 0
in_8e: db "MOV SEGREG, REG16/MEM16", 0
in_8f: db "POP REG16/MEM16", 0

in_90: db "NOP", 0
in_91: db "XCHG AX, CX", 0
in_92: db "XCHG AX, DX", 0
in_93: db "XCHG AX, BX", 0
in_94: db "XCHG AX, SP", 0
in_95: db "XCHG AX, BP", 0
in_96: db "XCHG AX, SI", 0
in_97: db "XCHG AX, DI", 0

in_98: db "CBW", 0
in_99: db "CWD", 0
in_9a: db "CALL FAR-PROC", 0
in_9b: db "WAIT", 0
in_9c: db "PUSHF", 0
in_9d: db "POPF", 0
in_9e: db "SAHF", 0
in_9f: db "LAHF", 0

in_a0: db "MOV AL, MEM8", 0
in_a1: db "MOV AX, MEM16", 0
in_a2: db "MOV MEM8, AL", 0
in_a3: db "MOV MEM16, AX", 0
in_a4: db "MOVS DEST-STR8, SRC-STR8", 0
in_a5: db "MOVS DEST-STR16, SRC-STR16", 0
in_a6: db "CMPS DEST-STR8, SRC-STR8", 0
in_a7: db "CMPS DEST-STR16, SRC-STR16", 0

in_a8: db "TEST AL, IMMED8", 0
in_a9: db "TEST AX, IMMED16", 0
in_aa: db "STOS DEST-STR8", 0
in_ab: db "STOS DEST-STR16", 0
in_ac: db "LODS SRC-STR8", 0
in_ad: db "LODS SRC-STR16", 0
in_ae: db "SCAS DEST-STR8", 0
in_af: db "SCAS DEST-STR16", 0

in_b0: db "MOV AL, IMMED8", 0
in_b1: db "MOV CL, IMMED8", 0
in_b2: db "MOV DL, IMMED8", 0
in_b3: db "MOV BL, IMMED8", 0
in_b4: db "MOV AH, IMMED8", 0
in_b5: db "MOV CH, IMMED8", 0
in_b6: db "MOV DH, IMMED8", 0
in_b7: db "MOV BH, IMMED8", 0

in_b8: db "MOV AX, IMMED16", 0
in_b9: db "MOV CX, IMMED16", 0
in_ba: db "MOV DX, IMMED16", 0
in_bb: db "MOV BX, IMMED16", 0
in_bc: db "MOV SP, IMMED16", 0
in_bd: db "MOV BP, IMMED16", 0
in_be: db "MOV SI, IMMED16", 0
in_bf: db "MOV DI, IMMED16", 0

in_c0: db "(invalid)", 0
in_c1: db "(invalid)", 0
in_c2: db "RETN IMMED16", 0
in_c3: db "RETN", 0
in_c4: db "LES REG16, MEM16", 0
in_c5: db "LDS REG16, MEM16", 0
in_c6: db "MOV MEM8, IMMED8", 0
in_c7: db "MOV MEM16, IMMED16", 0

in_c8: db "(invalid)", 0
in_c9: db "(invalid)", 0
in_ca: db "RETF IMMED16", 0
in_cb: db "RETF", 0
in_cc: db "INT 3", 0
in_cd: db "INT IMMED8", 0
in_ce: db "INTO", 0
in_cf: db "IRET", 0

in_d0: db "ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1", 0
in_d1: db "ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, 1", 0
in_d2: db "ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, CL", 0
in_d3: db "ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, CL", 0
in_d4: db "AAM", 0
in_d5: db "AAD", 0
in_d6: db "(invalid)", 0
in_d7: db "XLAT SOURCE-TABLE", 0

in_d8: db "ESC OPCODE, SOURCE", 0
in_d9: db "ESC OPCODE, SOURCE", 0
in_da: db "ESC OPCODE, SOURCE", 0
in_db: db "ESC OPCODE, SOURCE", 0
in_dc: db "ESC OPCODE, SOURCE", 0
in_dd: db "ESC OPCODE, SOURCE", 0
in_de: db "ESC OPCODE, SOURCE", 0
in_df: db "ESC OPCODE, SOURCE", 0

in_e0: db "LOOPNZ SHORT-LABEL", 0
in_e1: db "LOOPZ SHORT-LABEL", 0
in_e2: db "LOOP SHORT-LABEL", 0
in_e3: db "JCXZ SHORT-LABEL", 0
in_e4: db "IN AL, IMMED8", 0
in_e5: db "IN AX, IMMED8", 0
in_e6: db "OUT AL, IMMED8", 0
in_e7: db "OUT AX, IMMED8", 0

in_e8: db "CALL NEAR-PROC", 0
in_e9: db "JMP NEAR-LABEL", 0
in_ea: db "JMP FAR-LABEL", 0
in_eb: db "JMP SHORT-LABEL", 0
in_ec: db "IN AL, DX", 0
in_ed: db "IN AX, DX", 0
in_ee: db "OUT AL, DX", 0
in_ef: db "OUT AX, DX", 0

in_f0: db "LOCK", 0
in_f1: db "(invalid)", 0
in_f2: db "REPNZ", 0
in_f3: db "REPZ", 0
in_f4: db "HLT", 0
in_f5: db "CMC", 0
in_f6: db "TEST/NOT/NEG/MUL/IMUL/DIV/IDIV", " REG8/MEM8 (IMMED8)", 0
in_f7: db "TEST/NOT/NEG/MUL/IMUL/DIV/IDIV", " REG16/MEM16 (IMMED16)", 0

in_f8: db "CLC", 0
in_f9: db "STC", 0
in_fa: db "CLI", 0
in_fb: db "STI", 0
in_fc: db "CLD", 0
in_fd: db "STD", 0
in_fe: db "INC/DEC REG8/MEM8", 0
in_ff: db "INC/DEC/CALL NEAR/CALL FAR", "/JMP NEAR/JMP FAR/PUSH REG16/MEM16", 0

.EOF
