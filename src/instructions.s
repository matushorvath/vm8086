.EXPORT instructions

# From arg_al_ax_near_ptr.s
.IMPORT arg_al_ax_near_ptr_src
.IMPORT arg_al_ax_near_ptr_dst

# From arg_mod_op_rm.s
.IMPORT arg_mod_000_rm_w
.IMPORT arg_mod_000_rm_immediate_b
.IMPORT arg_mod_000_rm_immediate_w
.IMPORT arg_mod_op_rm_b
.IMPORT arg_mod_op_rm_w
.IMPORT arg_mod_op_rm_b_immediate_b
.IMPORT arg_mod_op_rm_w_immediate_sxb
.IMPORT arg_mod_op_rm_w_immediate_w

# From arg_mod_reg_rm.s
.IMPORT arg_mod_reg_rm_src_b
.IMPORT arg_mod_reg_rm_src_w
.IMPORT arg_mod_reg_rm_dst_b
.IMPORT arg_mod_reg_rm_dst_w
.IMPORT arg_mod_1sr_rm_src
.IMPORT arg_mod_1sr_rm_dst

# From arg_reg.s
.IMPORT arg_ax
.IMPORT arg_cx
.IMPORT arg_dx
.IMPORT arg_bx
.IMPORT arg_sp
.IMPORT arg_bp
.IMPORT arg_si
.IMPORT arg_di
.IMPORT arg_cs
.IMPORT arg_ds
.IMPORT arg_ss
.IMPORT arg_es

# From arg_reg_immediate_b.s
.IMPORT arg_al_immediate_b
.IMPORT arg_bl_immediate_b
.IMPORT arg_cl_immediate_b
.IMPORT arg_dl_immediate_b
.IMPORT arg_ah_immediate_b
.IMPORT arg_bh_immediate_b
.IMPORT arg_ch_immediate_b
.IMPORT arg_dh_immediate_b

# From arg_reg_immediate_w.s
.IMPORT arg_ax_immediate_w
.IMPORT arg_bx_immediate_w
.IMPORT arg_cx_immediate_w
.IMPORT arg_dx_immediate_w
.IMPORT arg_sp_immediate_w
.IMPORT arg_bp_immediate_w
.IMPORT arg_si_immediate_w
.IMPORT arg_di_immediate_w

# From bitwise.s
.IMPORT execute_and_b
.IMPORT execute_and_w
.IMPORT execute_or_b
.IMPORT execute_or_w
.IMPORT execute_xor_b
.IMPORT execute_xor_w
.IMPORT execute_test_b
.IMPORT execute_test_w

# From exec.s
.IMPORT execute_nop
.IMPORT invalid_opcode
.IMPORT not_implemented             # TODO remove

# From flags.s
.IMPORT execute_clc
.IMPORT execute_stc
.IMPORT execute_cmc
.IMPORT execute_cld
.IMPORT execute_std
.IMPORT execute_cli
.IMPORT execute_sti
.IMPORT execute_lahf
.IMPORT execute_sahf

# From group2.s
.IMPORT execute_group2_b
.IMPORT execute_group2_w

# From group_immed.s
.IMPORT execute_immed_b
.IMPORT execute_immed_w

# From in_out.s
# TODO .IMPORT execute_in_al_immediate_b
# TODO .IMPORT execute_in_ax_immediate_b
.IMPORT execute_out_al_immediate_b
.IMPORT execute_out_ax_immediate_b
# TODO .IMPORT execute_in_al_dx
# TODO .IMPORT execute_in_ax_dx
.IMPORT execute_out_al_dx
.IMPORT execute_out_ax_dx

# From inc_dec.s
.IMPORT execute_inc_w
.IMPORT execute_dec_w

# From interrupt.s
.IMPORT execute_int
.IMPORT execute_int3
.IMPORT execute_into
.IMPORT execute_iret

# From jump.s
.IMPORT execute_jo
.IMPORT execute_jno
.IMPORT execute_jc
.IMPORT execute_jnc
.IMPORT execute_jz
.IMPORT execute_jnz
.IMPORT execute_ja
.IMPORT execute_jna
.IMPORT execute_js
.IMPORT execute_jns
.IMPORT execute_jp
.IMPORT execute_jnp
.IMPORT execute_jl
.IMPORT execute_jnl
.IMPORT execute_jg
.IMPORT execute_jng
.IMPORT execute_jcxz
.IMPORT execute_jmp_short

