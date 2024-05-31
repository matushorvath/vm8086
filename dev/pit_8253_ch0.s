# This file needs to include pit_8253_common.si

# Re-export some symbols under new names
.EXPORT pit_data_read_ch0
.EXPORT pit_data_write_ch0
.EXPORT pit_mode_command_write_ch0
.EXPORT pit_vm_callback_ch0

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

pit_trigger_int0:
    db  1

.EOF
