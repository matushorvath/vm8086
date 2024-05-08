; MOVS 8-bit

    mark 0x80

    ; standalone instruction
    mov si, src_data - src_addr + 5
    mov di, dst_data - dst_addr
    movsb

    dump_state

    ; REP with increment
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 1
    mov cx, 13
    rep movsb

    dump_state

    ; REP with decrement
    mov si, src_data - src_addr + 11
    mov di, dst_data - dst_addr + 15
    mov cx, 7
    std
    rep movsb

    dump_state

    cld
