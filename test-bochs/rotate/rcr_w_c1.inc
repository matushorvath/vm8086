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
    clearf 0b_00000000_00000001
    rcr ax, 1
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0
    clearf 0b_00000000_00000001
    rcr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 1
    clearf 0b_00000000_00000001
    rcr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 2
    clearf 0b_00000000_00000001
    rcr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 3
    clearf 0b_00000000_00000001
    rcr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 4
    clearf 0b_00000000_00000001
    rcr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 5
    clearf 0b_00000000_00000001
    rcr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 6
    clearf 0b_00000000_00000001
    rcr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 7
    clearf 0b_00000000_00000001
    rcr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 8
    clearf 0b_00000000_00000001
    rcr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 9
    clearf 0b_00000000_00000001
    rcr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 10
    clearf 0b_00000000_00000001
    rcr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 11
    clearf 0b_00000000_00000001
    rcr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 12
    clearf 0b_00000000_00000001
    rcr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 13
    clearf 0b_00000000_00000001
    rcr di, cl
    pushf

    dump_state

    mov ax, 0b_01001101_10110010
    mov cl, 14
    clearf 0b_00000000_00000001
    rcr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 15
    clearf 0b_00000000_00000001
    rcr bx, cl
    pushf

    mov dx, 0b_01001101_10110010
    mov cl, 16
    clearf 0b_00000000_00000001
    rcr dx, cl
    pushf

    mov si, 0b_01001101_10110010
    mov cl, 17
    clearf 0b_00000000_00000001
    rcr si, cl
    pushf

    mov di, 0b_01001101_10110010
    mov cl, 18
    clearf 0b_00000000_00000001
    rcr di, cl
    pushf

    dump_state

    ; do not test CL beyond 2^32, since 286 and newer processors ignore them (as does bochs)
    mov ax, 0b_01001101_10110010
    mov cl, 0x0f
    clearf 0b_00000000_00000001
    rcr ax, cl
    pushf

    mov bx, 0b_01001101_10110010
    mov cl, 0x1f
    clearf 0b_00000000_00000001
    rcr bx, cl
    pushf

    ; test various addressing modes, 16-bit
    mov word [data], 0b_01001101_10110010
    clearf 0b_00000000_00000001
    rcr word [data], 1
    mov si, [data]

    mov bp, data
    mov word [bp], 0b_01001101_10110010
    clearf 0b_00000000_00000001
    rcr word [bp], 1
    mov di, [bp]

    dump_state
