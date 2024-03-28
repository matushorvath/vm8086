; TODO CALL NEAR, CALL FAR, RET NEAR IMMED16, RET NEAR 0, RET FAR IMMED16, RET FAR 0 (all immediate)
; TODO CALL NEAR REG16/MEM16, CALL FAR MEM16

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

    hlt
