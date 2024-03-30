%include "common.inc"


bss_seg     equ 0x8000
section .bss start=(bss_seg * 0x10) nobits
data:
    resw 0


section .text
    dump_state

    mark 0x80
%include "reg_ax.inc"

    mark 0x81
%include "reg_reg_8.inc"
    mark 0x82
%include "reg_reg_16.inc"

    mark 0x83
%include "reg_mem_8.inc"
    mark 0x84
%include "reg_mem_16.inc"

    call power_off
