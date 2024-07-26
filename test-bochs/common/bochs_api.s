.EXPORT bochs_shutdown
.EXPORT bochs_out_char

# From cpu/execute.s
.IMPORT halt

# From cpu/state.s
.IMPORT reg_al

##########
bochs_out_char:
.FRAME port, value;
    out [reg_al]
    ret 2
.ENDFRAME

##########
bochs_shutdown:
.FRAME port, value; tmp
    arb -1

    add .string, [.state], [ip + 1]
    eq  [0], [rb + value], [rb + tmp]
    jnz [rb + tmp], .advance_state

    # Wrong character, reset the state
    add 0, 0, [.state]
    jz  0, .done

.advance_state:
    add [.state], 1, [.state]

    # If we are not at the end of the string, return
    add .string, [.state], [ip + 1]
    jnz [0], .done

    # Halt the VM
    add 1, 0, [halt]

.done:
    arb 1
    ret 2

.state:
    db  0
.string:
    db  "Shutdown", 0
.ENDFRAME

.EOF
