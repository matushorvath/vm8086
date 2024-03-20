cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; MOV REG8, REG8
    mov al, 0xab
    mov ah, al
    ; TODO inc ah
    mov bl, ah
    ; TODO inc bl
    mov bh, bl
    ; TODO inc bh
    mov cl, bh
    ; TODO inc cl
    mov ch, cl
    ; TODO inc ch
    mov dl, ch
    ; TODO inc dl
    mov dh, dl
    ; TODO inc dh
    mov al, dh
    ; TODO inc al

    out 0x42, al

    ; MOV REG16, REG16
    mov ax, 0x4321
    mov bx, ax
    inc bx
    mov cx, bx
    inc cx
    mov dx, cx
    inc dx
    mov sp, dx                          ; breaks stack
    inc sp
    mov bp, sp
    inc bp
    mov si, bp
    inc si
    mov di, si
    inc di
    mov ax, di
    inc ax

    out 0x42, al

    ; MOV REG, IMMED8
    mov al, 0x01
    mov ah, 0x12
    mov bl, 0x23
    mov bh, 0x34
    mov cl, 0x45
    mov ch, 0x56
    mov dl, 0x67
    mov dh, 0x78

    out 0x42, al

    ; MOV REG, IMMED16
    mov ax, 0xfedc
    mov bx, 0xedcb
    mov cx, 0xba98
    mov dx, 0xa987
    mov sp, 0x7654                      ; breaks stack
    mov bp, 0x6543
    mov si, 0x3210
    mov di, 0x210f

    out 0x42, al

; TODO test the sp:bp case
; TODO test all the mod reg rm cases
; TODO check the sources and do white boxing
; TODO test mov reg, [addr + displacement], 8-bit and 16-bit

; TODO MOV REG8/MEM8, REG8
; TODO MOV REG16/MEM16, REG16
; TODO MOV REG8, REG8/MEM8
; TODO MOV REG16, REG16/MEM16

; TODO MOV MEM8, IMMED8
; TODO MOV MEM16, IMMED16

; TODO MOV AL, MEM8
; TODO MOV AX, MEM16
; TODO MOV MEM8, AL
; TODO MOV MEM16, AX

    hlt


section boot start=0xffff0              ; boot
    int3


; TODO new test for XCHG

; XCHG AX, CX
; XCHG AX, DX
; XCHG AX, BX
; XCHG AX, SP
; XCHG AX, BP
; XCHG AX, SI
; XCHG AX, DI

; XCHG REG8, REG8/MEM8
; XCHG REG16, REG16/MEM16
