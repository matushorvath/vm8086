cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section data_segment start=0x10000

    dw 23 dup (0x0000)
test_ds:
    dw  0


section stack_segment start=0x20000

    dw 17 dup (0x0000)
test_ss:
    dw  0


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

    ; set up for testing MOD RM
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    mov bx, 5
    mov bp, 7
    mov si, 11
    mov di, 13

    ; MOV MEM8, REG8
    mov ax, 0x00ab
    mov cx, 0x0000
    mov dx, 0x0000

    mov [bx + si + test_ds], al
    mov ah, [5 + 11 + test_ds]

    mov [bx + di + test_ds], al
    mov cl, [5 + 13 + test_ds]

    mov [si + test_ds], al
    mov ch, [11 + test_ds]

    mov [di + test_ds], al
    mov dl, [13 + test_ds]

    mov [bx + test_ds], al
    mov dh, [5 + test_ds]

    out 0x42, al

    mov ax, 0x00cd
    mov cx, 0x0000
    mov dx, 0x0000

    ; TODO needs segment overrride
    ; mov [bp + test_ss], al
    ; mov ah, [ss:7 + test_ds]

    ; TODO needs segment overrride
    ; mov [bp + si + test_ss], al
    ; mov cl, [ss:7 + 11 + test_ss]

    ; TODO needs segment overrride
    ; mov [bp + di + test_ss], al
    ; mov ch, [ss:7 + 13 + test_ss]

    mov [test_ds], al
    mov dl, [si - 11 + test_ds]

    out 0x42, al

    ; MOV REG8, MEM8
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11 + test_ds], al
    mov ah, [bx + si + test_ds]

    mov [5 + 13 + test_ds], al
    mov cl, [bx + di + test_ds]

    mov [11 + test_ds], al
    mov ch, [si + test_ds]

    mov [13 + test_ds], al
    mov dl, [di + test_ds]

    mov [5 + test_ds], al
    mov dh, [bx + test_ds]

    out 0x42, al

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    ; TODO needs segment overrride
    ; mov [ss:7 + test_ds], al
    ; mov ah, [bp + test_ss]

    ; TODO needs segment overrride
    ; mov [ss:7 + 11 + test_ss], al
    ; mov cl, [bp + si + test_ss]

    ; TODO needs segment overrride
    ; mov [ss:7 + 13 + test_ss], al
    ; mov ch, [bp + di + test_ss]

    mov [si - 11 + test_ds], al
    mov dl, [test_ds]

    out 0x42, al

;    db  decode_mod_rm_memory_bx_si
;    db  decode_mod_rm_memory_bx_di
;    db  decode_mod_rm_memory_bp_si
;    db  decode_mod_rm_memory_bp_di
;    db  decode_mod_rm_memory_si
;    db  decode_mod_rm_memory_di
;    db  decode_mod_rm_memory_bp
;    db  decode_mod_rm_memory_bx
;    db  decode_mod_rm_memory_direct

; TODO test 8-bit displacement, no displacement; verify above is 16-bit
; TODO force NASM to generate also the other variants for MOV REG8/REG8, REG8/REG16 (src/dst)

; TODO MOV MEM8, REG8
; TODO MOV MEM16, REG16
; TODO MOV REG8, MEM8
; TODO MOV REG16, MEM16

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
