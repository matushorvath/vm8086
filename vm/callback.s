.EXPORT init_vm_callback
.EXPORT vm_callback

# From main.s
.IMPORT extended_vm

# From cga/status_bar.s
.IMPORT set_disk_active
.IMPORT set_disk_inactive
.IMPORT set_speaker_active
.IMPORT set_speaker_inactive

# From cpu/execute.s
.IMPORT execute_callback

# From dev/keyboard.s
.IMPORT handle_keyboard

# From dev/pit_8253_ch0.s
.IMPORT pit_vm_callback_ch0

# From dev/pit_8253_ch2.s
.IMPORT pit_vm_callback_ch2

# From dev/ppi_8255a.s
.IMPORT ppi_a
.IMPORT speaker_activity_callback

# From fdc/commands.s
.IMPORT fdc_activity_callback

##########
init_vm_callback:
.FRAME
    # Set up callbacks
    add vm_callback, 0, [execute_callback]
    add on_disk_active, 0, [fdc_activity_callback]
    add on_speaker_active, 0, [speaker_activity_callback]

    ret 0
.ENDFRAME

##########
vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    # High frequency tasks, every 64 instructions
    jnz [vm_callback_hf_counter], .decrement_hf
    add 64, 0, [vm_callback_hf_counter]

    # Trigger PIT channels
    call pit_vm_callback_ch0
    call pit_vm_callback_ch2

    # Low frequerncy tasks, every 64 * 256 instructions
    jz  [extended_vm], .decrement_lf                        # optimization, since keyboard is the only low frequency task

    jnz [vm_callback_lf_counter], .decrement_lf
    add 256, 0, [vm_callback_lf_counter]

    # Handle keyboard input, if running on an extended VM
    jnz [ppi_a], .decrement_lf                              # optimization, avoid the function call until BIOS reads the previous scan code
    call handle_keyboard

.decrement_lf:
    add [vm_callback_lf_counter], -1, [vm_callback_lf_counter]

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
.decrement_hf:
    add [vm_callback_hf_counter], -1, [vm_callback_hf_counter]

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
vm_callback_hf_counter:
    db  0
vm_callback_lf_counter:
    db  0

disk_inactive_counter:
    db  0

speaker_inactive_counter:
    db  0

.EOF
