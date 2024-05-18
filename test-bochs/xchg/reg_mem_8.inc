; XCHG REG8, MEM8

    mov ax, bss_seg
    mov ds, ax
    mov byte [ds:data], 0x46

    mov al, 0x11
    mov ah, 0x22
    mov bl, 0x33
    mov bh, 0x44
    mov cl, 0x55
    mov ch, 0x66
    mov dl, 0x77
    mov dh, 0x88

    dump_state

    xchg al, [ds:data]

    dump_state

    xchg ah, [ds:data]
    xchg bl, [ds:data]
    xchg bh, [ds:data]
    xchg [ds:data], cl
    xchg [ds:data], ch
    xchg [ds:data], dl
    xchg [ds:data], dh

    dump_state
