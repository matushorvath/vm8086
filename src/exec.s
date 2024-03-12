.EXPORT execute
.EXPORT execute_nop
.EXPORT invalid_opcode

# From binary.s
.IMPORT binary

# From error.s
.IMPORT report_error

# From instructions.s
.IMPORT instructions

# From memory.s
.IMPORT read

# From state.s
.IMPORT reg_ip
.IMPORT inc_ip

# From trace.s
# TODO .IMPORT print_trace

##########
execute:
.FRAME tmp, op, exec_fn, args_fn
    arb -4

execute_loop:
# TODO tracing
#    # Skip tracing if disabled
#    jz  [binary + 3], execute_tracing_done
#
#    # If the [binary + 3] flag is positive, we use it as an address
#    # starting from where we should turn on tracing
#    eq  [binary + 3], [reg_ip], [rb + tmp]
#    jz  [rb + tmp], execute_tracing_different_address
#
#    # Address match, turn on tracing
#    add -1, 0, [binary + 3]
#
#execute_tracing_different_address:
#    # Print trace if enabled
#    eq  [binary + 3], -1, [rb + tmp]
#    jz  [rb + tmp], execute_tracing_done
#
#    call print_trace
#
#execute_tracing_done:
#    # Call the callback if enabled
#    jz  [binary + 4], execute_callback_done
#
#    call [binary + 4]
#    jnz [rb - 2], execute_callback_done
#
#    # Callback returned 0, halt
#    jz  0, execute_hlt
#
#execute_callback_done:
    # Read op code
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + op]

    # Increase ip
    call inc_ip

    # Process hlt
    eq  [rb + op], 0xf4, [rb + tmp]
    jnz [rb + tmp], execute_hlt

    # Find exec and args functions for this instruction
    mul [rb + op], 2, [rb + tmp]                            # one record is 2 bytes long

    add instructions + 0, [rb + tmp], [ip + 1]              # exec function is at index 0 in the record
    add [0], 0, [rb + exec_fn]

    add instructions + 1, [rb + tmp], [ip + 1]              # args function is at index 1 in the record
    add [0], 0, [rb + args_fn]

    # If there is an args_fn, call it; then call exec_fn with the result as a parameter
    jz  [rb + args_fn], execute_no_args_fn

    call [rb + args_fn]
    add [rb - 2], 0, [rb - 1]
    arb -1
    call [rb + exec_fn + 1]     # +1 to compensate for arb -1

    jz  0, execute_loop

execute_no_args_fn:
    # No args_fn, just call exec_fn with no parameters
    call [rb + exec_fn]

    jz  0, execute_loop

execute_hlt:
    arb 4
    ret 0
.ENDFRAME

##########
execute_nop:
.FRAME
    ret 0
.ENDFRAME

##########
invalid_opcode:
.FRAME
    arb -0

    add invalid_opcode_message, 0, [rb - 1]
    arb -1
    call report_error

invalid_opcode_message:
    db  "invalid opcode", 0
.ENDFRAME

.EOF
