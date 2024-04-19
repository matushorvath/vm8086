%include "common.inc"

section .text
    dump_state

    mov ax, 0

%include "aaa_aas.inc"
;TODO %include "daa_das.inc"

    call power_off
