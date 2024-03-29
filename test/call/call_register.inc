    ; test CALL REG16 (NEAR)

    dump_state                        ; 1n
    mov dx, near_forward_reg
    call dx

    dump_state                        ; 5n
    jmp test_end_reg

near_backward_reg:
    dump_state                        ; 3n
    retn 2

near_forward_reg:
    dump_state                        ; 2n
    push ax
    mov dx, near_backward_reg
    call dx
    dump_state                        ; 4n
    retn

test_end_reg:
