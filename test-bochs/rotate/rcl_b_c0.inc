    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov si, 0
    mov di, 0
    mov bp, 0

    ; rotate by various amounts
    mov ah, 0b_10110010
    clearf
    rcl ah, 1
    pushf

    mov al, 0b_10110010
    mov cl, 0
    clearf
    rcl al, cl
    pushf

    mov bh, 0b_10110010
    mov cl, 1
    clearf
    rcl bh, cl
    pushf

    mov bl, 0b_10110010
    mov cl, 2
    clearf
    rcl bl, cl
    pushf

    mov ch, 0b_10110010
    mov cl, 3
    clearf
    rcl ch, cl
    pushf

    mov dh, 0b_10110010
    mov cl, 4
    clearf
    rcl dh, cl
    pushf

    mov dl, 0b_10110010
    mov cl, 5
    clearf
    rcl dl, cl
    pushf

    dump_state

    mov ah, 0b_10110010
    mov cl, 6
    clearf
    rcl ah, cl
    pushf

    mov al, 0b_10110010
    mov cl, 7
    clearf
    rcl al, cl
    pushf

    mov bh, 0b_10110010
    mov cl, 8
    clearf
    rcl bh, cl
    pushf

    mov bl, 0b_10110010
    mov cl, 9
    clearf
    rcl bl, cl
    pushf

    mov ch, 0b_10110010
    mov cl, 10
    clearf
    rcl ch, cl
    pushf

    ; do not test CL beyond 2^32, since 286 and newer processors ignore them (as does bochs)
    mov dh, 0b_10110010
    mov cl, 0x0f
    clearf
    rcl dh, cl
    pushf

    mov dl, 0b_10110010
    mov cl, 0x1f
    clearf
    rcl dl, cl
    pushf

    dump_state

    ; test various addressing modes, 8-bit
    mov byte [data], 0b_10110010
    clearf
    rcl byte [data], 1
    mov ah, [data]

    mov bp, data
    mov byte [bp], 0b_10110010
    clearf
    rcl byte [bp], 1
    mov al, [bp]

    dump_state
