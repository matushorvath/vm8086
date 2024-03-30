%include "common.inc"


section .text
    out 0x80, al
%include "conditional.inc"

    out 0x81, al
%include "loop.inc"

    out 0x82, al
%include "jmp_direct.inc"

    out 0x83, al
%include "jmp_register.inc"

    out 0x84, al
%include "jmp_memory.inc"

    call power_off
