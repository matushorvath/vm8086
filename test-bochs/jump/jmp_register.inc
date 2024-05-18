; TODO negative pointer
; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test JMP REG16 (NEAR)

    ; if we execute anything we shouldn't, ax will be set to 0
    mov ax, 1
    dump_state


test_near_reg:
    mov dx, near_forward_reg            ; 1n
    jmp dx
    mov ax, 0

near_backward_reg:
    dump_state                          ; 3n
    mov dx, test_end_reg
    jmp dx
    mov ax, 0

    ; make sure the distance requires a NEAR jump
    db  256 dup 0

near_forward_reg:
    dump_state                          ; 2n
    mov dx, near_backward_reg
    jmp dx
    mov ax, 0

test_end_reg:
    dump_state                          ; 4f
