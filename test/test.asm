[map test.map]

cpu 8086

section interrupts start=0x00000
    dw  0x0000, 0x0000
    dw  0x0000, 0x0000
    dw  0x0000, 0x0000
    dw  0x0000, 0x8000          ; INT3: IP, CS

section .text start=0x80000
    ; INT 3 handler
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

    ; TODO 16-bit dx, 16-bit ax

    inc bx
    push bx
    pop ax
    out 0x77, ax

    iret

section boot start=0xffff0     ; needs to match simple_test_header.s
    out 0x00, al
    int3
    int 3

    inc dx
    inc ax
    out dx, ax

    hlt
