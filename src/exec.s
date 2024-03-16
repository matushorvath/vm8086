.EXPORT execute
.EXPORT execute_nop
.EXPORT invalid_opcode
.EXPORT not_implemented             # TODO remove

# From the linked 8086 binary
.IMPORT binary_enable_tracing
.IMPORT binary_vm_callback

# From error.s
.IMPORT report_error

# From instructions.s
.IMPORT instructions

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip

# From trace.s
# TODO .IMPORT print_trace

##########
execute:
.FRAME tmp, op
    arb -2

execute_loop:
# TODO tracing
#    # Skip tracing if disabled
#    jz  [binary_enable_tracing], execute_tracing_done
#
#    # If the [binary_enable_tracing] flag is positive, we use it as an address
#    # starting from where we should turn on tracing
#    eq  [binary_enable_tracing], [reg_ipxxx], [rb + tmp]
#    jz  [rb + tmp], execute_tracing_different_address
#
#    # Address match, turn on tracing
#    add -1, 0, [binary_enable_tracing]
#
#execute_tracing_different_address:
#    # Print trace if enabled
#    eq  [binary_enable_tracing], -1, [rb + tmp]
#    jz  [rb + tmp], execute_tracing_done
#
#    call print_trace
#
#execute_tracing_done:
#    # Call the callback if enabled
#    jz  [binary_vm_callback], execute_callback_done
#
#    call [binary_vm_callback]
#    jnz [rb - 2], execute_callback_done
#
#    # Callback returned 0, halt
#    jz  0, execute_hlt
#
#execute_callback_done:
    # Read op code
    call read_cs_ip_b
    add [rb - 2], 0, [rb + op]

    # Increase ip
    call inc_ip

    # Process hlt
    eq  [rb + op], 0xf4, [rb + tmp]
    jnz [rb + tmp], execute_hlt

    # Find information about this instruction
    mul [rb + op], 3, [rb + tmp]                            # one record is 3 bytes long

    add instructions + 0, [rb + tmp], [ip + 1]              # exec function is at index 0 in the record
    add [0], 0, [execute_exec_fn]

    add instructions + 1, [rb + tmp], [ip + 1]              # args function is at index 1 in the record
    add [0], 0, [execute_args_fn]

    add instructions + 2, [rb + tmp], [ip + 1]              # args count is at index 2 in the record
    mul [0], -1, [execute_args_count]

    # If there is an args_fn, call it; then call exec_fn
    jz  [execute_args_fn], execute_no_args_fn

    # Each args_fn passes a different number of arguments to the exec_fn. We can avoid having to copy them
    # all on the stack, because the return values from args_fn happen to land just one stack position below
    # where exec_fn expects its arguments. So we can just adjust rb by 1, call exec_fn and then adjust it back.
    # Of course we also need to adjust rb to match the number of exec_fn parameters, so we still need
    # to know how many there are, which is the args_count number from the instructions table.

    call [execute_args_fn]

    # Warning: Messed up stack below this line
    arb [execute_args_count]            # execute_args_count is already negative, see the "mul [0], -1" above

    # Another issue here is that we need to read the exec_fn pointer after doing an arb -(args_count - 1).
    # If exec_fn is on stack, we would have to compensate for the changed rb pointer when calling exec_fn.
    # It is possible to do, but since this function isn't reentrant, we instead use global variables to store
    # args_fn, exec_fn and args_count. Those don't depend on rb, so we can easily access them with messed up stack.

    call [execute_exec_fn]
    arb -1                              # undo the adjustment explained above, stack is now safe to use

    jz  0, execute_loop

execute_no_args_fn:
    # No args_fn, just call exec_fn with no parameters
    call [execute_exec_fn]

    jz  0, execute_loop

execute_hlt:
    arb 2
    ret 0

execute_exec_fn:
    db  0
execute_args_fn:
    db  0
execute_args_count:
    db  0
.ENDFRAME

##########
execute_nop:
.FRAME
    ret 0
.ENDFRAME

##########
invalid_opcode:
.FRAME
    add invalid_opcode_message, 0, [rb - 1]
    arb -1
    call report_error

invalid_opcode_message:
    db  "invalid opcode", 0
.ENDFRAME

##########
not_implemented:            # TODO remove
.FRAME
    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

not_implemented_message:
    db  "opcode not implemented", 0
.ENDFRAME

.EOF
