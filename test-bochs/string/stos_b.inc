; STOS 8-bit

    mov ax, 0
    mov cx, 0

    mark 0x50

    ; standalone instruction
    mov al, 0xba
    cld
    mov di, dst_data - dst_addr + 11
    stosb

    dump_state

    ; REP with increment
    mov al, 0x64
    cld
    mov di, dst_data - dst_addr + 1
    mov cx, 7
    rep stosb

    dump_state

    ; REP with decrement
    mov al, 0x23
    std
    mov di, dst_data - dst_addr + 13
    mov cx, 7
    rep stosb

    dump_state

    cld
