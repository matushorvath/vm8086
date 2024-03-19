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

    db  execute_cmc, 0, 0                               # 0xf5 CMC

        db  execute_clc, 0, 0                               # 0xf8 CLC
    db  execute_stc, 0, 0                               # 0xf9 STC
    db  execute_cli, 0, 0                               # 0xfa CLI
    db  execute_sti, 0, 0                               # 0xfb STI
    db  execute_cld, 0, 0                               # 0xfc CLD
    db  execute_std, 0, 0                               # 0xfd STD

    + after implemented, 

        db  not_implemented, 0, 0 # TODO    db  execute_pushf, 0                                # 0x9c PUSHF
    db  not_implemented, 0, 0 # TODO    db  execute_popf, 0                                 # 0x9d POPF
    