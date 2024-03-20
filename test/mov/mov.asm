cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al


    db  execute_mov_b, arg_mod_reg_rm_src_b, 4          # 0x88 MOV REG8/MEM8, REG8
    db  execute_mov_w, arg_mod_reg_rm_src_w, 4          # 0x89 MOV REG16/MEM16, REG16
    db  execute_mov_b, arg_mod_reg_rm_dst_b, 4          # 0x8a MOV REG8, REG8/MEM8
    db  execute_mov_w, arg_mod_reg_rm_dst_w, 4          # 0x8b MOV REG16, REG16/MEM16


    ; push and pop each register
    inc ax
    push ax
    push ax

    pop bx
    inc bx
    push bx
    push bx

    pop cx
    inc cx
    push cx
    push cx

    pop dx
    inc dx
    push dx
    push dx

    pop si
    inc si
    push si
    push si

    pop di
    inc di
    push di
    push di

    pop ax

    out 0x42, al

    ; push segment registers, TODO modify them first once we are able
    push cs
    push ds
    push ss
    push es

    out 0x42, al

    ; pop segment registers intentionally in different order, ss last
    pop ds
    pop es
    pop ss

    out 0x42, al

    ; everything is messed up, our work here is done
    hlt

section boot start=0xffff0              ; boot
    int3
