; LODS 8-bit

    mov ax, 0
    mov cx, 0

    mark 0x40

    ; standalone instruction
    mov al, 0
    cld
    mov si, src_data - src_addr + 5
    lodsb

    dump_state

    ; REP with increment
    mov al, 0
    cld
    mov si, src_data - src_addr + 7
    mov cx, 13
    rep lodsb

    dump_state

    ; REP with decrement
    mov al, 0
    std
    mov si, src_data - src_addr + 17
    mov cx, 7
    rep lodsb

    dump_state

    cld
