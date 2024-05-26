.EXPORT bochs_shutdown
.EXPORT bochs_out_char

# From execute.s
.IMPORT halt

# From state.s
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

    add bochs_shutdown_string, [bochs_shutdown_state], [ip + 1]
    eq  [0], [rb + value], [rb + tmp]
    jnz [rb + tmp], bochs_shutdown_advance_state

    # Wrong character, reset the state
    add 0, 0, [bochs_shutdown_state]
    jz  0, bochs_shutdown_done

bochs_shutdown_advance_state:
    add [bochs_shutdown_state], 1, [bochs_shutdown_state]

    # If we are not at the end of the string, return
    add bochs_shutdown_string, [bochs_shutdown_state], [ip + 1]
    jnz [0], bochs_shutdown_done

    # Halt the VM
    add 1, 0, [halt]

bochs_shutdown_done:
    arb 1
    ret 2

bochs_shutdown_state:
    db  0
bochs_shutdown_string:
    db  "Shutdown", 0
.ENDFRAME

.EOF
