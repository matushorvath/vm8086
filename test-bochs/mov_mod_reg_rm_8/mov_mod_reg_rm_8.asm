; TODO force NASM to generate also the other variants for MOV REG8/REG8, REG8/REG16 (src/dst)
; TODO x test sign-extended 8-bit displacement
; TODO x test wrap around (register near 0xfffff + displacement, also negative displacement, also around 0x7f)

%include "common.inc"


section data_segment start=0x10000 nobits
    resw 23
test_ds_8:
    resw 263
test_ds_16:
    resw 1


section stack_segment start=0x20000 nobits
    resw 17
test_ss_8:
    resw 313
test_ss_16:
    resw 1


section .text
    dump_state

    ; set up for testing MOD R/M
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    mov bx, 5
    mov bp, 7
    mov si, 11
    mov di, 13

%include "mem_reg_16.inc"
    mark 0x80
%include "reg_mem_16.inc"
    mark 0x81
%include "mem_reg_8.inc"
    mark 0x82
%include "reg_mem_8.inc"
    mark 0x83
%include "mem_reg_0.inc"
    mark 0x84
%include "reg_mem_0.inc"
    mark 0x85

    call power_off