# From prefix.s
.IMPORT execute_lock
.IMPORT execute_segment_prefix_cs
.IMPORT execute_segment_prefix_ds
.IMPORT execute_segment_prefix_ss
.IMPORT execute_segment_prefix_es
.IMPORT execute_repz
.IMPORT execute_repnz

# From stack.s
.IMPORT execute_push_w
.IMPORT execute_pop_w
.IMPORT execute_pushf
.IMPORT execute_popf

# From transfer.s
.IMPORT execute_mov_b
.IMPORT execute_mov_w
.IMPORT execute_xchg_b
.IMPORT execute_xchg_w
.IMPORT execute_xchg_ax_w

# iAPX 86, 88 User's Manual; August 1981; pages 4-27 to 4-35

instructions:
    db  not_implemented, 0, 0 # TODO    db  execute_add_b, arg_mod_reg_rm_src_b, 4          # 0x00 ADD REG8/MEM8, REG8
    db  not_implemented, 0, 0 # TODO    db  execute_add_w, arg_mod_reg_rm_src_w, 4          # 0x01 ADD REG16/MEM16, REG16
    db  not_implemented, 0, 0 # TODO    db  execute_add_b, arg_mod_reg_rm_dst_b, 4          # 0x02 ADD REG8, REG8/MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_add_w, arg_mod_reg_rm_dst_w, 4          # 0x03 ADD REG16, REG16/MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_add_b, arg_al_immediate_b               # 0x04 ADD AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_add_w, arg_ax_immediate_w               # 0x05 ADD AX, IMMED16

    db  execute_push_w, arg_es, 2                           # 0x06 PUSH ES
    db  execute_pop_w, arg_es, 2                            # 0x07 POP ES

    db  execute_or_b, arg_mod_reg_rm_src_b, 4               # 0x08 OR REG8/MEM8, REG8
    db  execute_or_w, arg_mod_reg_rm_src_w, 4               # 0x09 OR REG16/MEM16, REG16
    db  execute_or_b, arg_mod_reg_rm_dst_b, 4               # 0x0a OR REG8, REG8/MEM8
    db  execute_or_w, arg_mod_reg_rm_dst_w, 4               # 0x0b OR REG16, REG16/MEM16
    db  execute_or_b, arg_al_immediate_b, 4                 # 0x0c OR AL, IMMED8
    db  execute_or_w, arg_ax_immediate_w, 4                 # 0x0d OR AX, IMMED16

    db  execute_push_w, arg_cs, 2                           # 0x0e PUSH CS
    db  invalid_opcode, 0, 0                                # 0x0f

    db  not_implemented, 0, 0 # TODO    db  execute_adc_b, arg_mod_reg_rm_src_b, 4          # 0x10 ADC REG8/MEM8, REG8
    db  not_implemented, 0, 0 # TODO    db  execute_adc_w, arg_mod_reg_rm_src_w, 4          # 0x11 ADC REG16/MEM16, REG16
    db  not_implemented, 0, 0 # TODO    db  execute_adc_b, arg_mod_reg_rm_dst_b, 4          # 0x12 ADC REG8, REG8/MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_adc_w, arg_mod_reg_rm_dst_w, 4          # 0x13 ADC REG16, REG16/MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_adc_b, arg_al_immediate_b               # 0x14 ADC AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_adc_w, arg_ax_immediate_w               # 0x15 ADC AX, IMMED16

    db  execute_push_w, arg_ss, 2                           # 0x16 PUSH SS
    db  execute_pop_w, arg_ss, 2                            # 0x17 POP SS

    db  not_implemented, 0, 0 # TODO    db  execute_sbb_b, arg_mod_reg_rm_src_b, 4          # 0x18 SBB REG8/MEM8, REG8
    db  not_implemented, 0, 0 # TODO    db  execute_sbb_w, arg_mod_reg_rm_src_w, 4          # 0x19 SBB REG16/MEM16, REG16
    db  not_implemented, 0, 0 # TODO    db  execute_sbb_b, arg_mod_reg_rm_dst_b, 4          # 0x1a SBB REG8, REG8/MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_sbb_w, arg_mod_reg_rm_dst_w, 4          # 0x1b SBB REG16, REG16/MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_sbb_b, arg_al_immediate_b               # 0x1c SBB AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_sbb_w, arg_ax_immediate_w               # 0x1d SBB AX, IMMED16

    db  execute_push_w, arg_ds, 2                           # 0x1e PUSH DS
    db  execute_pop_w, arg_ds, 2                            # 0x1f POP DS

    db  execute_and_b, arg_mod_reg_rm_src_b, 4              # 0x20 AND REG8/MEM8, REG8
    db  execute_and_w, arg_mod_reg_rm_src_w, 4              # 0x21 AND REG16/MEM16, REG16
    db  execute_and_b, arg_mod_reg_rm_dst_b, 4              # 0x22 AND REG8, REG8/MEM8
    db  execute_and_w, arg_mod_reg_rm_dst_w, 4              # 0x23 AND REG16, REG16/MEM16
    db  execute_and_b, arg_al_immediate_b, 4                # 0x24 AND AL, IMMED8
    db  execute_and_w, arg_ax_immediate_w, 4                # 0x25 AND AX, IMMED16

    db  execute_segment_prefix_es, 0, 0                     # 0x26 ES: (segment override prefix)
    db  not_implemented, 0, 0 # TODO    db  execute_daa, 0                                  # 0x27 DAA

    db  not_implemented, 0, 0 # TODO    db  execute_sub_b, arg_mod_reg_rm_src_b, 4          # 0x28 SUB REG8/MEM8, REG8
    db  not_implemented, 0, 0 # TODO    db  execute_sub_w, arg_mod_reg_rm_src_w, 4          # 0x29 SUB REG16/MEM16, REG16
    db  not_implemented, 0, 0 # TODO    db  execute_sub_b, arg_mod_reg_rm_dst_b, 4          # 0x2a SUB REG8, REG8/MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_sub_w, arg_mod_reg_rm_dst_w, 4          # 0x2b SUB REG16, REG16/MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_sub_b, arg_al_immediate_b               # 0x2c SUB AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_sub_w, arg_ax_immediate_w               # 0x2d SUB AX, IMMED16

    db  execute_segment_prefix_cs, 0, 0                     # 0x2e CS: (segment override prefix)
    db  not_implemented, 0, 0 # TODO    db  execute_das, 0                                  # 0x2f DAS

    db  execute_xor_b, arg_mod_reg_rm_src_b, 4              # 0x30 XOR REG8/MEM8, REG8
    db  execute_xor_w, arg_mod_reg_rm_src_w, 4              # 0x31 XOR REG16/MEM16, REG16
    db  execute_xor_b, arg_mod_reg_rm_dst_b, 4              # 0x32 XOR REG8, REG8/MEM8
    db  execute_xor_w, arg_mod_reg_rm_dst_w, 4              # 0x33 XOR REG16, REG16/MEM16
    db  execute_xor_b, arg_al_immediate_b, 4                # 0x34 XOR AL, IMMED8
    db  execute_xor_w, arg_ax_immediate_w, 4                # 0x35 XOR AX, IMMED16

    db  execute_segment_prefix_ss, 0, 0                     # 0x36 SS: (segment override prefix)
    db  not_implemented, 0, 0 # TODO    db  execute_aaa, 0                                  # 0x37 AAA

    db  not_implemented, 0, 0 # TODO    db  execute_cmp_b, arg_mod_reg_rm_src_b, 4          # 0x38 CMP REG8/MEM8, REG8
    db  not_implemented, 0, 0 # TODO    db  execute_cmp_w, arg_mod_reg_rm_src_w, 4          # 0x39 CMP REG16/MEM16, REG16
    db  not_implemented, 0, 0 # TODO    db  execute_cmp_b, arg_mod_reg_rm_dst_b, 4          # 0x3a CMP REG8, REG8/MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_cmp_w, arg_mod_reg_rm_dst_w, 4          # 0x3b CMP REG16, REG16/MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_cmp_b, arg_al_immediate_b               # 0x3c CMP AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_cmp_w, arg_ax_immediate_w               # 0x3d CMP AX, IMMED16

    db  execute_segment_prefix_ds, 0, 0                     # 0x3e DS: (segment override prefix)
    db  not_implemented, 0, 0 # TODO    db  execute_aas, 0                                  # 0x3f AAS

    db  execute_inc_w, arg_ax, 2                            # 0x40 INC AX
    db  execute_inc_w, arg_cx, 2                            # 0x41 INC CX
    db  execute_inc_w, arg_dx, 2                            # 0x42 INC DX
    db  execute_inc_w, arg_bx, 2                            # 0x43 INC BX
    db  execute_inc_w, arg_sp, 2                            # 0x44 INC SP
    db  execute_inc_w, arg_bp, 2                            # 0x45 INC BP
    db  execute_inc_w, arg_si, 2                            # 0x46 INC SI
    db  execute_inc_w, arg_di, 2                            # 0x47 INC DI

    db  execute_dec_w, arg_ax, 2                            # 0x48 DEC AX
    db  execute_dec_w, arg_cx, 2                            # 0x49 DEC CX
    db  execute_dec_w, arg_dx, 2                            # 0x4a DEC DX
    db  execute_dec_w, arg_bx, 2                            # 0x4b DEC BX
    db  execute_dec_w, arg_sp, 2                            # 0x4c DEC SP
    db  execute_dec_w, arg_bp, 2                            # 0x4d DEC BP
    db  execute_dec_w, arg_si, 2                            # 0x4e DEC SI
    db  execute_dec_w, arg_di, 2                            # 0x4f DEC DI

    db  execute_push_w, arg_ax, 2                           # 0x50 PUSH AX
    db  execute_push_w, arg_cx, 2                           # 0x51 PUSH CX
    db  execute_push_w, arg_dx, 2                           # 0x52 PUSH DX
    db  execute_push_w, arg_bx, 2                           # 0x53 PUSH BX
    db  execute_push_w, arg_sp, 2                           # 0x54 PUSH SP
    db  execute_push_w, arg_bp, 2                           # 0x55 PUSH BP
    db  execute_push_w, arg_si, 2                           # 0x56 PUSH SI
    db  execute_push_w, arg_di, 2                           # 0x57 PUSH DI

    db  execute_pop_w, arg_ax, 2                            # 0x58 POP AX
    db  execute_pop_w, arg_cx, 2                            # 0x59 POP CX
    db  execute_pop_w, arg_dx, 2                            # 0x5a POP DX
    db  execute_pop_w, arg_bx, 2                            # 0x5b POP BX
    db  execute_pop_w, arg_sp, 2                            # 0x5c POP SP
    db  execute_pop_w, arg_bp, 2                            # 0x5d POP BP
    db  execute_pop_w, arg_si, 2                            # 0x5e POP SI
    db  execute_pop_w, arg_di, 2                            # 0x5f POP DI

    db  invalid_opcode, 0, 0                                # 0x60
    db  invalid_opcode, 0, 0                                # 0x61
    db  invalid_opcode, 0, 0                                # 0x62
    db  invalid_opcode, 0, 0                                # 0x63
    db  invalid_opcode, 0, 0                                # 0x64
    db  invalid_opcode, 0, 0                                # 0x65
    db  invalid_opcode, 0, 0                                # 0x66
    db  invalid_opcode, 0, 0                                # 0x67

    db  invalid_opcode, 0, 0                                # 0x68
    db  invalid_opcode, 0, 0                                # 0x69
    db  invalid_opcode, 0, 0                                # 0x6a
    db  invalid_opcode, 0, 0                                # 0x6b
    db  invalid_opcode, 0, 0                                # 0x6c
    db  invalid_opcode, 0, 0                                # 0x6d
    db  invalid_opcode, 0, 0                                # 0x6e
    db  invalid_opcode, 0, 0                                # 0x6f

    db  execute_jo, 0, 0                                    # 0x70 JO SHORT-LABEL
    db  execute_jno, 0, 0                                   # 0x71 JNO SHORT-LABEL
    db  execute_jc, 0, 0                                    # 0x72 JB/JNAEI/JC SHORT-LABEL
    db  execute_jnc, 0, 0                                   # 0x73 JNB/JAEI/JNC SHORT-LABEL
    db  execute_jz, 0, 0                                    # 0x74 JE/JZ SHORT-LABEL
    db  execute_jnz, 0, 0                                   # 0x75 JNE/JNZ SHORT-LABEL
    db  execute_jna, 0, 0                                   # 0x76 JBE/JNA SHORT-LABEL
    db  execute_ja, 0, 0                                    # 0x77 JNBE/JA SHORT-LABEL
    db  execute_js, 0, 0                                    # 0x78 JS SHORT-LABEL
    db  execute_jns, 0, 0                                   # 0x79 JNS SHORT-LABEL
    db  execute_jp, 0, 0                                    # 0x7a JP/JPE SHORT-LABEL
    db  execute_jnp, 0, 0                                   # 0x7b JNP/JPO SHORT-LABEL
    db  execute_jl, 0, 0                                    # 0x7c JL/JNGE SHORT-LABEL
    db  execute_jnl, 0, 0                                   # 0x7d JNL/JGE SHORT-LABEL
    db  execute_jng, 0, 0                                   # 0x7e JLE/JNG SHORT-LABEL
    db  execute_jg, 0, 0                                    # 0x7f JNLE/JG SHORT-LABEL

    # <immed>: 000 ADD, 001 OR, 010 ADC, 011 SBB, 100 AND, 101 SUB, 110 XOR, 111 CMP
    db  execute_immed_b, arg_mod_op_rm_b_immediate_b, 5     # 0x80 <immed> REG8/MEM8, IMMED8
    db  execute_immed_w, arg_mod_op_rm_w_immediate_w, 5     # 0x81 <immed> REG16/MEM16, IMMED16

    # <immed>: 000 ADD,         010 ADC, 011 SBB,          101 SUB,          111 CMP
    # however NASM will generate 0x83 0xf0 0xff for xor ax, word 0xffff, which is "(not used)" in intel docs
    # https://bugzilla.nasm.us/show_bug.cgi?id=3392642
    db  execute_immed_b, arg_mod_op_rm_b_immediate_b, 5     # 0x82 <immed> REG8/MEM8, IMMED8
    db  execute_immed_w, arg_mod_op_rm_w_immediate_sxb, 5   # 0x83 <immed> REG16/MEM16, IMMED8 (sign extended)

    db  execute_test_b, arg_mod_reg_rm_src_b, 4             # 0x84 TEST REG8/MEM8, REG8
    db  execute_test_w, arg_mod_reg_rm_src_w, 4             # 0x85 TEST REG16/MEM16, REG16
    db  execute_xchg_b, arg_mod_reg_rm_dst_b, 4             # 0x86 XCHG REG8, REG8/MEM8
    db  execute_xchg_w, arg_mod_reg_rm_dst_w, 4             # 0x87 XCHG REG16, REG16/MEM16

    db  execute_mov_b, arg_mod_reg_rm_src_b, 4              # 0x88 MOV REG8/MEM8, REG8
    db  execute_mov_w, arg_mod_reg_rm_src_w, 4              # 0x89 MOV REG16/MEM16, REG16
    db  execute_mov_b, arg_mod_reg_rm_dst_b, 4              # 0x8a MOV REG8, REG8/MEM8
    db  execute_mov_w, arg_mod_reg_rm_dst_w, 4              # 0x8b MOV REG16, REG16/MEM16
    db  execute_mov_w, arg_mod_1sr_rm_src, 4                # 0x8c MOV REG16/MEM16, SEGREG
    db  not_implemented, 0, 0 # TODO x   db  execute_lea_w, arg_mod_reg_mem_dst_w            # 0x8d LEA REG16, MEM16
    db  execute_mov_w, arg_mod_1sr_rm_dst, 4                # 0x8e MOV SEGREG, REG16/MEM16
    db  execute_pop_w, arg_mod_000_rm_w, 2                  # 0x8f POP REG16/MEM16

    db  execute_nop, 0, 0                                   # 0x90 NOP (= XCHG AX, AX)
    db  execute_xchg_ax_w, arg_cx, 2                        # 0x91 XCHG AX, CX
    db  execute_xchg_ax_w, arg_dx, 2                        # 0x92 XCHG AX, DX
    db  execute_xchg_ax_w, arg_bx, 2                        # 0x93 XCHG AX, BX
    db  execute_xchg_ax_w, arg_sp, 2                        # 0x94 XCHG AX, SP
    db  execute_xchg_ax_w, arg_bp, 2                        # 0x95 XCHG AX, BP
    db  execute_xchg_ax_w, arg_si, 2                        # 0x96 XCHG AX, SI
    db  execute_xchg_ax_w, arg_di, 2                        # 0x97 XCHG AX, DI

    db  not_implemented, 0, 0 # TODO x   db  execute_cbw, 0                                  # 0x98 CBW
    db  not_implemented, 0, 0 # TODO x   db  execute_cwd, 0                                  # 0x99 CWD
    db  not_implemented, 0, 0 # TODO    db  execute_call, arg_far_ptr                       # 0x9a CALL FAR-PROC
    db  not_implemented, 0, 0 # TODO    db  execute_wait, 0                                 # 0x9b WAIT
    db  execute_pushf, 0, 0                                 # 0x9c PUSHF
    db  execute_popf, 0, 0                                  # 0x9d POPF
    db  execute_sahf, 0, 0                                  # 0x9e SAHF
    db  execute_lahf, 0, 0                                  # 0x9f LAHF

    db  execute_mov_b, arg_al_ax_near_ptr_dst, 4            # 0xa0 MOV AL, MEM8
    db  execute_mov_w, arg_al_ax_near_ptr_dst, 4            # 0xa1 MOV AX, MEM16
    db  execute_mov_b, arg_al_ax_near_ptr_src, 4            # 0xa2 MOV MEM8, AL
    db  execute_mov_w, arg_al_ax_near_ptr_src, 4            # 0xa3 MOV MEM16, AX

    db  not_implemented, 0, 0 # TODO    db  execute_movs_b, 0                               # 0xa4 MOVS DEST-STR8, SRC-STR8
    db  not_implemented, 0, 0 # TODO    db  execute_movs_w, 0                               # 0xa5 MOVS DEST-STR16, SRC-STR16
    db  not_implemented, 0, 0 # TODO    db  execute_cmps_b, 0                               # 0xa6 CMPS DEST-STR8, SRC-STR8
    db  not_implemented, 0, 0 # TODO    db  execute_cmps_w, 0                               # 0xa7 CMPS DEST-STR16, SRC-STR16

    db  execute_test_b, arg_al_immediate_b, 4               # 0xa8 TEST AL, IMMED8
    db  execute_test_w, arg_ax_immediate_w, 4               # 0xa9 TEST AX, IMMED16

    db  not_implemented, 0, 0 # TODO    db  execute_stos_b, 0                               # 0xaa STOS DEST-STR8
    db  not_implemented, 0, 0 # TODO    db  execute_stos_w, 0                               # 0xab STOS DEST-STR16
    db  not_implemented, 0, 0 # TODO    db  execute_lods_b, 0                               # 0xac LODS SRC-STR8
    db  not_implemented, 0, 0 # TODO    db  execute_lods_w, 0                               # 0xad LODS SRC-STR16
    db  not_implemented, 0, 0 # TODO    db  execute_scas_b, 0                               # 0xae SCAS DEST-STR8
    db  not_implemented, 0, 0 # TODO    db  execute_scas_w, 0                               # 0xaf SCAS DEST-STR16

    db  execute_mov_b, arg_al_immediate_b, 4                # 0xb0 MOV AL, IMMED8
    db  execute_mov_b, arg_cl_immediate_b, 4                # 0xb1 MOV CL, IMMED8
    db  execute_mov_b, arg_dl_immediate_b, 4                # 0xb2 MOV DL, IMMED8
    db  execute_mov_b, arg_bl_immediate_b, 4                # 0xb3 MOV BL, IMMED8
    db  execute_mov_b, arg_ah_immediate_b, 4                # 0xb4 MOV AH, IMMED8
    db  execute_mov_b, arg_ch_immediate_b, 4                # 0xb5 MOV CH, IMMED8
    db  execute_mov_b, arg_dh_immediate_b, 4                # 0xb6 MOV DH, IMMED8
    db  execute_mov_b, arg_bh_immediate_b, 4                # 0xb7 MOV BH, IMMED8

    db  execute_mov_w, arg_ax_immediate_w, 4                # 0xb8 MOV AX, IMMED16
    db  execute_mov_w, arg_cx_immediate_w, 4                # 0xb9 MOV CX, IMMED16
    db  execute_mov_w, arg_dx_immediate_w, 4                # 0xba MOV DX, IMMED16
    db  execute_mov_w, arg_bx_immediate_w, 4                # 0xbb MOV BX, IMMED16
    db  execute_mov_w, arg_sp_immediate_w, 4                # 0xbc MOV SP, IMMED16
    db  execute_mov_w, arg_bp_immediate_w, 4                # 0xbd MOV BP, IMMED16
    db  execute_mov_w, arg_si_immediate_w, 4                # 0xbe MOV SI, IMMED16
    db  execute_mov_w, arg_di_immediate_w, 4                # 0xbf MOV DI, IMMED16

    db  invalid_opcode, 0, 0                                # 0xc0
    db  invalid_opcode, 0, 0                                # 0xc1

    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_immediate_w               # 0xc2 RET IMMED16 (within segment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_zero                      # 0xc3 RET (within segment)

    db  not_implemented, 0, 0 # TODO x   db  execute_les_w, arg_mod_reg_mem_dst_w            # 0xc4 LES REG16, MEM16
    db  not_implemented, 0, 0 # TODO x   db  execute_lds_w, arg_mod_reg_mem_dst_w            # 0xc5 LDS REG16, MEM16

    db  execute_mov_b, arg_mod_000_rm_immediate_b, 4        # 0xc6 MOV MEM8, IMMED8
    db  execute_mov_w, arg_mod_000_rm_immediate_w, 4        # 0xc7 MOV MEM16, IMMED16

    db  invalid_opcode, 0, 0                                # 0xc8
    db  invalid_opcode, 0, 0                                # 0xc9

    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_immediate_w                # 0xca RET IMMED16 (intersegment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_zero                       # 0xcb RET (intersegment)

    db  execute_int3, 0, 0                                  # 0xcc INT 3
    db  execute_int, 0, 0                                   # 0xcd INT IMMED8

    db  execute_into, 0, 0                                  # 0xce INTO
    db  execute_iret, 0, 0                                  # 0xcf IRET

    # <shift>: 000 ROL, 001 ROR, 010 RCL, 011 RCR, 100 SAL/SHL, 101 SHR,          111 SAR
    db  not_implemented, 0, 0 # TODO    db  execute_shift_b, arg_mod_shift_rm_1_b           # 0xd0 <shift> REG8/MEM8, 1
    db  not_implemented, 0, 0 # TODO    db  execute_shift_w, arg_mod_shift_rm_1_w           # 0xd1 <shift> REG16/MEM16, 1
    db  not_implemented, 0, 0 # TODO    db  execute_shift_b, arg_mod_shift_rm_cl_b          # 0xd2 <shift> REG8/MEM8, CL
    db  not_implemented, 0, 0 # TODO    db  execute_shift_w, arg_mod_shift_rm_cl_w          # 0xd3 <shift> REG16/MEM16, CL

    db  not_implemented, 0, 0 # TODO    db  execute_aam, 0                                  # 0xd4 AAM
    db  not_implemented, 0, 0 # TODO    db  execute_aad, 0                                  # 0xd5 AAD
    db  invalid_opcode, 0, 0                                # 0xd6
    db  not_implemented, 0, 0 # TODO x   db  execute_xlat, 0                                 # 0xd7 XLAT SOURCE-TABLE

    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_000                        # 0xd8 ESC OPCODE, SOURCE (2 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xd9 ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xda ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xdb ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xdc ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xdd ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_yyy                        # 0xde ESC OPCODE, SOURCE (4 bytes)
    db  not_implemented, 0, 0 # TODO    db  execute_esc, arg_esc_111                        # 0xdf ESC OPCODE, SOURCE (2 bytes)

    db  not_implemented, 0, 0 # TODO    db  execute_loopne, arg_short_ptr                   # 0xe0 LOOPNE/LOOPNZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_loope, arg_short_ptr                    # 0xe1 LOOPE/LOOPZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_loop, arg_short_ptr                     # 0xe2 LOOP SHORT-LABEL
    db  execute_jcxz, 0, 0                                  # 0xe3 JCXZ SHORT-LABEL

    db  not_implemented, 0, 0 # TODO    db  execute_in_al_immediate_b, 0, 0                 # 0xe4 IN AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_in_ax_immediate_b, 0, 0                 # 0xe5 IN AX, IMMED8
    db  execute_out_al_immediate_b, 0, 0                    # 0xe6 OUT AL, IMMED8
    db  execute_out_ax_immediate_b, 0, 0                    # 0xe7 OUT AX, IMMED8

    db  not_implemented, 0, 0 # TODO    db  execute_call, arg_near_ptr                      # 0xe8 CALL NEAR-PROC
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_near_ptr                       # 0xe9 JMP NEAR-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_far_ptr                        # 0xea JMP FAR-LABEL
    db  execute_jmp_short, 0, 0                             # 0xeb JMP SHORT-LABEL

    db  not_implemented, 0, 0 # TODO    db  execute_in_al_dx, 0, 0                          # 0xec IN AL, DX
    db  not_implemented, 0, 0 # TODO    db  execute_in_ax_dx, 0, 0                          # 0xed IN AX, DX
    db  execute_out_al_dx, 0, 0                             # 0xee OUT AL, DX
    db  execute_out_ax_dx, 0, 0                             # 0xef OUT AX, DX

    db  execute_lock, 0, 0                                  # 0xf0 LOCK (prefix)
    db  invalid_opcode, 0, 0                                # 0xf1
    db  execute_repnz, 0, 0                                 # 0xf2 REPNE/REPNZ
    db  execute_repz, 0, 0                                  # 0xf3 REP/REPE/REPZ

    # HLT instruction is processed as part of the 'execute' loop
    db  invalid_opcode, 0, 0                                # 0xf4 HLT
    db  execute_cmc, 0, 0                                   # 0xf5 CMC

    # <group 1>:
    # 000 TEST REG/MEM, IMMED
    # 001 (not used)
    # 010 NOT REG/MEM
    # 011 NEG REG/MEM
    # 100 MUL REG/MEM
    # 101 IMUL REG/MEM
    # 110 DIV REG/MEM
    # 111 IDIV REG/MEM
    db  not_implemented, 0, 0 # TODO    db  execute_group1_b, 0, 0                          # 0xf6 <group 1> 8-bit
    db  not_implemented, 0, 0 # TODO    db  execute_group1_w, 0, 0                          # 0xf7 <group 1> 16-bit

    db  execute_clc, 0, 0                                   # 0xf8 CLC
    db  execute_stc, 0, 0                                   # 0xf9 STC
    db  execute_cli, 0, 0                                   # 0xfa CLI
    db  execute_sti, 0, 0                                   # 0xfb STI
    db  execute_cld, 0, 0                                   # 0xfc CLD
    db  execute_std, 0, 0                                   # 0xfd STD

    # <group 2> 8-bit:
    # 000 INC REG8/MEM8
    # 001 DEC REG8/MEM8
    # (rest not used)
    db  execute_group2_b, arg_mod_op_rm_b, 3                # 0xfe <group 2> REG8/MEM8

    # <group 2> 16-bit:
    # 000 INC MEM16
    # 001 DEC MEM16
    # 010 CALL REG16/MEM16 (within segment)
    # 011 CALL MEM16 (intersegment)
    # 100 JMP REG16/MEM16 (within segment)
    # 101 JMP MEM16 (intersegment)
    # 110 PUSH MEM16
    # 111 (not used)
    db  execute_group2_w, arg_mod_op_rm_w, 3                # 0xff <group 2> REG16/MEM16

.EOF
