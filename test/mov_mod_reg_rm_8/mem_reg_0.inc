    ; MOV MEM8, REG8 (no displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [byte bx + si], dh
    mov al, [5 + 11]

    mov [byte bx + di], dh
    mov ah, [5 + 13]

    mov [byte si], dh
    mov cl, [11]

    mov [byte di], dh
    mov ch, [13]

    mov [byte bx], dh
    mov dl, [5]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    ; TODO needs segment overrride
    ; mov [byte bp], dh
    ; mov al, [ss:7]

    ; TODO needs segment overrride
    ; mov [byte bp + si], dh
    ; mov ah, [ss:7 + 11]

    ; TODO needs segment overrride
    ; mov [byte bp + di], dh
    ; mov cl, [ss:7 + 13]

    out 0x42, al
