%include "common.inc"


section .text
    mark 0x80
%include "conditional.inc"

    mark 0x81
%include "loop.inc"

    mark 0x82
%include "jmp_direct.inc"

    mark 0x83
%include "jmp_register.inc"

    mark 0x84
%include "jmp_memory.inc"

    call power_off
