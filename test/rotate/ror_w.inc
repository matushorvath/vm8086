    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov si, 0
    mov di, 0
    mov bp, 0

    ; rotate by various amounts
    mov ax, 0b_01001101_10110010
    clearf
    ror ax, 1
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0
    clearf
    ror bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 1
    clearf
    ror dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 2
    clearf
    ror si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 3
    clearf
    ror di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 4
    clearf
    ror ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 5
    clearf
    ror bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 6
    clearf
    ror dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 7
    clearf
    ror si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 8
    clearf
    ror di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 9
    clearf
    ror ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 10
    clearf
    ror bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 11
    clearf
    ror dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 12
    clearf
    ror si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 13
    clearf
    ror di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 14
    clearf
    ror ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 15
    clearf
    ror bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 16
    clearf
    ror dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 17
    clearf
    ror si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 18
    clearf
    ror di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 0x7f
    clearf
    ror ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0xff
    clearf
    ror bx, cl
    pushf

    ; test various addressing modes, 16-bit
    mov word [data], 0b_01001101_10110010
    clearf
    ror word [data], 1
    mov si, [data]

    mov bp, data
    mov word [bp], 0b_01001101_10110010
    clearf
    ror word [bp], 1
    mov di, [bp]

    dump_state
