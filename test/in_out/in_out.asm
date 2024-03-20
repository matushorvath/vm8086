cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


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


    db  execute_out_al_immediate_b, 0, 0                # 0xe6 OUT AL, IMMED8
    db  execute_out_ax_immediate_b, 0, 0                # 0xe7 OUT AX, IMMED8

    db  execute_out_al_dx, 0, 0                         # 0xee OUT AL, DX
    db  execute_out_ax_dx, 0, 0                         # 0xef OUT AX, DX