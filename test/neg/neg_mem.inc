; NEG with a memory operand

    mark 0x50

    mov byte [test_ds_8], 0x12
    neg byte [test_ds_8]
    mov al, byte [test_ds_8]
    pushf

    mov byte [test_ds_16], 0x34
    neg byte [test_ds_16]
    mov ah, byte [test_ds_16]
    pushf

    mov di, test_ds_16
    mov byte [di], 0x56
    neg byte [di]
    mov bl, byte [di]
    pushf

    dump_state

    mov word [test_ds_8], 0xfedc
    neg word [test_ds_8]
    mov ax, word [test_ds_8]
    pushf

    mov word [test_ds_16], 0xba98
    neg word [test_ds_16]
    mov bx, word [test_ds_16]
    pushf

    mov di, test_ds_16
    mov word [di], 0x7654
    neg word [di]
    mov cx, word [di]
    pushf

    dump_state
