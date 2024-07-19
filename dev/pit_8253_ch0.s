# This file needs to include pit_8253_common.si

# From pic_8259a_execute.s
.IMPORT interrupt_request

# Re-export some symbols under new names
.EXPORT pit_data_read_ch0
.EXPORT pit_data_write_ch0
.EXPORT pit_mode_command_write_ch0
.EXPORT pit_vm_callback_ch0

##########
# Action to perform when the channel triggers
pit_trigger:
.FRAME
    # Trigger IRQ0
    add 0, 0, [rb - 1]
    arb -1
    call interrupt_request

    ret 0
.ENDFRAME

##########
pit_data_read_ch0:
    jz  0, pit_data_read_common

pit_data_write_ch0:
    jz  0, pit_data_write_common

pit_mode_command_write_ch0:
    jz  0, pit_mode_command_write_common

pit_vm_callback_ch0:
    jz  0, pit_vm_callback_common

# Configuration
pit_channel:
    db  0

# Dummy gate that is always on
pit_gate:
    db  1

pit_output:
    db  0

.EOF
