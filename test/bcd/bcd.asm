%include "common.inc"

section .text
    dump_state

    mov ax, 0

%include "aaa_aas.inc"
%include "daa_das.inc"

; TODO test AAM, AAD

    call power_off
