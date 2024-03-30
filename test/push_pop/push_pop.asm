%include "common.inc"

bss_seg     equ 0x8000

section .bss start=(bss_seg * 0x10)
    resw 13
data:
    resw 1


section .text
    dump_state

%include "reg.inc"
%include "mem.inc"

    ; the sr.inc test messes up segments
%include "sr.inc"

    call power_off
