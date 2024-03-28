; TODO negative pointer
; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

%include "common.inc"


section .text
    out 0x80, al

%include "call_direct.inc"

    out 0x81, al
%include "call_register.inc"

    out 0x82, al
%include "call_memory.inc"

    hlt
