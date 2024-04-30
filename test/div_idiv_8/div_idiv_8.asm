%include "common.inc"


ints_seg            equ 0x0000

section interrupts start=(ints_seg * 0x10) nobits
vector_int0:        resw 2


rw_data_seg         equ 0x1000

section data_segment start=(rw_data_seg * 0x10) nobits
saved_int0:         resw 2
    resw 27
test_ds_8:
    resw 263
test_ds_16:
    resw 1


section .text
    dump_state

    ; set up segments
    mov ax, ints_seg
    mov es, ax
    mov ax, rw_data_seg
    mov ds, ax

    ; set up interrupt vector for #DE
    mov ax, word [es:vector_int0 + 0]
    mov word [saved_int0 + 0], ax
    mov ax, word [es:vector_int0 + 2]
    mov word [saved_int0 + 2], ax

    mov word [es:vector_int0 + 0], handle_int0
    mov word [es:vector_int0 + 2], text_seg

%include "div_idiv_8_modes.inc"
%include "div_idiv_8_numbers.inc"

    ; restore interrupt handler
    mov ax, word [saved_int0 + 0]
    mov word [es:vector_int0 + 0], ax

    call power_off

handle_int0:
    push ax
    push bp

    mov bp, sp

    ; assume a 2-byte DIV instruction, increase IP on stack to point to the next instruction
    mov ax, word [bp + 4]
    add ax, 2
    mov word [bp + 4], ax

    ; set carry flag on stack to mark that INT 0 has occurred
    mov ax, word [bp + 8]
    or  ax, 0b_00000000_00000001
    mov word [bp + 8], ax

    pop bp
    pop ax

    iret

; TODO check interrupt behavior with IF = 0/1
