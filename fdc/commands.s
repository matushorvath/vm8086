.EXPORT fdc_exec_read_data
.EXPORT fdc_exec_read_deleted_data
.EXPORT fdc_exec_write_data
.EXPORT fdc_exec_write_deleted_data

.EXPORT fdc_exec_read_track
.EXPORT fdc_exec_read_id
.EXPORT fdc_exec_format_track

.EXPORT fdc_exec_scan_equal
.EXPORT fdc_exec_scan_low_or_equal
.EXPORT fdc_exec_scan_high_or_equal

.EXPORT fdc_exec_recalibrate
.EXPORT fdc_exec_specify
.EXPORT fdc_exec_sense_drive_status
.EXPORT fdc_exec_seek

.EXPORT fdc_activity_callback

# From the config file
.IMPORT config_log_fdd

# From fdc_config.s
.IMPORT fdc_config_connected_units
.IMPORT fdc_config_inserted_units

# From fdc_control.s
.IMPORT fdc_dor_enable_motor_units
.IMPORT fdc_interrupt_pending

# From fdc_drives.s
.IMPORT fdc_medium_cylinders_units
.IMPORT fdc_medium_heads_units
.IMPORT fdc_medium_sectors_units
.IMPORT fdc_present_cylinder_units
.IMPORT fdc_present_sector_units

# From fdc_fsm.s
.IMPORT fdc_cmd_multi_track
.IMPORT fdc_cmd_unit_selected

.IMPORT fdc_cmd_cylinder
.IMPORT fdc_cmd_head
.IMPORT fdc_cmd_sector

.IMPORT fdc_cmd_end_of_track

.IMPORT fdc_cmd_hlt_nd

.IMPORT fdc_cmd_st0
.IMPORT fdc_cmd_st1
.IMPORT fdc_cmd_st2
.IMPORT fdc_cmd_st3

# From fdc_init.s
.IMPORT fdc_error_non_dma

# From dev/pic_8259a_execute.s
.IMPORT interrupt_request

# From cpu/error.s
.IMPORT report_error

# From cpu/images.s
.IMPORT floppy

# From dev/dma_8237a.s
.IMPORT dma_disable_controller
.IMPORT dma_mask_ch2
.IMPORT dma_transfer_type_ch2
.IMPORT dma_mode_ch2
.IMPORT dma_count_ch2
.IMPORT dma_receive_data
.IMPORT dma_send_data

# From util/bits.s
.IMPORT bit_0

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num

# TODO fdc_exec_read_data and fdc_exec_write_data have a lot of common code, unify

##########
fdc_exec_read_data:
.FRAME heads, sectors, dma_count, addr_c, addr_s, tmp
    arb -6

    add [dma_count_ch2], 0, [rb + dma_count]

    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Floppy is accessible, report disk activity
    jz  [fdc_activity_callback], .after_callback
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    arb -1
    call [fdc_activity_callback]

.after_callback:
    # Load floppy parameters
    add fdc_medium_heads_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + heads]
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + sectors]

    # Cylinder number must match the cylinder we are on
    eq  [fdc_cmd_cylinder], [fdc_present_cylinder_units], [rb + tmp]
    jz  [rb + tmp], .bad_input

    # Head number must be in range
    lt  [fdc_cmd_head], 0, [rb + tmp]
    jnz [rb + tmp], .bad_input
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jz  [rb + tmp], .bad_input

    # Sector number must be in range (1-based)
    lt  [fdc_cmd_sector], 1, [rb + tmp]
    jnz [rb + tmp], .bad_input
    lt  [rb + sectors], [fdc_cmd_sector], [rb + tmp]
    jnz [rb + tmp], .bad_input

    # Check the DMA controller
    jnz [dma_disable_controller], .no_dma
    jnz [dma_mask_ch2], .no_dma

    eq  [dma_transfer_type_ch2], 1, [rb + tmp]              # transfer type must be write (1)
    jz  [rb + tmp], .no_dma

    eq  [dma_mode_ch2], 1, [rb + tmp]                       # only single mode is supported (1)
    jz  [rb + tmp], .no_dma

    # DMA is set up, start reading at head H sector S up to end of the track/cylinder,
    # or until the DMA controller has enough data

    # Calculate cylinder address in intcode memory:
    # addr_c = floppy + cylinder * heads * sectors * 512
    mul [fdc_cmd_cylinder], [rb + heads], [rb + addr_c]
    mul [rb + addr_c], [rb + sectors], [rb + addr_c]
    mul [rb + addr_c], 512, [rb + addr_c]
    add [floppy], [rb + addr_c], [rb + addr_c]

