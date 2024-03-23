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

    ; test XOR REG16/MEM16, IMMED16
    mov bx, 01010101_01010101b
    xor bx, 11001100_11001100b                      ; XOR REG16, IMMED16

    mov word [data], 01010101_01010101b
    xor word [data], 11001100_11001100b             ; XOR MEM16, IMMED16
    mov cx, word [data]

    mov bp, data
    mov word [data], 01010101_01010101b
    xor word [ds:bp], 11001100_11001100b            ; XOR MEM16, IMMED16
    mov dx, word [data]

    out 0x42, al

    ; test XOR REG16/MEM16, IMMED8, positive value
    mov bx, 11001100_11001100b
    xor bx, 01010101b                               ; XOR REG16, IMMED8

    mov word [data], 11001100_11001100b
    xor word [data], 01010101b                      ; XOR MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 11001100_11001100b
    xor word [ds:bp], 01010101b                     ; XOR MEM16, IMMED8
    mov dx, word [data]

    out 0x42, al

; TODO use different high and low byte, to catch mixed up lo and hi
