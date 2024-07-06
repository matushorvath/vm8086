.EXPORT vm_callback

# From cpu/prefix.s
.IMPORT prefix_valid

##########
vm_callback:
.FRAME continue                         # returns continue
    arb -1

    # Stop the VM after executing one instruction (not counting any prefixes)

    # Default is to continue
    add 1, 0, [rb + continue]

    # Is this the first time this callback is called?
    jz  [vm_callback_was_called], vm_callback_first_call

    # No, do we have an active prefix? If a prefix was the last thing executed,
    # we are still waiting for the first instruction.
    jnz [prefix_valid], vm_callback_done

    # We already executed something and it wasn't a prefix,
    # we must have already executed an instruction
    add 0, 0, [rb + continue]
    jz  0, vm_callback_done

vm_callback_first_call:
    # This is the first time we are called, before executing anything
    add 1, 0, [vm_callback_was_called]

vm_callback_done:
    arb 1
    ret 0

vm_callback_was_called:
    db  0
.ENDFRAME

.EOF
