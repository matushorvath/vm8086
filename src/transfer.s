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

    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_cx                          # 0x91 XCHG AX, CX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_dx                          # 0x92 XCHG AX, DX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_bx                          # 0x93 XCHG AX, BX
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_sp                          # 0x94 XCHG AX, SP
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_bp                          # 0x95 XCHG AX, BP
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_si                          # 0x96 XCHG AX, SI
    db  not_implemented, 0, 0 # TODO    db  execute_xchg_w, arg_di                          # 0x97 XCHG AX, DI
