; SUB 8-bit

    clc
    mov bl, 0x00
    mov bh, 0x00
    sub bl, bh
    pushf

    stc
    mov bh, 0x12
    mov cl, 0x12
    sub bh, cl
    pushf

    clc
    mov cl, 0x7f
    mov ch, 0x7f
    sub cl, ch
    pushf

    stc
    mov ch, 0x80
    mov dl, 0x80
    sub ch, dl
    pushf

    clc
    mov dl, 0xdc
    mov dh, 0xdc
    sub dl, dh
    pushf

    stc
    mov dl, 0xff
    mov dh, 0xff
    sub dl, dh
    pushf

    dump_state

    clc
    mov bl, 0x98
    mov bh, 0x43
    sub bl, bh
    pushf

    stc
    mov bh, 0x23
    mov cl, 0xde
    sub bh, cl
    pushf

    clc
    mov cl, 0x00
    mov ch, 0x81
    sub cl, ch
    pushf

    stc
    mov ch, 0x12
    mov dl, 0x93
    sub ch, dl
    pushf

    clc
    mov dl, 0xa0
    mov dh, 0x21
    sub dl, dh
    pushf

    stc
    mov dl, 0x7f
    mov dh, 0x00
    sub dl, dh
    pushf

    dump_state

    clc
    mov bl, 0x80
    mov bh, 0x00
    sub bl, bh
    pushf

    stc
    mov bh, 0x00
    mov cl, 0x80
    sub bh, cl
    pushf

    clc
    mov cl, 0xcd
    mov ch, 0x4d
    sub cl, ch
    pushf

    stc
    mov ch, 0x23
    mov dl, 0xa3
    sub ch, dl
    pushf

    clc
    mov dl, 0xab
    mov dh, 0xcd
    sub dl, dh
    pushf

    stc
    mov dl, 0x98
    mov dh, 0x03
    sub dl, dh
    pushf

    dump_state

    clc
    mov bl, 0x34
    mov bh, 0x56
    sub bl, bh
    pushf

    stc
    mov bh, 0xff
    mov cl, 0x00
    sub bh, cl
    pushf

    clc
    mov cl, 0x00
    mov ch, 0x01
    sub cl, ch
    pushf

    stc
    mov ch, 0x12
    mov dl, 0x13
    sub ch, dl
    pushf

    clc
    mov dl, 0xe4
    mov dh, 0xe5
    sub dl, dh
    pushf

    dump_state
