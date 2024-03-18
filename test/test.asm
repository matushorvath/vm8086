[map test.map]

cpu 8086

; TODO:
; set overflow, INTO
; move the int x test to a different interrupt, perhaps interrupt from interrupt? how is it with IF?
; OUT with 16-bit dx, 16-bit ax
; reset registers between tests
; CMC CLC STC CLI STI CLD STD, perhaps test with PUSHF/POPF + OUT

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
