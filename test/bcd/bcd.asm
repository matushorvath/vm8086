%include "common.inc"

section .text
    dump_state

    mov ax, 0

%include "aaa_aas.inc"
%include "daa_das.inc"
%include "aam.inc"

; TODO test AAD

    call power_off
