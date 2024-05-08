; MOVS 8-bit

    mark 0x10

    ; standalone instruction
    cld
    mov si, src_data - src_addr + 5
    mov di, dst_data - dst_addr
    movsb

    dump_state

    ; REP with increment
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 1
    mov cx, 13
    rep movsb

    dump_state

    ; REP with decrement
    std
    mov si, src_data - src_addr + 11
    mov di, dst_data - dst_addr + 15
    mov cx, 7
    rep movsb

    dump_state

    cld
