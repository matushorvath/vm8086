    ; MOV MEM16, REG16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [byte bx + si], sp
    mov ax, [5 + 11]

    mov [byte bx + di], sp
    mov cx, [5 + 13]

    mov [byte si], sp
    mov dx, [11]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [byte di], cx
    mov ax, [13]

    mov [byte bx], cx
    mov dx, [5]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    ; TODO needs segment overrride
    ; mov [byte bp], dx
    ; mov ax, [ss:7]

    ; TODO needs segment overrride
    ; mov [byte bp + si], dx
    ; mov cx, [ss:7 + 11]

    ; TODO needs segment overrride
    ; mov [byte bp + di], dx
    ; mov sp, [ss:7 + 13]

    out 0x42, al
