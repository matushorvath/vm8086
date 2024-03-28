%include "common.inc"


section .data start=0xe0000
    dw  13 dup (0)
data:
    dw  0


section .text
    out 0x42, al

%include "reg.inc"
%include "mem.inc"

    ; the sr.inc test messes up segments
%include "sr.inc"

    hlt
