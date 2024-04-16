%include "common.inc"

bss_seg     equ 0x8000

section .bss start=(bss_seg * 0x10)
    resw 13
data:
    resw 1


section .text
    dump_state

    mark 0x80
%include "reg.inc"
    mark 0x81
%include "mem.inc"

    mark 0x82
%include "overflow.inc"

    ; the sr.inc test messes up segments
    mark 0x83
%include "sr.inc"

    call power_off
