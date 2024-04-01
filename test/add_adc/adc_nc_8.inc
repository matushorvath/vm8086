; ADC 8-bit, no input carry

    clc
    mov bl, 0x00
    mov bh, 0x00
    adc bl, bh
    pushf

    clc
    mov bh, 0x12
    mov cl, 0x34
    adc bh, cl
    pushf

    clc
    mov cl, 0x50
    mov ch, 0x2f
    adc cl, ch
    pushf

    clc
    mov ch, 0x75
    mov dl, 0x0b
    adc ch, dl
    pushf

    clc
    mov dl, 0x61
    mov dh, 0x35
    adc dl, dh
    pushf

    clc
    mov dl, 0x81
    mov dh, 0x2a
    adc dl, dh
    pushf

    dump_state

    clc
    mov bl, 0x7d
    mov bh, 0x82
    adc bl, bh
    pushf

    clc
    mov bh, 0xa9
    mov cl, 0x57
    adc bh, cl
    pushf

    clc
    mov cl, 0xec
    mov ch, 0x3b
    adc cl, ch
    pushf

    clc
    mov ch, 0xba
    mov dl, 0x89
    adc ch, dl
    pushf

    clc
    mov dl, 0xff
    mov dh, 0x80
    adc dl, dh
    pushf

    clc
    mov dl, 0xff
    mov dh, 0xff
    adc dl, dh
    pushf

    dump_state
