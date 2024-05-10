    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov si, 0
    mov di, 0
    mov bp, 0

    ; shift by various amounts
    mov ax, 0b_10110010_01001101
    clearf
    sar ax, 1
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 0
    clearf
    sar bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 1
    clearf
    sar dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 2
    clearf
    sar si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 3
    clearf
    sar di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 4
    clearf
    sar ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 5
    clearf
    sar bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 6
    clearf
    sar dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 7
    clearf
    sar si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 8
    clearf
    sar di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 9
    clearf
    sar ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 10
    clearf
    sar bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 11
    clearf
    sar dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 12
    clearf
    sar si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 13
    clearf
    sar di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 14
    clearf
    sar ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 15
    clearf
    sar bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 16
    clearf
    sar dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 17
    clearf
    sar si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 18
    clearf
    sar di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 0x7f
    clearf
    sar ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 0xff
    clearf
    sar bx, cl
    pushf

    ; test various addressing modes, 16-bit
    mov word [data], 0b_10110010_01001101
    clearf
    sar word [data], 1
    mov si, [data]

    mov bp, data
    mov word [bp], 0b_10110010_01001101
    clearf
    sar word [bp], 1
    mov di, [bp]

    dump_state
