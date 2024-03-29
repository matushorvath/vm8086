    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 16-bit
    mov ax, 0b_01010101_11001100
    and ax, 0b_11001100_01010101        ; AND AX, IMMED16

    mov bx, 0b_01010101_11001100
    mov cx, 0b_11001100_01010101
    and bx, cx                          ; AND REG16, REG16

    mov cx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    and word [data], cx                 ; AND MEM16, REG16
    mov cx, word [data]

    mov dx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    and dx, word [data]                 ; AND REG16, MEM16

    dump_state

    ; test flags, 16-bit

    ; SF = 1
    mov ax, 0b_11010101_11001100
    clearf
    and ax, 0b_11001100_01010101
    dump_state

    ; ZF = 1
    mov ax, 0b_01010101_11001100
    clearf
    and ax, 0b_10101010_00110011
    dump_state

    ; PF = 1
    mov ax, 0b_01010101_11001101
    clearf
    and ax, 0b_01001100_01001100
    dump_state

    ; test AND REG16/MEM16, IMMED16
    mov bx, 0b_01010101_11001100
    and bx, 0b_11001100_01010101                    ; AND REG16, IMMED16

    mov word [data], 0b_01010101_11001100
    and word [data], 0b_11001100_01010101           ; AND MEM16, IMMED16
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    and word [ds:bp], 0b_11001100_01010101          ; AND MEM16, IMMED16
    mov dx, word [data]

    dump_state

    ; test AND REG16/MEM16, IMMED8, positive value
    mov bx, 0b_01010101_11001100
    and bx, 0b_01010101                             ; AND REG16, IMMED8

    mov word [data], 0b_01010101_11001100
    and word [data], 0b_01010101                    ; AND MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    and word [ds:bp], 0b_01010101                   ; AND MEM16, IMMED8
    mov dx, word [data]

    dump_state

    ; test AND REG16/MEM16, IMMED8, negative value
    mov bx, 0b_11001100_01010101
    and bx, 0b_11111111_11001100                    ; AND REG16, IMMED8

    mov word [data], 0b_11001100_01010101
    and word [data], 0b_11111111_11001100           ; AND MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_11001100_01010101
    and word [ds:bp], 0b_11111111_11001100          ; AND MEM16, IMMED8
    mov dx, word [data]

    dump_state
