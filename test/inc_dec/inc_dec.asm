cpu 8086

section interrupts start=0x00000
    dw  0x0000,         0x0000
    dw  0x0000,         0x0000
    dw  0x0000,         0x0000
    dw  handle_int3,    0x8000          ; INT 3

section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; push and pop each register
    inc ax
    push ax
    push ax
    pop ax


    out 0x42, al

    ; everything is messed up, our work here is done
    hlt

section boot start=0xffff0              ; boot
    int3



    db  execute_inc_w, arg_ax, 2                        # 0x40 INC AX
    db  execute_inc_w, arg_cx, 2                        # 0x41 INC CX
    db  execute_inc_w, arg_dx, 2                        # 0x42 INC DX
    db  execute_inc_w, arg_bx, 2                        # 0x43 INC BX
    db  execute_inc_w, arg_sp, 2                        # 0x44 INC SP
    db  execute_inc_w, arg_bp, 2                        # 0x45 INC BP
    db  execute_inc_w, arg_si, 2                        # 0x46 INC SI
    db  execute_inc_w, arg_di, 2                        # 0x47 INC DI

    db  execute_dec_w, arg_ax, 2                        # 0x48 DEC AX
    db  execute_dec_w, arg_cx, 2                        # 0x49 DEC CX
    db  execute_dec_w, arg_dx, 2                        # 0x4a DEC DX
    db  execute_dec_w, arg_bx, 2                        # 0x4b DEC BX
    db  execute_dec_w, arg_sp, 2                        # 0x4c DEC SP
    db  execute_dec_w, arg_bp, 2                        # 0x4d DEC BP
    db  execute_dec_w, arg_si, 2                        # 0x4e DEC SI
    db  execute_dec_w, arg_di, 2                        # 0x4f DEC DI