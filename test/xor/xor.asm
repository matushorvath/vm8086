; TODO XOR REG16/MEM16, REG16
; TODO XOR REG16, REG16/MEM16
; TODO XOR AX, IMMED16

; TODO <immed> REG8/MEM8, IMMED8
; TODO <immed> REG16/MEM16, IMMED16

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .data start=0x10000

    dw  7 dup 0x0000

data:
    dw  0


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    mov dx, 0x1000
    mov ds, dx

    out 0x42, al

    ; test various addressing modes, 8-bit
    mov al, 01010101b
    xor al, 11001100b                   ; XOR AL, IMMED8

    mov ah, 01010101b
    mov bl, 11001100b
    xor ah, bl                          ; XOR REG8, REG8

    mov bl, 01010101b
    mov byte [data], 11001100b
    xor byte [data], bl                 ; XOR MEM8, REG8
    mov bl, byte [data]

    mov bh, 01010101b
    mov byte [data], 11001100b          ; XOR REG8, MEM8
    xor bh, byte [data]

    out 0x42, al

    ; test flags, 8-bit
%macro clearf 0
    mov dx, 0
    push dx
    popf
%endmacro

    ; SF = 1
    mov al, 01010101b
    clearf
    xor al, 11001100b
    out 0x42, al

    ; ZF = 1
    mov al, 01010101b
    clearf
    xor al, 01010101b
    out 0x42, al

    ; PF = 1
    mov al, 01010101b
    clearf
    xor al, 01001100b
    out 0x42, al

    hlt


section boot start=0xffff0              ; boot
    int3
