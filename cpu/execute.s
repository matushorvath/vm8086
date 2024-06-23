.EXPORT execute
.EXPORT execute_nop
.EXPORT execute_esc
.EXPORT execute_hlt
.EXPORT invalid_opcode
.EXPORT halt
.EXPORT exec_ip

# From the config file
.IMPORT config_enable_tracing
.IMPORT config_tracing_cs
.IMPORT config_tracing_ip
.IMPORT config_vm_callback

# From util/error.s
.IMPORT report_error

# From instructions.s
.IMPORT instructions

# From memory.s
.IMPORT read_cs_ip_b

# From prefix.s
.IMPORT prefix_valid
.IMPORT ds_segment_prefix
.IMPORT ss_segment_prefix
.IMPORT rep_prefix

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT reg_ds
.IMPORT reg_ss
.IMPORT inc_ip_b

# From trace.s
.IMPORT print_trace

# TODO handling of IRQs:
#
# Repeat, LOCK and segment override prefixes are considered "part of" the instructions they prefix;
# no interrupt is recognized between execution of a prefix and an instruction.
#
# A MOV (move) to segment register instruction and a POP segment register instruction are treated similarly:
# no interrupt is recognized until after the following instruction.
#
# repeated string instructions, where an interrupt request is recognized in the middle of an instruction

##########
execute:
.FRAME tmp, op, tracing_triggered
    arb -3

    # If there is no trigger address, tracing is always triggered
    add 0, 0, [rb + tracing_triggered]
    jnz [config_tracing_cs], execute_loop
    jnz [config_tracing_ip], execute_loop
    add 1, 0, [rb + tracing_triggered]

execute_loop:
    # Skip tracing if disabled
    jz  [config_enable_tracing], execute_tracing_done

    # If tracing was already triggered, jump directly to it
    jnz [rb + tracing_triggered], execute_tracing_triggered

    # Check if we have reached the trigger address
    mul [reg_ip + 1], 0x100, [rb + tmp]
    add [reg_ip + 0], [rb + tmp], [rb + tmp]
    eq  [config_tracing_ip], [rb + tmp], [rb + tmp]
    jz  [rb + tmp], execute_tracing_done

    mul [reg_cs + 1], 0x100, [rb + tmp]
    add [reg_cs + 0], [rb + tmp], [rb + tmp]
    eq  [config_tracing_cs], [rb + tmp], [rb + tmp]
    jz  [rb + tmp], execute_tracing_done

    # Trigger address match
    add 1, 0, [rb + tracing_triggered]

execute_tracing_triggered:
    call print_trace

execute_tracing_done:
    # Handle prefixes; first check if they were consumed (prefix_valid == 0)
    jz  [prefix_valid], execute_prefix_done

    # Decrease prefix lifetime
    add [prefix_valid], -1, [prefix_valid]

    # If prefix_valid == 0, we have just used the prefixes, reset them to defaults
    jnz [prefix_valid], execute_prefix_done

    add reg_ds, 0, [ds_segment_prefix]
    add reg_ss, 0, [ss_segment_prefix]
    add 0, 0, [rep_prefix]

execute_prefix_done:
    # Call the callback if enabled
    jz  [config_vm_callback], execute_callback_done

    call [config_vm_callback]
    jnz [rb - 2], execute_callback_done

    # Callback returned 0, stop the VM
    jz  0, execute_done

execute_callback_done:
    add [reg_ip + 0], 0, [exec_ip + 0]
    add [reg_ip + 1], 0, [exec_ip + 1]

    # Read op code
    call read_cs_ip_b
    add [rb - 2], 0, [rb + op]

    # Increment ip
    call inc_ip_b

    # Find information about this instruction
    mul [rb + op], 3, [rb + tmp]                            # one record is 3 bytes long

    add instructions + 0, [rb + tmp], [ip + 1]              # exec function is at index 0 in the record
    add [0], 0, [execute_exec_fn]

    add instructions + 1, [rb + tmp], [ip + 1]              # args function is at index 1 in the record
    add [0], 0, [execute_args_fn]

    # If there is an args_fn, call it; then call exec_fn
    jz  [execute_args_fn], execute_no_args_fn

    add instructions + 2, [rb + tmp], [ip + 1]              # args count is at index 2 in the record
    mul [0], -1, [execute_args_count]

    # Each args_fn passes a different number of arguments to the exec_fn. We can avoid having to copy them
    # all on the stack, because the return values from args_fn happen to land just one stack position below
    # where exec_fn expects its arguments. So we can just adjust rb by 1, call exec_fn and then adjust it back.
    # Of course we also need to adjust rb to match the number of exec_fn parameters, so we still need
    # to know how many there are, which is the args_count number from the instructions table.

    call [execute_args_fn]

    # Warning: Messed up stack below this line
    arb [execute_args_count]            # execute_args_count is already negative, see the "mul [0], -1" above
    arb -1                              # adjust rb as explained above

    # Another issue here is that we need to read the exec_fn pointer after doing an arb -(args_count - 1).
    # If exec_fn is on stack, we would have to compensate for the changed rb pointer when calling exec_fn.
    # It is possible to do, but since this function isn't reentrant, we instead use global variables to store
    # args_fn, exec_fn and args_count. Those don't depend on rb, so we can easily access them with messed up stack.

    call [execute_exec_fn]
    arb 1                               # undo the adjustment explained above, stack is now safe to use

    jz  [halt], execute_loop
    jz  0, execute_done

execute_no_args_fn:
    # No args_fn, just call exec_fn with no parameters
    call [execute_exec_fn]

    jz  [halt], execute_loop

execute_done:
    arb 3
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
execute_esc:
.FRAME op, lseg, loff;
    # The only thing to do here is to increase IP according to the MOD and R/M
    # fields, which was already done by arg_mod_op_rm_b/arg_mod_op_rm_w.
    ret 3
.ENDFRAME

##########
execute_hlt:
.FRAME
    # This is a nop for now
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
halt:                                   # set this to non-zero to halt the VM
    db  0
exec_ip:                                # IP where the currently executed instruction started
    db  0
    db  0

.EOF
