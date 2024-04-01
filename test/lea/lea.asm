%include "common.inc"


section data_segment start=0x10000 nobits
    resw 29
test_ds_8:
    resw 263
test_ds_16:
    resw 1


section stack_segment start=0x20000 nobits
    resw 13
test_ss_8:
    resw 313
test_ss_16:
    resw 1


section .text
    dump_state

    ; set up segments
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    mov bx, 3
    mov bp, 7
    mov si, 17
    mov di, 4077

    mark 0x80

    lea ax, [bx + si]
    lea cx, [bx + di]
    lea dx, [di]

    dump_state

    lea ax, [bp + si]
    lea cx, [bp + di]
    lea dx, [bp]

    dump_state

    mark 0x81

    lea ax, [byte bx + si + test_ds_8]
    lea cx, [byte bx + di + test_ds_8]
    lea dx, [byte di + test_ds_8]

    dump_state

    lea ax, [byte bp + si + test_ss_8]
    lea cx, [byte bp + di + test_ss_8]
    lea dx, [byte bp + test_ss_8]

    dump_state

    mark 0x82

    lea ax, [word bx + si + test_ds_16]
    lea cx, [word bx + di + test_ds_16]
    lea dx, [word di + test_ds_16]

    dump_state

    lea ax, [word bp + si + test_ss_16]
    lea cx, [word bp + di + test_ss_16]
    lea dx, [word bp + test_ss_16]

    dump_state

    call power_off
