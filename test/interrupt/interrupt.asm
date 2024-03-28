cpu 8086
org 0x00000


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0xd000             ; INT 3
    dw  handle_int4, 0x9000             ; INT 4
    dw  16 dup (0x0000, 0x0000)
    dw  handle_int21, 0xa000            ; INT 21
    dw  233 dup (0x0000, 0x0000)
    dw  handle_int255, 0xb000           ; INT 255


section int3_section start=0xd0000

handle_int3:
    out 0x42, al

    ; should not interrupt
    into
    out 0x42, al

    ; cause an overflow and then interrupt
    mov ax, 0x8000
    dec ax
    into
    out 0x42, al

    iret


section int4_section start=0x90000

handle_int4:
    out 0x42, al

    ; test if interrupt clears TF and IF
    mov dx, 0b_00000011_00000000
    push dx
    popf
    out 0x42, al
    int 255
    out 0x42, al

    ; test restoring flags
    std
    out 0x42, al

    iret


section int21_section start=0xa0000

handle_int21:
    out 0x42, al

    ; interrupt while processing an interrupt
    ; TODO HW should this work? test STI/CLI here?
    int 255
    out 0x42, al

    iret


section int255_section start=0xb0000

handle_int255:
    ; this interrupt needs to just output and return
    out 0x42, al
    iret


section boot start=0xffff0              ; boot
    ; TODO HW should we call STI here to allow interrupts?

    int3
    out 0x42, al

    int 21
    out 0x42, al

    hlt
