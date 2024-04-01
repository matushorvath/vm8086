; ADC 8-bit, with input carry

    stc
    mov bl, 0x00
    mov bh, 0x00
    add bl, bh
    pushf

    stc
    mov bh, 0x12
    mov cl, 0x33
    add bh, cl
    pushf

    stc
    mov cl, 0x50
    mov ch, 0x2e
    add cl, ch
    pushf

    stc
    mov ch, 0x75
    mov dl, 0x0a
    add ch, dl
    pushf

    stc
    mov dl, 0x61
    mov dh, 0x34
    add dl, dh
    pushf

    stc
    mov dl, 0x81
    mov dh, 0x29
    add dl, dh
    pushf

    dump_state

    stc
    mov bl, 0x7d
    mov bh, 0x81
    add bl, bh
    pushf

    stc
    mov bh, 0xa9
    mov cl, 0x56
    add bh, cl
    pushf

    stc
    mov cl, 0xec
    mov ch, 0x3a
    add cl, ch
    pushf

    stc
    mov ch, 0xba
    mov dl, 0x88
    add ch, dl
    pushf

    stc
    mov dl, 0xff
    mov dh, 0x7f
    add dl, dh
    pushf

    stc
    mov dl, 0xec
    mov dh, 0xda
    add dl, dh
    pushf

    dump_state
