    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 16-bit
    mov ax, 0b_01010101_11001100
    xor ax, 0b_11001100_01010101        ; XOR AX, IMMED16

    mov bx, 0b_01010101_11001100
    mov cx, 0b_11001100_01010101
    xor bx, cx                          ; XOR REG16, REG16

    mov cx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    xor word [data], cx                 ; XOR MEM16, REG16
    mov cx, word [data]

    mov dx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    xor dx, word [data]                 ; XOR REG16, MEM16

    out 0x42, al

    ; test flags, 16-bit

    ; SF = 1
    mov ax, 0b_01010101_11001100
    clearf
    xor ax, 0b_11001100_01010101
    out 0x42, al

    ; ZF = 1
    mov ax, 0b_01010101_11001100
    clearf
    xor ax, 0b_01010101_11001100
    out 0x42, al

    ; PF = 1
    mov ax, 0b_01010101_11001100
    clearf
    xor ax, 0b_01001100_01001100
    out 0x42, al

    ; test XOR REG16/MEM16, IMMED16
    mov bx, 0b_01010101_11001100
    xor bx, 0b_11001100_01010101                    ; XOR REG16, IMMED16

    mov word [data], 0b_01010101_11001100
    xor word [data], 0b_11001100_01010101           ; XOR MEM16, IMMED16
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    xor word [ds:bp], 0b_11001100_01010101          ; XOR MEM16, IMMED16
    mov dx, word [data]

    out 0x42, al

    ; test XOR REG16/MEM16, IMMED8, positive value
    mov bx, 0b_01010101_11001100
    xor bx, 0b_01010101                             ; XOR REG16, IMMED8

    mov word [data], 0b_01010101_11001100
    xor word [data], 0b_01010101                    ; XOR MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    xor word [ds:bp], 0b_01010101                   ; XOR MEM16, IMMED8
    mov dx, word [data]

    out 0x42, al

    ; test XOR REG16/MEM16, IMMED8, negative value
    mov bx, 0b_11001100_01010101
    xor bx, 0b_11111111_11001100                    ; XOR REG16, IMMED8

    mov word [data], 0b_11001100_01010101
    xor word [data], 0b_11111111_11001100           ; XOR MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_11001100_01010101
    xor word [ds:bp], 0b_11111111_11001100          ; XOR MEM16, IMMED8
    mov dx, word [data]

    out 0x42, al
