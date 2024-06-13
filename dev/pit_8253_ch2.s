# This file needs to include pit_8253_common.si

# Re-export some symbols under new names
.EXPORT pit_data_read_ch2
.EXPORT pit_data_write_ch2
.EXPORT pit_mode_command_write_ch2
.EXPORT pit_vm_callback_ch2
.EXPORT pit_set_gate_ch2

.EXPORT pit_gate_ch2
.EXPORT pit_output_ch2

pit_data_read_ch2:
    jz  0, pit_data_read_common

pit_data_write_ch2:
    jz  0, pit_data_write_common

pit_mode_command_write_ch2:
    jz  0, pit_mode_command_write_common

pit_vm_callback_ch2:
    jz  0, pit_vm_callback_common

pit_set_gate_ch2:
    jz  0, pit_set_gate_common

# Configuration
pit_channel:
    db  2

pit_trigger_int0:
    db  0

# Gate status can be read using port 0x61 bit 0
pit_gate_ch2:
pit_gate:
    db  1

# Output can be read using port 0x62 bit 5
pit_output_ch2:
pit_output:
    db  0

.EOF