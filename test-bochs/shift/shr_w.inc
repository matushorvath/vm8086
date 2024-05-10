    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov si, 0
    mov di, 0
    mov bp, 0

    ; shift by various amounts
    mov ax, 0b_01001101_10110010
    clearf
    shr ax, 1
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0
    clearf
    shr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 1
    clearf
    shr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 2
    clearf
    shr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 3
    clearf
    shr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 4
    clearf
    shr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 5
    clearf
    shr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 6
    clearf
    shr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 7
    clearf
    shr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 8
    clearf
    shr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 9
    clearf
    shr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 10
    clearf
    shr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 11
    clearf
    shr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 12
    clearf
    shr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 13
    clearf
    shr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 14
    clearf
    shr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 15
    clearf
    shr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 16
    clearf
    shr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 17
    clearf
    shr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 18
    clearf
    shr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 0x7f
    clearf
    shr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0xff
    clearf
    shr bx, cl
    pushf

    ; test various addressing modes, 16-bit
    mov word [data], 0b_01001101_10110010
    clearf
    shr word [data], 1
    mov si, [data]

    mov bp, data
    mov word [bp], 0b_01001101_10110010
    clearf
    shr word [bp], 1
    mov di, [bp]

    dump_state
