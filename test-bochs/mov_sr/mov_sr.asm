%include "common.inc"


bss_seg     equ 0x8000

section .bss start=(bss_seg * 0x10) nobits

test_data:
    resw  0


section .text
    dump_state

    ; MOV sr, [16-bit displacement]
    mov ds, [cs:data_segment]

    dump_state

    mov [test_data], ds
    mov es, [test_data]

    dump_state

    mov [test_data], es
    mov ss, [test_data]
    mov es, ax                          ; zero es to check the mov es, [] below 

    dump_state

    mov [test_data], ss
    mov es, [test_data]

    dump_state

    ; TODO proper tests once we are able to fill registers with immediate

    ; MOV sr, [registers]
    mov es, [bx + si]
    mov es, [bx + di]
    mov es, [bp + si]
    mov es, [bp + di]
    mov es, [si]
    mov es, [di]
    mov es, [bp]
    mov es, [bx]

    ; MOV [registers], sr
    mov [bx + si], es
    mov [bx + di], es
    mov [bp + si], es
    mov [bp + di], es
    mov [si], es
    mov [di], es
    mov [bp], es
    mov [bx], es

    dump_state

    ; TODO MOV sr, MEM16 with 8-bit displacement, both directions
    ; TODO MOV sr, MEM16 with 16-bit displacement], both directions
    ; TODO MOV sr, reg, both directions
    ; TODO test setting cs (as the last test probably)

    call power_off

data_segment:
    ; we load this into ds at the beginning of the test
    dw  bss_seg
