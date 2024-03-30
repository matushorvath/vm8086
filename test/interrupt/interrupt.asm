%include "common.inc"

ints_seg            equ 0x0000

section interrupts start=(ints_seg * 0x10) nobits
                    resw 2 * 3
vector_int3:        resw 2
vector_int4:        resw 2
                    resw 2 * 16
vector_int21:       resw 2
                    resw 2 * 233
vector_int255:      resw 2


saved_ints_seg      equ 0x1000

section saved_interrupts start=(saved_ints_seg * 0x10) nobits
saved_int3:         resw 2
saved_int4:         resw 2
saved_int21:        resw 2
saved_int255:       resw 2


section .text
    ; TODO HW should we call STI here to allow interrupts?

    mov ax, ints_seg
    mov ds, ax
    mov ax, saved_ints_seg
    mov es, ax

    ; save the interrupt handlers we are going to overwrite,
    ; otherwise power_off will just freeze on bochs
    mov ax, word [vector_int3   + 0]
    mov word [es:saved_int3   + 0], ax
    mov ax, word [vector_int3   + 2]
    mov word [es:saved_int3   + 2], ax
    mov ax, word [vector_int4   + 0]
    mov word [es:saved_int4   + 0], ax
    mov ax, word [vector_int4   + 2]
    mov word [es:saved_int4   + 2], ax
    mov ax, word [vector_int21  + 0]
    mov word [es:saved_int21  + 0], ax
    mov ax, word [vector_int21  + 2]
    mov word [es:saved_int21  + 2], ax
    mov ax, word [vector_int255 + 0]
    mov word [es:saved_int255 + 0], ax
    mov ax, word [vector_int255 + 2]
    mov word [es:saved_int255 + 2], ax

    ; set up interrupt handlers
    mov word [vector_int3   + 0], handle_int3
    mov word [vector_int3   + 2], text_seg
    mov word [vector_int4   + 0], handle_int4
    mov word [vector_int4   + 2], extra_seg
    mov word [vector_int21  + 0], handle_int21
    mov word [vector_int21  + 2], extra_seg
    mov word [vector_int255 + 0], handle_int255
    mov word [vector_int255 + 2], text_seg

    ; test interrupts
    int3
    dump_state

    int 21
    dump_state

    ; restore interrupt handlers
    mov ax, word [es:saved_int3   + 0]
    mov word [vector_int3   + 0], ax
    mov ax, word [es:saved_int3   + 2]
    mov word [vector_int3   + 2], ax
    mov ax, word [es:saved_int4   + 0]
    mov word [vector_int4   + 0], ax
    mov ax, word [es:saved_int4   + 2]
    mov word [vector_int4   + 2], ax
    mov ax, word [es:saved_int21  + 0]
    mov word [vector_int21  + 0], ax
    mov ax, word [es:saved_int21  + 2]
    mov word [vector_int21  + 2], ax
    mov ax, word [es:saved_int255 + 0]
    mov word [vector_int255 + 0], ax
    mov ax, word [es:saved_int255 + 2]
    mov word [vector_int255 + 2], ax

    call power_off

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


section int_handlers start=extra_addr

handle_int4:
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)

    ; test if interrupt clears TF and IF
    mov dx, 0b_00000011_00000000
    push dx
    popf
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)
    int 255
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)

    ; test restoring flags
    std
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)

    iret

handle_int21:
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)

    ; interrupt while processing an interrupt
    ; TODO HW should this work? test STI/CLI here?
    int 255
    ; TODO this does not work in bochs, it needs a far call
    dump_state
    ; TODO remove db  3 dup (0x90)

    iret
