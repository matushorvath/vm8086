; STOS 16-bit

    mov ax, 0
    mov cx, 0

    mark 0xc0

    ; standalone instruction
    mov ax, 0xba98
    cld
    mov di, dst_data - dst_addr + 11
    stosw

    dump_state

    ; REP with increment
    mov ax, 0xa864
    cld
    mov di, dst_data - dst_addr
    mov cx, 5
    rep stosw

    dump_state

    ; REP with decrement
    mov ax, 0x2345
    std
    mov di, dst_data - dst_addr + 13
    mov cx, 3
    rep stosw

    dump_state

    cld
