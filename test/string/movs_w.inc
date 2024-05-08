; MOVS 16-bit

    mark 0x80

    ; standalone instruction
    cld
    mov si, src_data - src_addr + 11
    mov di, dst_data - dst_addr
    movsw

    dump_state

    ; REP with increment
    cld
    mov si, src_data - src_addr + 17
    mov di, dst_data - dst_addr + 1
    mov cx, 7
    rep movsw

    dump_state

    ; REP with decrement
    std
    mov si, src_data - src_addr + 21
    mov di, dst_data - dst_addr + 15
    mov cx, 5
    rep movsw

    dump_state

    cld
