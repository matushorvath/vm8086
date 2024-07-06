.EXPORT vm_callback

# From dev/pit_8253_ch0.s
.IMPORT pit_vm_callback_ch0

# From dev/pit_8253_ch2.s
.IMPORT pit_vm_callback_ch2

##########
vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    # Run the timer every 64 instructions
    jnz [vm_callback_counter], pit_vm_callback_decrement
    add 64, 0, [vm_callback_counter]

    call pit_vm_callback_ch0
    call pit_vm_callback_ch2

pit_vm_callback_decrement:
    add [vm_callback_counter], -1, [vm_callback_counter]

    arb 1
    ret 0
.ENDFRAME

##########
vm_callback_counter:
    db  0

.EOF
