; TODO <immed> REG16/MEM16, IMMED16

    ; test various addressing modes, 16-bit
    mov ax, 01010101_01010101b
    xor ax, 11001100_11001100b          ; XOR AL, IMMED16

    mov bx, 01010101_01010101b
    mov cx, 11001100_11001100b
    xor bx, cx                          ; XOR REG16, REG16

    mov cx, 01010101_01010101b
    mov word [data], 11001100_11001100b
    xor word [data], cx                 ; XOR MEM16, REG16
    mov cx, word [data]

    mov dx, 01010101_01010101b
    mov word [data], 11001100_11001100b
    xor dx, word [data]                 ; XOR REG16, MEM16

    out 0x42, al

    ; test flags, 16-bit

    ; SF = 1
    mov ax, 01010101_01010101b
    clearf
    xor ax, 11001100_11001100b
    out 0x42, al

    ; ZF = 1
    mov ax, 01010101_01010101b
    clearf
    xor ax, 01010101_01010101b
    out 0x42, al

    ; PF = 1
    mov ax, 01010101_01010101b
    clearf
    xor ax, 01001100_01001100b
    out 0x42, al
