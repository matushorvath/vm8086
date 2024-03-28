%include "common.inc"


section interrupts start=0x00000 nobits
                    resw 2 * 3
vector_int3:        resw 2
vector_int4:        resw 2
                    resw 2 * 16
vector_int21:       resw 2
                    resw 2 * 233
vector_int255:      resw 2


section .text
    ; TODO HW should we call STI here to allow interrupts?

    ; set up interrupt handlers
    mov word [vector_int3   + 0], handle_int3
    mov word [vector_int3   + 2], 0xd000
    mov word [vector_int4   + 0], handle_int4
    mov word [vector_int4   + 2], 0xe000
    mov word [vector_int21  + 0], handle_int21
    mov word [vector_int21  + 2], 0xe000
    mov word [vector_int255 + 0], handle_int255
    mov word [vector_int255 + 2], 0xd000

    ; test interrupts
    int3
    out 0x42, al

    int 21
    out 0x42, al

    hlt

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

handle_int255:
    ; this interrupt needs to just output and return
    out 0x42, al
    iret


section int_handlers start=0xe0000

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

handle_int21:
    out 0x42, al

    ; interrupt while processing an interrupt
    ; TODO HW should this work? test STI/CLI here?
    int 255
    out 0x42, al

    iret
