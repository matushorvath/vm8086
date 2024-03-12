.EXPORT instructions

# From exec.s
# TODO .IMPORT execute_nop
# TODO .IMPORT invalid_opcode

# From params.s
# TODO .IMPORT immediate
# TODO .IMPORT zeropage

# TODO what should arg_mod_reg_mem_dst_w do when the r/m field is a register, not memory? e.g. for LEA

# iAPX 86, 88 User's Manual; August 1981; pages 4-27 to 4-35

instructions:
    db  exec_add_b, arg_mod_reg_rm_src_b            # 0x00 ADD REG8/MEM8, REG8
    db  exec_add_w, arg_mod_reg_rm_src_w            # 0x01 ADD REG16/MEM16, REG16
    db  exec_add_b, arg_mod_reg_rm_dst_b            # 0x02 ADD REG8, REG8/MEM8
    db  exec_add_w, arg_mod_reg_rm_dst_w            # 0x03 ADD REG16, REG16/MEM16
    db  exec_add_b, arg_al_immediate_b              # 0x04 ADD AL, IMMED8
    db  exec_add_w, arg_ax_immediate_w              # 0x05 ADD AX, IMMED16

    db  exec_push_w, arg_reg_es                     # 0x06 PUSH ES
    db  exec_pop_w, arg_reg_es                      # 0x07 POP ES

    db  exec_or_b, arg_mod_reg_rm_src_b             # 0x08 OR REG8/MEM8, REG8
    db  exec_or_w, arg_mod_reg_rm_src_w             # 0x09 OR REG16/MEM16, REG16
    db  exec_or_b, arg_mod_reg_rm_dst_b             # 0x0a OR REG8, REG8/MEM8
    db  exec_or_w, arg_mod_reg_rm_dst_w             # 0x0b OR REG16, REG16/MEM16
    db  exec_or_b, arg_al_immediate_b               # 0x0c OR AL, IMMED8
    db  exec_or_w, arg_ax_immediate_w               # 0x0d OR AX, IMMED16

    db  exec_push_w, arg_reg_cs                     # 0x0e PUSH CS
    db  invalid_opcode, 0                           # 0x0f

    db  exec_adc_b, arg_mod_reg_rm_src_b            # 0x10 ADC REG8/MEM8, REG8
    db  exec_adc_w, arg_mod_reg_rm_src_w            # 0x11 ADC REG16/MEM16, REG16
    db  exec_adc_b, arg_mod_reg_rm_dst_b            # 0x12 ADC REG8, REG8/MEM8
    db  exec_adc_w, arg_mod_reg_rm_dst_w            # 0x13 ADC REG16, REG16/MEM16
    db  exec_adc_b, arg_al_immediate_b              # 0x14 ADC AL, IMMED8
    db  exec_adc_w, arg_ax_immediate_w              # 0x15 ADC AX, IMMED16

    db  exec_push_w, arg_reg_ss                     # 0x16 PUSH SS
    db  exec_pop_w, arg_reg_ss                      # 0x17 POP SS

    db  exec_sbb_b, arg_mod_reg_rm_src_b            # 0x18 SBB REG8/MEM8, REG8
    db  exec_sbb_w, arg_mod_reg_rm_src_w            # 0x19 SBB REG16/MEM16, REG16
    db  exec_sbb_b, arg_mod_reg_rm_dst_b            # 0x1a SBB REG8, REG8/MEM8
    db  exec_sbb_w, arg_mod_reg_rm_dst_w            # 0x1b SBB REG16, REG16/MEM16
    db  exec_sbb_b, arg_al_immediate_b              # 0x1c SBB AL, IMMED8
    db  exec_sbb_w, arg_ax_immediate_w              # 0x1d SBB AX, IMMED16

    db  exec_push_w, arg_reg_ds                     # 0x1e PUSH SDS
    db  exec_pop_w, arg_reg_ds                      # 0x1f POP DS

    db  exec_and_b, arg_mod_reg_rm_src_b            # 0x20 AND REG8/MEM8, REG8
    db  exec_and_w, arg_mod_reg_rm_src_w            # 0x21 AND REG16/MEM16, REG16
    db  exec_and_b, arg_mod_reg_rm_dst_b            # 0x22 AND REG8, REG8/MEM8
    db  exec_and_w, arg_mod_reg_rm_dst_w            # 0x23 AND REG16, REG16/MEM16
    db  exec_and_b, arg_al_immediate_b              # 0x24 AND AL, IMMED8
    db  exec_and_w, arg_ax_immediate_w              # 0x25 AND AX, IMMED16

    db  exec_segment_prefix, arg_reg_es             # 0x26 ES: (segment override prefix)
    db  exec_daa, 0                                 # 0x27 DAA

    db  exec_sub_b, arg_mod_reg_rm_src_b            # 0x28 SUB REG8/MEM8, REG8
    db  exec_sub_w, arg_mod_reg_rm_src_w            # 0x29 SUB REG16/MEM16, REG16
    db  exec_sub_b, arg_mod_reg_rm_dst_b            # 0x2a SUB REG8, REG8/MEM8
    db  exec_sub_w, arg_mod_reg_rm_dst_w            # 0x2b SUB REG16, REG16/MEM16
    db  exec_sub_b, arg_al_immediate_b              # 0x2c SUB AL, IMMED8
    db  exec_sub_w, arg_ax_immediate_w              # 0x2d SUB AX, IMMED16

    db  exec_segment_prefix, arg_reg_cs             # 0x2e CS: (segment override prefix)
    db  exec_das, 0                                 # 0x2f DAS

    db  exec_xor_b, arg_mod_reg_rm_src_b            # 0x30 XOR REG8/MEM8, REG8
    db  exec_xor_w, arg_mod_reg_rm_src_w            # 0x31 XOR REG16/MEM16, REG16
    db  exec_xor_b, arg_mod_reg_rm_dst_b            # 0x32 XOR REG8, REG8/MEM8
    db  exec_xor_w, arg_mod_reg_rm_dst_w            # 0x33 XOR REG16, REG16/MEM16
    db  exec_xor_b, arg_al_immediate_b              # 0x34 XOR AL, IMMED8
    db  exec_xor_w, arg_ax_immediate_w              # 0x35 XOR AX, IMMED16

    db  exec_segment_prefix, arg_reg_ss             # 0x36 SS: (segment override prefix)
    db  exec_aaa, 0                                 # 0x37 AAA

    db  exec_cmp_b, arg_mod_reg_rm_src_b            # 0x38 CMP REG8/MEM8, REG8
    db  exec_cmp_w, arg_mod_reg_rm_src_w            # 0x39 CMP REG16/MEM16, REG16
    db  exec_cmp_b, arg_mod_reg_rm_dst_b            # 0x3a CMP REG8, REG8/MEM8
    db  exec_cmp_w, arg_mod_reg_rm_dst_w            # 0x3b CMP REG16, REG16/MEM16
    db  exec_cmp_b, arg_al_immediate_b              # 0x3c CMP AL, IMMED8
    db  exec_cmp_w, arg_ax_immediate_w              # 0x3d CMP AX, IMMED16

    db  exec_segment_prefix, arg_reg_ds             # 0x3e DS: (segment override prefix)
    db  exec_aas, 0                                 # 0x3f AAS

    db  exec_inc_w, arg_reg_ax                      # 0x40 INC AX
    db  exec_inc_w, arg_reg_cx                      # 0x41 INC CX
    db  exec_inc_w, arg_reg_dx                      # 0x42 INC DX
    db  exec_inc_w, arg_reg_bx                      # 0x43 INC BX
    db  exec_inc_w, arg_reg_sp                      # 0x44 INC SP
    db  exec_inc_w, arg_reg_bp                      # 0x45 INC BP
    db  exec_inc_w, arg_reg_si                      # 0x46 INC SI
    db  exec_inc_w, arg_reg_di                      # 0x47 INC DI

    db  exec_dec_w, arg_reg_ax                      # 0x48 DEC AX
    db  exec_dec_w, arg_reg_cx                      # 0x49 DEC CX
    db  exec_dec_w, arg_reg_dx                      # 0x4a DEC DX
    db  exec_dec_w, arg_reg_bx                      # 0x4b DEC BX
    db  exec_dec_w, arg_reg_sp                      # 0x4c DEC SP
    db  exec_dec_w, arg_reg_bp                      # 0x4d DEC BP
    db  exec_dec_w, arg_reg_si                      # 0x4e DEC SI
    db  exec_dec_w, arg_reg_di                      # 0x4f DEC DI

    db  exec_push_w, arg_reg_ax                     # 0x50 PUSH AX
    db  exec_push_w, arg_reg_cx                     # 0x51 PUSH CX
    db  exec_push_w, arg_reg_dx                     # 0x52 PUSH DX
    db  exec_push_w, arg_reg_bx                     # 0x53 PUSH BX
    db  exec_push_w, arg_reg_sp                     # 0x54 PUSH SP
    db  exec_push_w, arg_reg_bp                     # 0x55 PUSH BP
    db  exec_push_w, arg_reg_si                     # 0x56 PUSH SI
    db  exec_push_w, arg_reg_di                     # 0x57 PUSH DI

    db  exec_pop_w, arg_reg_ax                      # 0x58 POP AX
    db  exec_pop_w, arg_reg_cx                      # 0x59 POP CX
    db  exec_pop_w, arg_reg_dx                      # 0x5a POP DX
    db  exec_pop_w, arg_reg_bx                      # 0x5b POP BX
    db  exec_pop_w, arg_reg_sp                      # 0x5c POP SP
    db  exec_pop_w, arg_reg_bp                      # 0x5d POP BP
    db  exec_pop_w, arg_reg_si                      # 0x5e POP SI
    db  exec_pop_w, arg_reg_di                      # 0x5f POP DI

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

    db  exec_jo, arg_short_ptr                      # 0x70 JO SHORT-LABEL
    db  exec_jno, arg_short_ptr                     # 0x71 JNO SHORT-LABEL
    db  exec_jb, arg_short_ptr                      # 0x72 JB/JNAEI/JC SHORT-LABEL
    db  exec_jnb, arg_short_ptr                     # 0x73 JNB/JAEI/JNC SHORT-LABEL
    db  exec_jz, arg_short_ptr                      # 0x74 JE/JZ SHORT-LABEL
    db  exec_jnz, arg_short_ptr                     # 0x75 JNE/JNZ SHORT-LABEL
    db  exec_jna, arg_short_ptr                     # 0x76 JBE/JNA SHORT-LABEL
    db  exec_ja, arg_short_ptr                      # 0x77 JNBE/JA SHORT-LABEL
    db  exec_js, arg_short_ptr                      # 0x78 JS SHORT-LABEL
    db  exec_jns, arg_short_ptr                     # 0x79 JNS SHORT-LABEL
    db  exec_jp, arg_short_ptr                      # 0x7a JP/JPE SHORT-LABEL
    db  exec_jnp, arg_short_ptr                     # 0x7b JNP/JPO SHORT-LABEL
    db  exec_jl, arg_short_ptr                      # 0x7c JL/JNGE SHORT-LABEL
    db  exec_jnl, arg_short_ptr                     # 0x7d JNL/JGE SHORT-LABEL
    db  exec_jng, arg_short_ptr                     # 0x7e JLE/JNG SHORT-LABEL
    db  exec_jg, arg_short_ptr                      # 0x7f JNLE/JG SHORT-LABEL

    # <alop>: 000 ADD, 001 OR, 010 ADC, 011 SBB, 100 AND, 101 SUB, 110 XOR, 111 CMP
    db  exec_alop_b, arg_mod_alop_rm_b              # 0x80 <alop> REG8/MEM8, IMMED8
    db  exec_alop_w, arg_mod_alop_rm_w              # 0x81 <alop> REG16/MEM16, IMMED16

    # <alop>: 000 ADD,         010 ADC, 011 SBB,          101 SUB,          111 CMP
    db  exec_alop_b, arg_mod_alop_rm_ext_b          # 0x82 <alop> REG8/MEM8, IMMED8
    db  exec_alop_w, arg_mod_alop_rm_ext_w          # 0x83 <alop> REG16/MEM16, IMMED8 (sign extend)

    db  exec_test_b, arg_mod_reg_rm_src_b           # 0x84 TEST REG8/MEM8, REG8
    db  exec_test_w, arg_mod_reg_rm_src_w           # 0x85 TEST REG16/MEM16, REG16
    db  exec_xchg_b, arg_mod_reg_rm_dst_b           # 0x86 XCHG REG8, REG8/MEM8
    db  exec_xchg_w, arg_mod_reg_rm_dst_w           # 0x87 XCHG REG16, REG16/MEM16

    db  exec_mov_b, arg_mod_reg_rm_src_b            # 0x88 MOV REG8/MEM8, REG8
    db  exec_mov_w, arg_mod_reg_rm_src_w            # 0x89 MOV REG16/MEM16, REG16
    db  exec_mov_b, arg_mod_reg_rm_dst_b            # 0x8a MOV REG8, REG8/MEM8
    db  exec_mov_w, arg_mod_reg_rm_dst_w            # 0x8b MOV REG16, REG16/MEM16

    db  exec_mov_w, arg_mod_1sr_rm_src              # 0x8c MOV REG16/MEM16, SEGREG
    db  exec_lea_w, arg_mod_reg_mem_dst_w           # 0x8d LEA REG16, MEM16
    db  exec_mov_w, arg_mod_1sr_rm_dst              # 0x8e MOV SEGREG, REG16/MEM16
    db  exec_pop_w, arg_mod_000_rm_w                # 0x8f POP REG16/MEM16

    db  exec_nop, 0                                 # 0x90 NOP (= XCHG AX, AX)
    db  exec_xchg_w, arg_reg_cx                     # 0x91 XCHG AX, CX
    db  exec_xchg_w, arg_reg_dx                     # 0x92 XCHG AX, DX
    db  exec_xchg_w, arg_reg_bx                     # 0x93 XCHG AX, BX
    db  exec_xchg_w, arg_reg_sp                     # 0x94 XCHG AX, SP
    db  exec_xchg_w, arg_reg_bp                     # 0x95 XCHG AX, BP
    db  exec_xchg_w, arg_reg_si                     # 0x96 XCHG AX, SI
    db  exec_xchg_w, arg_reg_di                     # 0x97 XCHG AX, DI

    db  exec_cbw, 0                                 # 0x98 CBW
    db  exec_cwd, 0                                 # 0x99 CWD
    db  exec_call, arg_far_ptr                      # 0x9a CALL FAR-PROC
    db  exec_wait, 0                                # 0x9b WAIT
    db  exec_pushf, 0                               # 0x9c PUSHF
    db  exec_popf, 0                                # 0x9d POPF
    db  exec_sahf, 0                                # 0x9e SAHF
    db  exec_lahf, 0                                # 0x9f LAHF

    db  exec_mov_b, arg_al_near_ptr_dst_b           # 0xa0 MOV AL, MEM8
    db  exec_mov_w, arg_ax_near_ptr_dst_w           # 0xa1 MOV AX, MEM16
    db  exec_mov_b, arg_al_near_ptr_src_b           # 0xa2 MOV MEM8, AL
    db  exec_mov_w, arg_ax_near_ptr_src_w           # 0xa3 MOV MEM16, AX

    db  exec_movs_b, 0                              # 0xa4 MOVS DEST-STR8, SRC-STR8
    db  exec_movs_w, 0                              # 0xa5 MOVS DEST-STR16, SRC-STR16
    db  exec_cmps_b, 0                              # 0xa6 CMPS DEST-STR8, SRC-STR8
    db  exec_cmps_w, 0                              # 0xa7 CMPS DEST-STR16, SRC-STR16

    db  exec_test_b, arg_al_immediate_b             # 0xa8 TEST AL, IMMED8
    db  exec_test_w, arg_ax_immediate_w             # 0xa9 TEST AX, IMMED16

    db  exec_stos_b, 0                              # 0xaa STOS DEST-STR8
    db  exec_stos_w, 0                              # 0xab STOS DEST-STR16
    db  exec_lods_b, 0                              # 0xac LODS SRC-STR8
    db  exec_lods_w, 0                              # 0xad LODS SRC-STR16
    db  exec_scas_b, 0                              # 0xae SCAS DEST-STR8
    db  exec_scas_w, 0                              # 0xaf SCAS DEST-STR16

    db  exec_mov_b, arg_al_immediate_b              # 0xb0 MOV AL, IMMED8
    db  exec_mov_b, arg_cl_immediate_b              # 0xb1 MOV CL, IMMED8
    db  exec_mov_b, arg_dl_immediate_b              # 0xb2 MOV DL, IMMED8
    db  exec_mov_b, arg_bl_immediate_b              # 0xb3 MOV BL, IMMED8
    db  exec_mov_b, arg_ah_immediate_b              # 0xb4 MOV AH, IMMED8
    db  exec_mov_b, arg_ch_immediate_b              # 0xb5 MOV CH, IMMED8
    db  exec_mov_b, arg_dh_immediate_b              # 0xb6 MOV DH, IMMED8
    db  exec_mov_b, arg_bh_immediate_b              # 0xb7 MOV BH, IMMED8

    db  exec_mov_w, arg_ax_immediate_w              # 0xb8 MOV AX, IMMED16
    db  exec_mov_w, arg_cx_immediate_w              # 0xb9 MOV CX, IMMED16
    db  exec_mov_w, arg_dx_immediate_w              # 0xba MOV DX, IMMED16
    db  exec_mov_w, arg_bx_immediate_w              # 0xbb MOV BX, IMMED16
    db  exec_mov_w, arg_sp_immediate_w              # 0xbc MOV SP, IMMED16
    db  exec_mov_w, arg_bp_immediate_w              # 0xbd MOV BP, IMMED16
    db  exec_mov_w, arg_si_immediate_w              # 0xbe MOV SI, IMMED16
    db  exec_mov_w, arg_di_immediate_w              # 0xbf MOV DI, IMMED16

    db  invalid_opcode, 0                           # 0xc0
    db  invalid_opcode, 0                           # 0xc1

    db  exec_ret_near, arg_immediate_w              # 0xc2 RET IMMED16 (within segment)
    db  exec_ret_near, arg_zero                     # 0xc3 RET (within segment)

    db  exec_les_w, arg_mod_reg_mem_dst_w           # 0xc4 LES REG16, MEM16
    db  exec_lds_w, arg_mod_reg_mem_dst_w           # 0xc5 LDS REG16, MEM16

    db  exec_mov_b, arg_mod_000_rm_immediate_b      # 0xc6 MOV MEM8, IMMED8
    db  exec_mov_w, arg_mod_000_rm_immediate_w      # 0xc7 MOV MEM16, IMMED16

    db  invalid_opcode, 0                           # 0xc8
    db  invalid_opcode, 0                           # 0xc9

    db  exec_ret_far, arg_immediate_w               # 0xca RET IMMED16 (intersegment)
    db  exec_ret_far, arg_zero                      # 0xcb RET (intersegment)

    db  exec_int3, 0                                # 0xcc INT 3
    db  exec_int, arg_immediate_b                   # 0xcd INT IMMED8

    db  exec_into, 0                                # 0xce INTO
    db  exec_iret, 0                                # 0xcf IRET

    # <rsop>: 000 ROL, 001 ROR, 010 RCL, 011 RCR, 100 SAL/SHL, 101 SHR,          111 SAR
    db  exec_rsop_b, arg_mod_rsop_rm_1_b            # 0xd0 <rsop> REG8/MEM8, 1
    db  exec_rsop_w, arg_mod_rsop_rm_1_w            # 0xd1 <rsop> REG16/MEM16, 1
    db  exec_rsop_b, arg_mod_rsop_rm_cl_b           # 0xd2 <rsop> REG8/MEM8, CL
    db  exec_rsop_w, arg_mod_rsop_rm_cl_w           # 0xd3 <rsop> REG16/MEM16, CL

    db  exec_aam, 0                                 # 0xd4 AAM
    db  exec_aad, 0                                 # 0xd5 AAD
    db  invalid_opcode, 0                           # 0xd6
    db  exec_xlat, 0                                # 0xd7 XLAT SOURCE-TABLE

    db  exec_esc, arg_esc_000                       # 0xd8 ESC OPCODE, SOURCE (2 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xd9 ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xda ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xdb ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xdc ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xdd ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_yyy                       # 0xde ESC OPCODE, SOURCE (4 bytes)
    db  exec_esc, arg_esc_111                       # 0xdf ESC OPCODE, SOURCE (2 bytes)

    db  exec_loopne, arg_short_ptr                  # 0xe0 LOOPNE/LOOPNZ SHORT-LABEL
    db  exec_loope, arg_short_ptr                   # 0xe1 LOOPE/LOOPZ SHORT-LABEL
    db  exec_loop, arg_short_ptr                    # 0xe2 LOOP SHORT-LABEL
    db  exec_jcxz, arg_short_ptr                    # 0xe3 JCXZ SHORT-LABEL

    db  exec_in_b, arg_al_immediate_b               # 0xe4 IN AL, IMMED8
    db  exec_in_w, arg_ax_immediate_w               # 0xe5 IN AX, IMMED8
    db  exec_out_b, arg_al_immediate_b              # 0xe6 OUT AL, IMMED8
    db  exec_out_w, arg_ax_immediate_w              # 0xe7 OUT AX, IMMED8

    db  exec_call, arg_near_ptr                     # 0xe8 CALL NEAR-PROC
    db  exec_jmp, arg_near_ptr                      # 0xe9 JMP NEAR-LABEL
    db  exec_jmp, arg_far_ptr                       # 0xea JMP FAR-LABEL
    db  exec_jmp, arg_short_ptr                     # 0xeb JMP SHORT-LABEL

    db  exec_in_b, arg_al_dx_b                      # 0xe4 IN AL, DX
    db  exec_in_w, arg_ax_dx_w                      # 0xe5 IN AX, DX
    db  exec_out_b, arg_al_dx_b                     # 0xe6 OUT AL, DX
    db  exec_out_w, arg_ax_dx_w                     # 0xe7 OUT AX, DX

    db  exec_lock, 0                                # 0xf0 LOCK (prefix)
    db  invalid_opcode, 0                           # 0xf1
    db  exec_repnz, 0                               # 0xf2 REPNE/REPNZ
    db  exec_repz, 0                                # 0xf3 REP/REPE/REPZ

    db  exec_hlt, 0                                 # 0xf4 HLT
    db  exec_cmc, 0                                 # 0xf5 CMC

    # <tnmd>:
    # 000 TEST REG/MEM, IMMED
    # 001 (not used)
    # 010 NOT REG/MEM
    # 011 NEG REG/MEM
    # 100 MUL REG/MEM
    # 101 IMUL REG/MEM
    # 110 DIV REG/MEM
    # 111 IDIV REG/MEM
    db  exec_tnmd_b, arg_mod_tnmd_rm_b              # 0xf6 <tnmd> 8-bit
    db  exec_tnmd_w, arg_mod_tnmd_rm_w              # 0xf7 <tnmd> 16-bit

    db  exec_clc, 0                                 # 0xf8 CLC
    db  exec_stc, 0                                 # 0xf9 STC
    db  exec_cli, 0                                 # 0xfa CLI
    db  exec_sti, 0                                 # 0xfb STI
    db  exec_cld, 0                                 # 0xfc CLD
    db  exec_std, 0                                 # 0xfd STD

    # <feop>:
    # 000 INC REG8/MEM8
    # 001 DEC REG8/MEM8
    # (rest not used)
    db  exec_feop_b, arg_mod_feop_rm_b              # 0xfe <feop> REG8/MEM8

    # <fdop>:
    # 000 INC MEM16
    # 001 DEC MEM16
    # 010 CALL REG16/MEM16 (within segment)
    # 011 CALL MEM16 (intersegment)
    # 100 JMP REG16/MEM16 (within segment)
    # 101 JMP MEM16 (intersegment)
    # 110 PUSH MEM16
    # 111 (not used)
    db  exec_ffop_w, arg_mod_ffop_rm_w              # 0xff <ffop> REG16/MEM16

.EOF
