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

# From the config file
.IMPORT config_log_fdd

# From a linked binary
.IMPORT fdc_activity_callback

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

# From pic_8259a_execute.s
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

# From util/bits.s
.IMPORT bits

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num

##########
fdc_exec_read_data:
.FRAME heads, sectors, sectors_eot, dma_count, addr_c, addr_s, tmp
    arb -7

    add [dma_count_ch2], 0, [rb + dma_count]

    # Prepare base value for ST0
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is the unit connected?
    add fdc_config_connected_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_read_data_no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_read_data_no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_read_data_no_floppy

    # Floppy is accessible, report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    # Load floppy parameters
    add fdc_medium_heads_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + heads]
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + sectors]

    # Limit number of sectors to EOT from the command input
    add [rb + sectors], 0, [rb + sectors_eot]
    lt  [fdc_cmd_end_of_track], [rb + sectors_eot], [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_data_after_eot
    add [fdc_cmd_end_of_track], 0, [rb + sectors_eot]

fdc_exec_read_data_after_eot:
    # Cylinder number must match the cylinder we are on
    eq  [fdc_cmd_cylinder], [fdc_present_cylinder_units], [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_data_bad_input

    # Head number must be in range
    lt  [fdc_cmd_head], 0, [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_bad_input
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_data_bad_input

    # Sector number must be in range (1-based)
    lt  [fdc_cmd_sector], 1, [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_bad_input
    lt  [rb + sectors_eot], [fdc_cmd_sector], [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_bad_input

    # Check the DMA controller
    jnz [dma_disable_controller], fdc_exec_read_data_no_dma
    jnz [dma_mask_ch2], fdc_exec_read_data_no_dma

    eq  [dma_transfer_type_ch2], 1, [rb + tmp]              # transfer type must be write (1)
    jz  [rb + tmp], fdc_exec_read_data_no_dma

    eq  [dma_mode_ch2], 1, [rb + tmp]                       # only single mode is supported (1)
    jz  [rb + tmp], fdc_exec_read_data_no_dma

    # DMA is set up, start reading at head H sector S up to end of the track/cylinder,
    # or until the DMA controller has enough data

    # Calculate cylinder address in intcode memory:
    # addr_c = floppy + cylinder * heads * sectors * 512
    mul [fdc_cmd_cylinder], [rb + heads], [rb + addr_c]
    mul [rb + addr_c], [rb + sectors], [rb + addr_c]
    mul [rb + addr_c], 512, [rb + addr_c]
    add [floppy], [rb + addr_c], [rb + addr_c]

fdc_exec_read_data_loop:
    # Does the DMA controller expect more data?
    eq  [dma_count_ch2], -1, [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_all_data_read

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
    lt  [rb + sectors_eot], [fdc_cmd_sector], [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_data_loop

    # End of track, move to sector 1
    add 1, 0, [fdc_cmd_sector]

    # Is this a multi-track operation?
    jnz [fdc_cmd_multi_track], fdc_exec_read_data_multi_track

    # Single track operation is finished, move to the same head on next cylinder
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]
    jz  0, fdc_exec_read_data_all_data_read

fdc_exec_read_data_multi_track:
    # Multi-track operation, move to next side
    add [fdc_cmd_head], 1, [fdc_cmd_head]

    # Does this side actually exist on the disk?
    lt  [fdc_cmd_head], [rb + heads], [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_loop

    # No, end of cylinder, move to head 0 on next cylinder
    add 0, 0, [fdc_cmd_head]
    add [fdc_cmd_cylinder], 1, [fdc_cmd_cylinder]

fdc_exec_read_data_all_data_read:
    # The DMA controller does not want more data, or there is no more data available
    # Respond with ST0 (see above) ST1 ST2, and C H R N that was set up above
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], fdc_exec_read_data_terminated

    add [rb + dma_count], 0, [rb - 1]
    arb -1
    call fdc_exec_read_data_log

    jz  0, fdc_exec_read_data_terminated

fdc_exec_read_data_no_dma:
    # Floppy is accessible, but the DMA controller is not ready to accept data
    # Set up ST0 (abnormal termination), ST1, ST2; keep head, cylinder or sector
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], fdc_exec_read_data_terminated

    add [rb + dma_count], 0, [rb - 1]
    arb -1
    call fdc_exec_read_data_log

    jz  0, fdc_exec_read_data_terminated

fdc_exec_read_data_bad_input:
    # Floppy is accessible, but input parameters are invalid
    # Set up ST0 (abnormal termination), ST1 (end of cylinder, no data), ST2
    # TODO only set ST1 bit 7 when sector is wrong
    # TODO set up ST2 (bits 1, 4) when cylinder is wrong
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b10000100, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], fdc_exec_read_data_bad_input_after_log

    add [rb + dma_count], 0, [rb - 1]
    arb -1
    call fdc_exec_read_data_log

fdc_exec_read_data_bad_input_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

    jz  0, fdc_exec_read_data_terminated

fdc_exec_read_data_no_floppy:
    # Floppy is not accessible
    # Set up ST0 (not ready, abnormal termination), ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Floppy disk logging
    jz  [config_log_fdd], fdc_exec_read_data_no_floppy_after_log

    add [rb + dma_count], 0, [rb - 1]
    arb -1
    call fdc_exec_read_data_log

fdc_exec_read_data_no_floppy_after_log:
    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

fdc_exec_read_data_terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

fdc_exec_read_data_after_irq:
    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    arb 7
    ret 0
.ENDFRAME

##########
fdc_exec_read_data_log:
.FRAME dma_count; tmp
    arb -1

    call log_start

    add fdc_exec_read_data_log_start, 0, [rb - 1]
    arb -1
    call print_str

    lt  [fdc_cmd_st0], 64, [rb + tmp]
    add fdc_exec_read_data_log_result, [rb + tmp], [ip + 1]
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

    jz  [fdc_cmd_multi_track], fdc_exec_read_data_log_no_mt

    add fdc_exec_read_data_log_mt, 0, [rb - 1]
    arb -1
    call print_str

fdc_exec_read_data_log_no_mt:
    add fdc_exec_read_data_log_cnt_f, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + dma_count], 1, [rb - 1]
    arb -1
    call print_num

    add fdc_exec_read_data_log_cnt_t, 0, [rb - 1]
    arb -1
    call print_str

    add [dma_count_ch2], 1, [rb - 1]
    arb -1
    call print_num

    out 10

    arb 1
    ret 1

fdc_exec_read_data_log_start:
    db  "fdd read data: ", 0
fdc_exec_read_data_log_mt:
    db  ", multi-track", 0
fdc_exec_read_data_log_cnt_f:
    db  ", bytes ", 0
fdc_exec_read_data_log_cnt_t:
    db  " -> ", 0
fdc_exec_read_data_log_result:
    db  fdc_exec_read_data_log_failure
    db  fdc_exec_read_data_log_success
fdc_exec_read_data_log_failure:
    db  "FAILURE", 0
fdc_exec_read_data_log_success:
    db  "SUCCESS", 0
.ENDFRAME

##########
fdc_exec_read_deleted_data:
.FRAME
    add fdc_exec_read_deleted_data_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_read_deleted_data_error:
    db  "fdc: read deleted data command ", "is not supported", 0
.ENDFRAME

##########
fdc_exec_write_data:
.FRAME
    # TODO for now, return a valid "write protected" status
    # TODO implement write data
    # TODO disk activity

#    # Trigger IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#
#    add 6, 0, [rb - 1]
#    arb -1
#    call interrupt_request
#
#    ret 0

    add fdc_exec_write_data_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_write_data_error:
    db  "fdc: write data command ","is not implemented", 0
.ENDFRAME

##########
fdc_exec_write_deleted_data:
.FRAME
    add fdc_exec_write_deleted_data_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_write_deleted_data_error:
    db  "fdc: write deleted data command ","is not supported", 0
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

    add fdc_exec_read_track_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_read_track_error:
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
    jz  [0], fdc_exec_read_id_no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_read_id_no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_read_id_no_floppy

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
    jz  [rb + tmp], fdc_exec_read_id_after_sector_wraparound
    add 0, 0, [fdc_cmd_sector]
    # TODO this is wrong, sectors are numbered starting 1 (both the 1 and the wraparound condition)

fdc_exec_read_id_after_sector_wraparound:
    # Save new present sector
    add fdc_present_sector_units, [fdc_cmd_unit_selected], [ip + 3]
    add [fdc_cmd_sector], 0, [0]

    jz  0, fdc_exec_read_id_terminated

fdc_exec_read_id_no_floppy:
    # Floppy is not accessible, set up ST0 (not ready, abnormal termination),
    # ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

fdc_exec_read_id_terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

fdc_exec_read_id_after_irq:
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

    add fdc_exec_format_track_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_format_track_error:
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

    add fdc_exec_scan_equal_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_scan_equal_error:
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

    add fdc_exec_scan_low_or_equal_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_scan_low_or_equal_error:
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

    add fdc_exec_scan_high_or_equal_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_scan_high_or_equal_error:
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
    jz  [0], fdc_exec_recalibrate_no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_recalibrate_no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_recalibrate_no_floppy

    # Floppy is accessible, retract the head to cylinder 0
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add 0, 0, [0]

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Set up STO to report a successful seek (seek end)
    add 0b00100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, fdc_exec_recalibrate_terminated

fdc_exec_recalibrate_no_floppy:
    # Floppy is not inserted, set up ST0 (not ready, seek end, abnormal termination)
    add 0b01101000, [fdc_cmd_st0], [fdc_cmd_st0]

fdc_exec_recalibrate_terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

fdc_exec_recalibrate_after_irq:
    ret 0
.ENDFRAME

##########
fdc_exec_specify:
.FRAME
    # We ignore all the timings, but verify that ND (bit 0) is zero for DMA mode
    add bits, [fdc_cmd_hlt_nd], [ip + 1]
    jnz [0], fdc_exec_specify_non_dma

    ret 0

fdc_exec_specify_non_dma:
    add fdc_error_non_dma, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
fdc_exec_sense_drive_status:
.FRAME
    # TODO implement sense drive status
    #ret 0

    add fdc_exec_sense_drive_status_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_sense_drive_status_error:
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
    jz  [0], fdc_exec_seek_no_floppy

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_seek_no_floppy

    # Is the motor running?
    add fdc_dor_enable_motor_units, [fdc_cmd_unit_selected], [ip + 1]
    jz  [0], fdc_exec_seek_no_floppy

    # Floppy is accessible, load cylinder count
    add fdc_medium_cylinders_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + cylinders]

    # Requested cylinder number must be in range
    lt  [fdc_cmd_cylinder], 0, [rb + tmp]
    jnz [rb + tmp], fdc_exec_seek_bad_input
    lt  [fdc_cmd_cylinder], [rb + cylinders], [rb + tmp]
    jz  [rb + tmp], fdc_exec_seek_bad_input

    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    # Set present cylinder to the requested cylinder
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add [fdc_cmd_cylinder], 0, [0]

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Set up STO to report a successful seek (seek end)
    add 0b00100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, fdc_exec_seek_terminated

fdc_exec_seek_bad_input:
    # Floppy is accessible, but input parameters are invalid; set up ST0 (seek end, abnormal termination)
    add 0b01100000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, fdc_exec_seek_terminated

fdc_exec_seek_no_floppy:
    # Floppy is not inserted, set up ST0 (not ready, seek end, abnormal termination)
    add 0b01101000, [fdc_cmd_st0], [fdc_cmd_st0]

fdc_exec_seek_terminated:
    # Trigger IRQ6
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

fdc_exec_seek_after_irq:
    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    arb 2
    ret 0
.ENDFRAME

.EOF
