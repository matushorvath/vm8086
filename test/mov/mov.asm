cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3

test_data:
    dw  0x1234


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    mov cx, [test_data]
    mov ax, cx
    out 0x42, al

    mov bx, ax
    inc bx
    mov ax, bx
    out 0x42, al

    mov dx, bx
    mov [test_data], dx
    inc dx
    mov ax, dx
    out 0x42, al

    mov si, [test_data]
    mov ax, bx
    out 0x42, al

; TODO write tests once we have mov immediate and can set ds
; TODO test the sp:bp case
; TODO test all the mod reg rm cases
; TODO test big 16-bit numbers, also check the sources and do white boxing
; TODO test mov reg, [addr + displacement], 8-bit and 16-bit

; TODO MOV REG8/MEM8, REG8
; TODO MOV REG16/MEM16, REG16
; TODO MOV REG8, REG8/MEM8
; TODO MOV REG16, REG16/MEM16

    hlt


section boot start=0xffff0              ; boot
    int3
