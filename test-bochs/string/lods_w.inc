; LODS 16-bit

    mov cx, 0

    mark 0xb0

    ; standalone instruction
    mov ax, 0
    cld
    mov si, src_data - src_addr + 11
    lodsw

    dump_state

    ; REP with increment
    mov ax, 0
    cld
    mov si, src_data - src_addr + 17
    mov cx, 7
    rep lodsw

    dump_state

    ; REP with decrement
    mov ax, 0
    std
    mov si, src_data - src_addr + 21
    mov cx, 5
    rep lodsw

    dump_state

    cld
