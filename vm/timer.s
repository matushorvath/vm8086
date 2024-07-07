.EXPORT vm_callback

# From dev/pit_8253_ch0.s
.IMPORT pit_vm_callback_ch0

# From dev/pit_8253_ch2.s
.IMPORT pit_vm_callback_ch2

# From cga/status_bar.s
.IMPORT set_disk_inactive

##########
vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    # Run the timer every 64 instructions
    jnz [vm_callback_counter], vm_callback_decrement
    add 64, 0, [vm_callback_counter]

    # Trigger PIT channels
    call pit_vm_callback_ch0
    call pit_vm_callback_ch2

    # Reset disk activity every 256 timer counters
    jnz [disk_inactive_counter], disk_inactive_decrement
    add 256, 0, [disk_inactive_counter]

    # Remove the disk activity icon
    call set_disk_inactive

disk_inactive_decrement:
    add [disk_inactive_counter], -1, [disk_inactive_counter]

vm_callback_decrement:
    add [vm_callback_counter], -1, [vm_callback_counter]

    arb 1
    ret 0
.ENDFRAME

##########
vm_callback_counter:
    db  0
disk_inactive_counter:
    db  0

.EOF
