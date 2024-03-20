.EXPORT execute_mov_b
.EXPORT execute_mov_w

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

##########
execute_mov_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the target value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b() -> param3
    arb -3
    call write_location_b

    ret 4
.ENDFRAME

##########
execute_mov_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w

    # Write the target value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_b().hi -> param4
    arb -4
    call write_location_w

    ret 4
.ENDFRAME

.EOF

TODO

    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_al_near_ptr_dst_b            # 0xa0 MOV AL, MEM8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_ax_near_ptr_dst_w            # 0xa1 MOV AX, MEM16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_al_near_ptr_src_b            # 0xa2 MOV MEM8, AL
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_ax_near_ptr_src_w            # 0xa3 MOV MEM16, AX

    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_al_immediate_b               # 0xb0 MOV AL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_cl_immediate_b               # 0xb1 MOV CL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_dl_immediate_b               # 0xb2 MOV DL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_bl_immediate_b               # 0xb3 MOV BL, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_ah_immediate_b               # 0xb4 MOV AH, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_ch_immediate_b               # 0xb5 MOV CH, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_dh_immediate_b               # 0xb6 MOV DH, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_bh_immediate_b               # 0xb7 MOV BH, IMMED8

    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_ax_immediate_w               # 0xb8 MOV AX, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_cx_immediate_w               # 0xb9 MOV CX, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_dx_immediate_w               # 0xba MOV DX, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_bx_immediate_w               # 0xbb MOV BX, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_sp_immediate_w               # 0xbc MOV SP, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_bp_immediate_w               # 0xbd MOV BP, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_si_immediate_w               # 0xbe MOV SI, IMMED16
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_di_immediate_w               # 0xbf MOV DI, IMMED16

    db  not_implemented, 0, 0 # TODO    db  execute_mov_b, arg_mod_000_rm_immediate_b       # 0xc6 MOV MEM8, IMMED8
    db  not_implemented, 0, 0 # TODO    db  execute_mov_w, arg_mod_000_rm_immediate_w       # 0xc7 MOV MEM16, IMMED16

    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_cx                          # 0x91 XCHG AX, CX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_dx                          # 0x92 XCHG AX, DX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_bx                          # 0x93 XCHG AX, BX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_sp                          # 0x94 XCHG AX, SP
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_bp                          # 0x95 XCHG AX, BP
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_si                          # 0x96 XCHG AX, SI
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_di                          # 0x97 XCHG AX, DI
