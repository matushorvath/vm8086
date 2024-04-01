; ADC 8-bit, with input carry

    stc
    mov bl, 0x00
    mov bh, 0x00
    adc bl, bh
    pushf

    stc
    mov bh, 0x12
    mov cl, 0x33
    adc bh, cl
    pushf

    stc
    mov cl, 0x50
    mov ch, 0x2e
    adc cl, ch
    pushf

    stc
    mov ch, 0x75
    mov dl, 0x0a
    adc ch, dl
    pushf

    stc
    mov dl, 0x61
    mov dh, 0x34
    adc dl, dh
    pushf

    stc
    mov dl, 0x81
    mov dh, 0x29
    adc dl, dh
    pushf

    dump_state

    stc
    mov bl, 0x7d
    mov bh, 0x81
    adc bl, bh
    pushf

    stc
    mov bh, 0xa9
    mov cl, 0x56
    adc bh, cl
    pushf

    stc
    mov cl, 0xec
    mov ch, 0x3a
    adc cl, ch
    pushf

    stc
    mov ch, 0xba
    mov dl, 0x88
    adc ch, dl
    pushf

    stc
    mov dl, 0xff
    mov dh, 0x7f
    adc dl, dh
    pushf

    stc
    mov dl, 0xff
    mov dh, 0xfe
    adc dl, dh
    pushf

    dump_state