.loop:
    # Does the DMA controller expect more data?
    eq  [dma_count_ch2], -1, [rb + tmp]
    jnz [rb + tmp], .all_data_read

    # Calculate sector address in intcode memory:
    # addr_s = addr_c + (head * sectors + sector - 1) * 512
    mul [fdc_cmd_head], [rb + sectors], [rb + addr_s]
    add [rb + addr_s], [fdc_cmd_sector], [rb + addr_s]
    add [rb + addr_s], -1, [rb + addr_s]
    mul [rb + addr_s], 512, [rb + addr_s]
    add [rb + addr_c], [rb + addr_s], [rb + addr_s]

    # Send one sector of data to DMA controller, channel 2
    # TODO if N=0, DTL defines how much of each sector should we send to DMA, not 512
    add 2, 0, [rb - 1]
    add [rb + addr_s], 0, [rb - 2]
    add 512, 0, [rb - 3]
    arb -3
    call dma_receive_data

    # Move to next sector
    add [fdc_cmd_sector], 1, [fdc_cmd_sector]

    # Did we reach end of track?
    lt  [rb + sectors], [fdc_cmd_sector], [rb + tmp]
    jz  [rb + tmp], .loop

    # End of track, move to sector 1
    add 1, 0, [fdc_cmd_sector]

    # Is this a multi-track operation?
    jnz [fdc_cmd_multi_track], .multi_track

    # Single track operation is finished, move to the same head on next cylinder
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]
    jz  0, .all_data_read

.multi_track:
    # Multi-track operation, move to next side
    add [fdc_cmd_head], 1, [fdc_cmd_head]

    # Does this side actually exist on the disk?
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jnz [rb + tmp], .loop

    # No, end of cylinder, move to head 0 on next cylinder
    add 0, 0, [fdc_cmd_head]
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]

.all_data_read:
    # The DMA controller does not want more data, or there is no more data available
    # Respond with ST0 (see above) ST1 ST2, and C H R N that was set up above
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .terminated

    add 0, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

    jz  0, .terminated

.no_dma:
    # Floppy is accessible, but the DMA controller is not ready to accept data
    # Set up ST0 (abnormal termination), ST1, ST2; keep head, cylinder or sector
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .terminated

    add 0, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

    jz  0, .terminated

.bad_input:
    # Floppy is accessible, but input parameters are invalid
    # Set up ST0 (abnormal termination), ST1 (end of cylinder, no data), ST2
    # TODO only set ST1 bit 7 when sector is wrong
    # TODO set up ST2 (bits 1, 4) when cylinder is wrong
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b10000100, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .bad_input_after_log

    add 0, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

.bad_input_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

    jz  0, .terminated

.no_floppy:
    # Floppy is not accessible
    # Set up ST0 (not ready, abnormal termination), ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .no_floppy_after_log

    add 0, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

.no_floppy_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

.terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

    arb 6
    ret 0
.ENDFRAME

##########
fdc_exec_read_deleted_data:
.FRAME
    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: read deleted data command is not supported", 0
.ENDFRAME

##########
fdc_exec_write_data:
.FRAME heads, sectors, dma_count, addr_c, addr_s, tmp
    arb -6

    add [dma_count_ch2], 0, [rb + dma_count]

    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Floppy is accessible, report disk activity
    jz  [fdc_activity_callback], .after_callback
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    arb -1
    call [fdc_activity_callback]

.after_callback:
    # Load floppy parameters
    add fdc_medium_heads_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + heads]
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + sectors]

    # Cylinder number must match the cylinder we are on
    eq  [fdc_cmd_cylinder], [fdc_present_cylinder_units], [rb + tmp]
    jz  [rb + tmp], .bad_input

    # Head number must be in range
    lt  [fdc_cmd_head], 0, [rb + tmp]
    jnz [rb + tmp], .bad_input
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jz  [rb + tmp], .bad_input

    # Sector number must be in range (1-based)
    lt  [fdc_cmd_sector], 1, [rb + tmp]
    jnz [rb + tmp], .bad_input
    lt  [rb + sectors], [fdc_cmd_sector], [rb + tmp]
    jnz [rb + tmp], .bad_input

    # Check the DMA controller
    jnz [dma_disable_controller], .no_dma
    jnz [dma_mask_ch2], .no_dma

    eq  [dma_transfer_type_ch2], 0, [rb + tmp]              # transfer type must be read (0)
    jz  [rb + tmp], .no_dma

    eq  [dma_mode_ch2], 1, [rb + tmp]                       # only single mode is supported (1)
    jz  [rb + tmp], .no_dma

    # DMA is set up, start writing at head H sector S up to end of the track/cylinder,
    # or until the DMA controller has no more data

    # Calculate cylinder address in intcode memory:
    # addr_c = floppy + cylinder * heads * sectors * 512
    mul [fdc_cmd_cylinder], [rb + heads], [rb + addr_c]
    mul [rb + addr_c], [rb + sectors], [rb + addr_c]
    mul [rb + addr_c], 512, [rb + addr_c]
    add [floppy], [rb + addr_c], [rb + addr_c]

