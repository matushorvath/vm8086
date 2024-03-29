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
    dump_state

    int 21
    dump_state

    hlt

handle_int3:
    dump_state

    ; should not interrupt
    into
    dump_state

    ; cause an overflow and then interrupt
    mov ax, 0x8000
    dec ax
    into
    dump_state

    iret

handle_int255:
    ; this interrupt needs to just output and return
    dump_state
    iret


section int_handlers start=0xe0000

handle_int4:
    dump_state

    ; test if interrupt clears TF and IF
    mov dx, 0b_00000011_00000000
    push dx
    popf
    dump_state
    int 255
    dump_state

    ; test restoring flags
    std
    dump_state

    iret

handle_int21:
    dump_state

    ; interrupt while processing an interrupt
    ; TODO HW should this work? test STI/CLI here?
    int 255
    dump_state

    iret
