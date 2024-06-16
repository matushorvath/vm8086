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

.IMPORT fdc_cmd_hlt_nd

.IMPORT fdc_cmd_st0
.IMPORT fdc_cmd_st1
.IMPORT fdc_cmd_st2
.IMPORT fdc_cmd_st3

# From fdc_init.s
.IMPORT fdc_error_non_dma

# From cpu/error.s
.IMPORT report_error

# From cpu/images.s
.IMPORT floppy_image

# From cpu/interrupt.s
.IMPORT interrupt

# From dev/dma_8237a.s
.IMPORT dma_disable_controller
.IMPORT dma_mask_ch2
.IMPORT dma_transfer_type_ch2
.IMPORT dma_mode_ch2
.IMPORT dma_count_ch2
.IMPORT dma_receive_data

# From util/bits.s
.IMPORT bits

##########
fdc_exec_read_data:
.FRAME cylinders, heads, sectors, addr, count, tmp
    arb -6

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

    # Floppy is accessible, load floppy parameters
    add fdc_medium_heads_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + heads]
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [rb + sectors]

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
    lt  [rb + sectors], [fdc_cmd_sector], [rb + tmp]
    jnz [rb + tmp], fdc_exec_read_data_bad_input

    # Check the DMA controller
    jnz [dma_disable_controller], fdc_exec_read_data_no_dma
    jnz [dma_mask_ch2], fdc_exec_read_data_no_dma

    eq  [dma_transfer_type_ch2], 1, [rb + tmp]              # transfer type must be write (1)
    jz  [rb + tmp], fdc_exec_read_data_no_dma

    eq  [dma_mode_ch2], 1, [rb + tmp]                       # only single mode is supported (1)
    jz  [rb + tmp], fdc_exec_read_data_no_dma

    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    # DMA is set up, find the data we want to read
    # addr = floppy_image + ((cylinder * heads + head) * sectors + (sector - 1)) * 512
    mul [fdc_cmd_cylinder], [rb + heads], [rb + addr]
    add [fdc_cmd_head], [rb + addr], [rb + addr]
    mul [rb + sectors], [rb + addr], [rb + addr]
    add [fdc_cmd_sector], [rb + addr], [rb + addr]
    add -1, [rb + addr], [rb + addr]
    mul 512, [rb + addr], [rb + addr]
    add [floppy_image], [rb + addr], [rb + addr]

    # Determine how much data should we read (the counter in DMA controller plus 1)
    add [dma_count_ch2], 1, [rb + count]
    # TODO If N=0, DTL defines how much of the sector should we send to data bus.
    # TODO If N>0, DTL is ignored. Still includes reading multiple sectors if no TC.

    # TODO for now we can read one sector only, 512 bytes
    # boot sector read from 8088_bios: MT=1 HD=0 C=0 H=0 S=1 N=02 EOT=36 GPL=27 DTL=0xff
    jz  [fdc_cmd_multi_track], fdc_exec_read_data_not_supported

    eq  [rb + count], 512, [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_data_not_supported

    # TODO read multiple sectors, wraparound when reaching the last sector, until DMA sends TC
    # TODO support EOT, final sector number on track; stop reading after sector number equal to EOT
    # TODO support MT: read sector 1 side 0... sector L side 1 (L = last sector on side)

    # Send data to the DMA controller, channel 2
    add 2, 0, [rb - 1]
    add [rb + addr], 0, [rb - 2]
    add [rb + count], 0, [rb - 3]
    arb -3
    call dma_receive_data

    # Respond with ST0 (see above) ST1 ST2 C H R N
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # For C H R N keep the head and cylinder that was requested, report last read sector
    # TODO see table on page 435 in UPD765.pdf, the correct values are based on MT and EOT
    # TODO update fdc_cmd_sector if we read multiple sectors
    add [fdc_cmd_sector], 1, [fdc_cmd_sector] # very rough fake of the actual correct result

    jz  0, fdc_exec_read_data_terminated

fdc_exec_read_data_not_supported:                           # TODO remove
    add fdc_exec_read_data_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_read_data_error:                                   # TODO remove
    db  "fdc: requested read data command variant ", "is not supported", 0

fdc_exec_read_data_no_dma:
    # Floppy is accessible, but the DMA controller is not ready to accept data
    # Set up ST0 (abnormal termination), ST1, ST2; keep head, cylinder or sector
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    jz  0, fdc_exec_read_data_terminated

fdc_exec_read_data_bad_input:
    # Floppy is accessible, but input parameters are invalid
    # Set up ST0 (abnormal termination), ST1 (end of cylinder, no data), ST2
    # TODO only set ST1 bit 7 when sector is wrong
    # TODO set up ST2 (bits 1, 4) when cylinder is wrong
    add 0b01000000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b10000100, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

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

    # Zero out cylinder, head and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_head]
    add 0, 0, [fdc_cmd_sector]

fdc_exec_read_data_terminated:
    # Raise INT 0e = IRQ6
    add 1, 0, [fdc_interrupt_pending]
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    arb 6
    ret 0
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

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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
    # Raise INT 0e = IRQ6
    add 1, 0, [fdc_interrupt_pending]
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    arb 2
    ret 0
.ENDFRAME

##########
fdc_exec_format_track:
.FRAME
    # TODO for now, return a valid "write protected" status
    # TODO implement format track
    # TODO disk activity

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
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
    # Raise INT 0e = IRQ6
    add 1, 0, [fdc_interrupt_pending]
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

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
    # Raise INT 0e = IRQ6
    add 1, 0, [fdc_interrupt_pending]
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    # Report disk activity
    add [fdc_cmd_unit_selected], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call fdc_activity_callback

    arb 2
    ret 0
.ENDFRAME

.EOF
