[map test.map]

cpu 8086

; TODO:
; set overflow, INTO
; move the int x test to a different interrupt, perhaps interrupt from interrupt? how is it with IF?
; OUT with 16-bit dx, 16-bit ax
; reset registers between tests
; CMC CLC STC CLI STI CLD STD, perhaps test with PUSHF/POPF + OUT

section interrupts start=0x00000
    dw  0x0000,         0x0000
    dw  0x0000,         0x0000
    dw  0x0000,         0x0000
    dw  handle_int3,    0x8000          ; INT 3
    dw  handle_int4,    0x8000          ; INT 4

handle_int4_data:
    ; TODO move this near handle_int3 once we can mov to segment registers
    dw  0x1234

section .text start=0x80000

handle_int3:                            ; INT 3 handler
    nop

    inc ax
    out 0x11, al

    inc ax
;    inc ah
;    inc ah
;    inc ah
    out 0x22, ax

    inc ax
    inc ax
    dec ax
    inc ax

    dec dx
    inc dx
    inc dx
    inc dx
    inc dx
    inc dx

    out dx, al

    inc bx
    push bx
    pop ax
    out 0x77, ax

    iret

handle_int4:                            ; INT 4 handler
    out 0x80, ax

    mov cx, [handle_int4_data]
    mov ax, cx
    out 0x82, ax

    mov bx, ax
    inc bx
    mov ax, bx
    out 0x84, ax

    mov dx, bx
    mov [handle_int4_data], dx
    inc dx                              ; TODO mov dx, 0
    mov ax, dx
    out 0x86, ax

    mov bx, [handle_int4_data]
    mov ax, bx
    out 0x88, ax

    ; TODO test mov reg, [addr + displacement], 8-bit and 16-bit

    iret

section boot start=0xffff0              ; needs to match simple_test_header.s
    out 0x00, al
    int3
    int 4

    inc dx
    inc ax
    out dx, ax

    hlt
