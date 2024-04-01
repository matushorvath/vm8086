; ADD 8-bit

    clc
    mov bl, 0x00
    mov bh, 0x00
    add bl, bh
    pushf

    stc
    mov bh, 0x12
    mov cl, 0x34
    add bh, cl
    pushf

    clc
    mov cl, 0x50
    mov ch, 0x2f
    add cl, ch
    pushf

    stc
    mov ch, 0x75
    mov dl, 0x0b
    add ch, dl
    pushf

    clc
    mov dl, 0x61
    mov dh, 0x35
    add dl, dh
    pushf

    stc
    mov dl, 0x81
    mov dh, 0x2a
    add dl, dh
    pushf

    dump_state

    clc
    mov bl, 0x7d
    mov bh, 0x82
    add bl, bh
    pushf

    stc
    mov bh, 0xa9
    mov cl, 0x57
    add bh, cl
    pushf

    clc
    mov cl, 0xec
    mov ch, 0x3b
    add cl, ch
    pushf

    stc
    mov ch, 0xba
    mov dl, 0x89
    add ch, dl
    pushf

    clc
    mov dl, 0xff
    mov dh, 0x80
    add dl, dh
    pushf

    stc
    mov dl, 0xec
    mov dh, 0xdb
    add dl, dh
    pushf

    dump_state
