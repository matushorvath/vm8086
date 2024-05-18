.EXPORT main

# These symbols are required by exec.s
.EXPORT binary_enable_tracing
.EXPORT binary_vm_callback

# From exec.s
.IMPORT execute

# From init_test.s
.IMPORT init_processor_test

# From prefix.s
.IMPORT prefix_valid

# From print_output.s
.IMPORT print_output

##########
# Entry point
    arb stack

    # Overwrite the first instruction with 'hlt', so in case
    # we ever jump to 0 by mistake, we halt immediately
    add 99, 0, [0]

    call main
    hlt

##########
main:
.FRAME
    call init_processor_test
    call execute
    call print_output

    ret 0
.ENDFRAME

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

##########
# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
binary_enable_tracing:
    db  0

# Optional callback function to call before each instruction, zero if not used
binary_vm_callback:
    db  vm_callback

##########
    ds  50, 0
stack:

.EOF
