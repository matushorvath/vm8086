    ; test CALL REG16 (NEAR)

    out 0x42, al                        ; 1n
    mov dx, near_forward_reg
    call dx

    out 0x42, al                        ; 5n
    jmp test_end_reg

near_backward_reg:
    out 0x42, al                        ; 3n
    retn 2

near_forward_reg:
    out 0x42, al                        ; 2n
    push ax
    mov dx, near_backward_reg
    call dx
    out 0x42, al                        ; 4n
    retn

test_end_reg:
