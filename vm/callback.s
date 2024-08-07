.EXPORT vm_callback
.EXPORT on_disk_active
.EXPORT on_speaker_active

# From dev/pit_8253_ch0.s
.IMPORT pit_vm_callback_ch0

# From dev/pit_8253_ch2.s
.IMPORT pit_vm_callback_ch2

# From cga/status_bar.s
.IMPORT set_disk_active
.IMPORT set_disk_inactive
.IMPORT set_speaker_active
.IMPORT set_speaker_inactive

##########
vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    # Run the timer every 64 instructions
    jnz [vm_callback_counter], .decrement
    add 64, 0, [vm_callback_counter]

    # Trigger PIT channels
    call pit_vm_callback_ch0
    call pit_vm_callback_ch2

    # Hide the disk activity icon after 256 timer counters
    jz  [disk_inactive_counter], .after_disk

    add [disk_inactive_counter], -1, [disk_inactive_counter]
    jnz [disk_inactive_counter], .after_disk

    call set_disk_inactive

.after_disk:
    # Hide the speaker activity icon after 256 timer counters
    jz  [speaker_inactive_counter], .after_speaker

    add [speaker_inactive_counter], -1, [speaker_inactive_counter]
    jnz [speaker_inactive_counter], .after_speaker

    call set_speaker_inactive

.after_speaker:
.decrement:
    add [vm_callback_counter], -1, [vm_callback_counter]

    arb 1
    ret 0
.ENDFRAME

##########
on_disk_active:
.FRAME unit;
    # Display the disk icon
    call set_disk_active

    # Restart the timer
    add 255, 0, [disk_inactive_counter]

    ret 1
.ENDFRAME

##########
on_speaker_active:
.FRAME
    # Display the speaker icon
    call set_speaker_active

    # Restart the timer
    add 255, 0, [speaker_inactive_counter]

    ret 0
.ENDFRAME

##########
vm_callback_counter:
    db  0

disk_inactive_counter:
    db  0

speaker_inactive_counter:
    db  0

.EOF
