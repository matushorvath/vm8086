; XCHG REG8, REG8

    mov al, 0x11
    mov ah, 0x22
    mov bl, 0x33
    mov bh, 0x44
    mov cl, 0x55
    mov ch, 0x66
    mov dl, 0x77
    mov dh, 0x88

    dump_state

    xchg dh, dl

    dump_state

    xchg dl, ch
    xchg ch, cl
    xchg cl, bh
    xchg bh, bl
    xchg bl, ah
    xchg ah, al
    xchg dh, al

    dump_state
