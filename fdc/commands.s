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

# From fdc_config.s
.IMPORT fdc_config_connected_units
.IMPORT fdc_config_inserted_units

# From fdc_control.s
.IMPORT fdc_dor_enable_motor_units
.IMPORT fdc_interrupt_pending

# From fdc_drives.s
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

# From cpu/interrupt.s
.IMPORT interrupt

# From util/bits.s
.IMPORT bits

##########
fdc_exec_read_data:
.FRAME
    # TODO implement read data

    # Read sectors on current track, throw data away until sector number matches R
    # (reads ID Address Marks and ID fields). Then put the data to bus.
    # After reading the sector, increment sector number and continue outputting
    # until DMA controller sends TC (terminal count) then stop outputting data
    # (looks like in the middle of the sector).
    # After TC, continue reading sector and throw data away, then check CRC and
    # finish the read data command.

    # With MT read sector 1 side 0... sector L side 1 (L = last sector on side)

    # If N=0, DTL defines how much of the sector should we send to data bus.
    # If N>0, DTL is ignored. Still includes reading multiple sectors if no TC.

    # If we don't find R on this track, set ND=1 in SR1 and b7=0,b6=1 in SR0, then end.

    # If CRC error in ID field, DE=1 in SR1. If CRC error in Data Field also DD=1 in SR2.
    # Also b7=0,b6=1 in SR0, then end.

    # If SK=0 and we read Deleted Data Address Mark, set CM=1 in SR2 then end.
    # If SK=1 FDC skips the deleted sector and reads next sector, not even check CRC.

    # For CHRN in result phase, see table on page 435 in UPD765.pdf. Based on MT and EOT.

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt

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
    # TODO implement write data

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

    # Return requested head, zero out cylinder and sector
    add 0, 0, [fdc_cmd_cylinder]
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
    # TODO implement format track

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
    add 0b00010000, [fdc_cmd_st0], [fdc_cmd_st0]

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
.FRAME
    # TODO implement seek

    # TODO handle units that are not present/no floppy, see docs what to do then
    # TODO during seek compare PCN with fdc_cmd_cylinder which is the target cylinder
    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt
    # TODO during command phase of seek fdc is in busy state (in MSR), during execution it's not

#    # Raise INT 0e = IRQ6
#    add 1, 0, [fdc_interrupt_pending]
#    add 0x0e, 0, [rb - 1]
#    arb -1
#    call interrupt
#
#    ret 0

    add fdc_exec_seek_error, 0, [rb - 1]
    arb -1
    call report_error

fdc_exec_seek_error:
    db  "fdc: seek command ","is not implemented", 0
.ENDFRAME

.EOF