.loop:
    # Does the DMA controller have more data?
    eq  [dma_count_ch2], -1, [rb + tmp]
    jnz [rb + tmp], .all_data_written

    # Calculate sector address in intcode memory:
    # addr_s = addr_c + (head * sectors + sector - 1) * 512
    mul [fdc_cmd_head], [rb + sectors], [rb + addr_s]
    add [rb + addr_s], [fdc_cmd_sector], [rb + addr_s]
    add [rb + addr_s], -1, [rb + addr_s]
    mul [rb + addr_s], 512, [rb + addr_s]
    add [rb + addr_c], [rb + addr_s], [rb + addr_s]

    # Receive one sector of data from DMA controller, channel 2
    # TODO if N=0, DTL defines how much of each sector should we receive from DMA, not 512
    add 2, 0, [rb - 1]
    add [rb + addr_s], 0, [rb - 2]
    add 512, 0, [rb - 3]
    arb -3
    call dma_send_data

    # Move to next sector
    add [fdc_cmd_sector], 1, [fdc_cmd_sector]

    # Did we reach end of track?
    lt  [rb + sectors], [fdc_cmd_sector], [rb + tmp]
    jz  [rb + tmp], .loop

    # End of track, move to sector 1
    add 1, 0, [fdc_cmd_sector]

    # Is this a multi-track operation?
    jnz [fdc_cmd_multi_track], .multi_track

    # Single track operation is finished, move to the same head on next cylinder
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]
    jz  0, .all_data_written

.multi_track:
    # Multi-track operation, move to next side
    add [fdc_cmd_head], 1, [fdc_cmd_head]

    # Does this side actually exist on the disk?
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jnz [rb + tmp], .loop

    # No, end of cylinder, move to head 0 on next cylinder
    add 0, 0, [fdc_cmd_head]
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]

.all_data_written:
    # The DMA controller does not have more data, or we have filled in all requested sectors
    # Respond with ST0 (see above) ST1 ST2, and C H R N that was set up above
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .terminated

    add 1, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

    jz  0, .terminated

.no_dma:
    # Floppy is accessible, but the DMA controller is not ready to accept data
    # Set up ST0 (abnormal termination), ST1, ST2; keep head, cylinder or sector
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .terminated

    add 1, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

    jz  0, .terminated

.bad_input:
    # Floppy is accessible, but input parameters are invalid
    # Set up ST0 (abnormal termination), ST1 (end of cylinder, no data), ST2
    # TODO only set ST1 bit 7 when sector is wrong
    # TODO set up ST2 (bits 1, 4) when cylinder is wrong
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b10000100, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .bad_input_after_log

    add 1, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

.bad_input_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

    jz  0, .terminated

.no_floppy:
    # Floppy is not accessible
    # Set up ST0 (not ready, abnormal termination), ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], .no_floppy_after_log

    add 1, 0, [rb - 1]
    add [rb + dma_count], 0, [rb - 2]
    arb -2
    call fdc_exec_read_write_data_log

.no_floppy_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

.terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

    arb 6
    ret 0
.ENDFRAME

##########
fdc_exec_write_deleted_data:
.FRAME
    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: write deleted data command ","is not supported", 0
.ENDFRAME

##########
fdc_exec_read_write_data_log:
.FRAME write, dma_count; tmp
    arb -1

    call log_start

    add .read_write_msg, [rb + write], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call print_str

    lt  [fdc_cmd_st0], 64, [rb + tmp]
    add .result_msg, [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call print_str

    out ' '
    out 'C'
    add [fdc_cmd_cylinder], 0, [rb - 1]
    arb -1
    call print_num

    out ' '
    out 'H'
    add [fdc_cmd_head], 0, [rb - 1]
    arb -1
    call print_num

    out ' '
    out 'S'
    add [fdc_cmd_sector], 0, [rb - 1]
    arb -1
    call print_num

    jz  [fdc_cmd_multi_track], .no_mt

    add .mt_msg, 0, [rb - 1]
    arb -1
    call print_str

.no_mt:
    add .cnt_f_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + dma_count], 1, [rb - 1]
    arb -1
    call print_num

    add .cnt_t_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [dma_count_ch2], 1, [rb - 1]
    arb -1
    call print_num

    out 10

    arb 1
    ret 2

