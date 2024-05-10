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

    dump_state
