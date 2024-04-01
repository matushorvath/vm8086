; ADC 8-bit, no input carry

    clc
    mov bl, 0x00
    mov bh, 0x00
    add bl, bh
    pushf

    clc
    mov bh, 0x12
    mov cl, 0x34
    add bh, cl
    pushf

    clc
    mov cl, 0x50
    mov ch, 0x2f
    add cl, ch
    pushf

    clc
    mov ch, 0x75
    mov dl, 0x0b
    add ch, dl
    pushf
    ; TODO flags should be 0892, is 0882
    ; need A

    clc
    mov dl, 0x61
    mov dh, 0x35
    add dl, dh
    pushf

    clc
    mov dl, 0x81
    mov dh, 0x2a
    add dl, dh
    pushf
    ; TODO flags should be 0082, is 0882
    ; need O

    dump_state

    clc
    mov bl, 0x7d
    mov bh, 0x82
    add bl, bh
    pushf
    ; TODO flags should be 0086, is 0886
    ; need O

    clc
    mov bh, 0xa9
    mov cl, 0x57
    add bh, cl
    pushf
    ; TODO flags should be 0057, is 0047
    ; need A

    clc
    mov cl, 0xec
    mov ch, 0x3b
    add cl, ch
    pushf
    ; TODO flags should be 0017, is 0007
    ; need A

    clc
    mov ch, 0xba
    mov dl, 0x89
    add ch, dl
    pushf
    ; TODO flags should be 0813, is 0003
    ; need O A

    clc
    mov dl, 0xff
    mov dh, 0x80
    add dl, dh
    pushf
    ; TODO flags should be 0803, is 0003
    ; need O

    clc
    mov dl, 0xec
    mov dh, 0xdb
    add dl, dh
    pushf
    ; TODO flags should be 0093, is 0883
    ; need O A

    dump_state
