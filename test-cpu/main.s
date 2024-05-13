.EXPORT main

# These symbols are required by exec.s
.EXPORT binary_enable_tracing
.EXPORT binary_vm_callback

# From exec.s
.IMPORT execute

# From init_test.s
.IMPORT init_processor_test

# From memory.s
.IMPORT read_cs_ip_b

# From print_output.s
.IMPORT print_output

# TODO if we check 3 NOPs, IP is 2 larger than expected
# TODO flags are differnt, because we don't set top 4 bytes to 1 (ignore top half-byte of flags)

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
.FRAME tmp                              # returns tmp
    arb -1

    # Stop the VM if we encounter three NOP instructions in sequence

    # Is next instruction a NOP?
    call read_cs_ip_b
    eq  [rb - 2], 0x90, [rb + tmp]
    jz  [rb + tmp], vm_callback_continue

    # Yes, this is a NOP, increase NOP count
    add [vm_callback_nop_count], 1, [vm_callback_nop_count]

    # Did we see enough NOPs in row?
    # TODO should be 3 NOPs in a row, but them IP is wrong (too large by 2)
    lt  [vm_callback_nop_count], 1, [rb + tmp]
    jnz [rb + tmp], vm_callback_continue

    add 0, 0, [rb + tmp]
    jz  0, vm_callback_done

vm_callback_not_nop:
    # Next instruction is not a NOP, reset NOP counts
    add 0, 0, [vm_callback_nop_count]

    # fall through

vm_callback_continue:
    # We want to continue, return 1
    add 1, 0, [rb + tmp]

vm_callback_done:
    arb 1
    ret 0

vm_callback_nop_count:
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