.read_write_msg:
    db  .read_msg
    db  .write_msg
.read_msg:
    db  "fdd read data:  ", 0
.write_msg:
    db  "fdd write data: ", 0

.mt_msg:
    db  ", multi-track", 0
.cnt_f_msg:
    db  ", bytes ", 0
.cnt_t_msg:
    db  " -> ", 0

.result_msg:
    db  .failure_msg
    db  .success_msg
.failure_msg:
    db  "FAILURE", 0
.success_msg:
    db  "SUCCESS", 0
.ENDFRAME

##########
fdc_exec_read_track:
.FRAME
    # TODO implement read track
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: read track command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_read_id:
.FRAME tmp, sector_count
    arb -2

    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # TODO validate C H S is in range

    # Floppy is accessible; respond with ST0 (see above) ST1 ST2 C H R N
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # For C H R N keep the head that was requested, report current cylinder
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [fdc_cmd_cylinder]

    # Report a different sector than what we reported last time
    add fdc_present_sector_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 1, [fdc_cmd_sector]

    # How many total sectors are on this cylinder?
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + sector_count]

    # Wrap around reported sector to 0 if we overflow
    eq  [fdc_cmd_sector], [rb + sector_count], [rb + tmp]
    jz  [rb + tmp], .after_sector_wraparound
    add 0, 0, [fdc_cmd_sector]
    # TODO this is wrong, sectors are numbered starting 1 (both the 1 and the wraparound condition)

.after_sector_wraparound:
    # Save new present sector
    add fdc_present_sector_units, [fdc_cmd_unit_selected], [ip + 3]
    add [fdc_cmd_sector], 0, [0]

    jz  0, .terminated

.no_floppy:
    # Floppy is not accessible, set up ST0 (not ready, abnormal termination),
    # ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

.terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

.after_irq:
    arb 2
    ret 0
.ENDFRAME

##########
fdc_exec_format_track:
.FRAME
    # TODO for now, return a valid "write protected" status
    # TODO implement format track
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: format track command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_scan_equal:
.FRAME
    # TODO implement scan equal
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: scan equal command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_scan_low_or_equal:
.FRAME
    # TODO implement scan low or equal
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: scan low or equal command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_scan_high_or_equal:
.FRAME
    # TODO implement scan high or equal
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: scan high or equal command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_recalibrate:
.FRAME
    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Floppy is accessible, retract the head to cylinder 0
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add 0, 0, [0]

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Set up STO to report a successful seek (seek end)
    add 0b00100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, .terminated

.no_floppy:
    # Floppy is not inserted, set up ST0 (not ready, seek end, abnormal termination)
    add 0b01101000, [fdc_cmd_st0], [fdc_cmd_st0]

.terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

.after_irq:
    ret 0
.ENDFRAME

##########
fdc_exec_specify:
.FRAME
    # We ignore all the timings, but verify that ND (bit 0) is zero for DMA mode
    add bit_0, [fdc_cmd_hlt_nd], [ip + 1]
    jnz [0], .non_dma

    ret 0

.non_dma:
    add fdc_error_non_dma, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
fdc_exec_sense_drive_status:
.FRAME
    # TODO implement sense drive status
    #ret 0

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: sense drive status command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_seek:
.FRAME cylinders, tmp
    arb -2

    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], .no_floppy

    # Floppy is accessible, load cylinder count
    add fdc_medium_cylinders_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + cylinders]

    # Requested cylinder number must be in range
    lt  [fdc_cmd_cylinder], 0, [rb + tmp]
    jnz [rb + tmp], .bad_input
    lt  [fdc_cmd_cylinder], [rb + cylinders], [rb + tmp]
    jz  [rb + tmp], .bad_input

    # Report disk activity
    jz  [fdc_activity_callback], .after_callback
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    arb -1
    call [fdc_activity_callback]

.after_callback:
    # Set present cylinder to the requested cylinder
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add [fdc_cmd_cylinder], 0, [0]

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Set up STO to report a successful seek (seek end)
    add 0b00100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, .terminated

.bad_input:
    # Floppy is accessible, but input parameters are invalid; set up ST0 (seek end, abnormal termination)
    add 0b01100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, .terminated

.no_floppy:
    # Floppy is not inserted, set up ST0 (not ready, seek end, abnormal termination)
    add 0b01101000, [fdc_cmd_st0], [fdc_cmd_st0]

.terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

    arb 2
    ret 0
.ENDFRAME

##########
fdc_activity_callback:
    db  0

.EOF
