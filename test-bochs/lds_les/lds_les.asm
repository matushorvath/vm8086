%include "common.inc"


section data_segment start=0x10000 nobits
    resw 29
test_ds_8:
    resw 263
test_ds_16:
    resw 2


section .text
    dump_state

    ; set up segments
    mov di, 0x1000
    mov ds, di

    ; set up data
    mov word [test_ds_8 + 0], 0x1234
    mov word [test_ds_8 + 2], 0x5678
    mov word [test_ds_16 + 0], 0xfedc
    mov word [test_ds_16 + 2], 0xba98

    mark 0x80

    lds ax, [test_ds_8]
    mov cx, ds
    mov ds, di

    lds bx, [test_ds_16]
    mov dx, ds
    mov ds, di

    dump_state

    mark 0x81

    les ax, [test_ds_8]
    mov cx, es

    les bx, [test_ds_16]
    mov dx, es

    dump_state

    call power_off
