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
    shl ax, 1
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 0
    clearf
    shl bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 1
    clearf
    shl dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 2
    clearf
    shl si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 3
    clearf
    shl di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 4
    clearf
    shl ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 5
    clearf
    shl bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 6
    clearf
    shl dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 7
    clearf
    shl si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 8
    clearf
    shl di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 9
    clearf
    shl ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 10
    clearf
    shl bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 11
    clearf
    shl dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 12
    clearf
    shl si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 13
    clearf
    shl di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 14
    clearf
    shl ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 15
    clearf
    shl bx, cl
    pushf

    mov dx, 0b_10110010_01001101
    mov cl, 16
    clearf
    shl dx, cl
    pushf

    mov si, 0b_10110010_01001101
    mov cl, 17
    clearf
    shl si, cl
    pushf

    mov di, 0b_10110010_01001101
    mov cl, 18
    clearf
    shl di, cl
    pushf

    dump_state

    mov ax, 0b_10110010_01001101
    mov cl, 0x7f
    clearf
    shl ax, cl
    pushf

    mov bx, 0b_10110010_01001101
    mov cl, 0xff
    clearf
    shl bx, cl
    pushf

    ; test various addressing modes, 16-bit
    mov word [data], 0b_10110010_01001101
    clearf
    shl word [data], 1
    mov si, [data]

    mov bp, data
    mov word [bp], 0b_10110010_01001101
    clearf
    shl word [bp], 1
    mov di, [bp]

    dump_state
