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
.IMPORT fdc_cmd_mfm
.IMPORT fdc_cmd_skip_deleted
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

# From util/nibbles.s
.IMPORT nibbles

##########
fdc_exec_read_data:
.FRAME
    # Execute read data
    # TODO

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

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_read_deleted_data:
.FRAME
    # Execute read deleted data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_write_data:
.FRAME
    # Execute write data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_write_deleted_data:
.FRAME
    # Execute write deleted data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_read_track:
.FRAME
    # Execute read track
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_read_id:
.FRAME tmp
    arb -1

    # Execute read id; prepare defaults for ST0
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

    # For C H R N we return the head that was requested, current track, some random sector
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [fdc_cmd_cylinder]
    add fdc_present_sector_units, [fdc_cmd_unit_selected], [ip + 1]
    add [0], 0, [fdc_cmd_sector]

    # Increase the reported sector so we report a different one each time
    add [fdc_cmd_sector], 1, [fdc_cmd_sector]

    # TODO track 0 has a different number of sectors
    add fdc_medium_sectors_units, [fdc_cmd_unit_selected], [ip + 1]
    lt  [0], [fdc_cmd_sector], [rb + tmp]
    jz  [rb + tmp], fdc_exec_read_id_after_sector
    add 0, 0, [fdc_cmd_sector]

fdc_exec_read_id_after_sector:
    add fdc_present_sector_units, [fdc_cmd_unit_selected], [ip + 3]
    add [fdc_cmd_sector], 0, [0]

    jz  0, fdc_exec_read_id_terminated

fdc_exec_read_id_no_floppy:
    # Floppy is not accessible, set up ST0 (not ready, abnormal termination),
    # ST1 (missing address mark, no data), ST2
    add 0b01001000, [fdc_cmd_st0], [fdc_cmd_st0]
    add 0b00000101, 0, [fdc_cmd_st1]
    add 0, 0, [fdc_cmd_st2]

    # Return requested head, zero out track and sector
    add 0, 0, [fdc_cmd_cylinder]
    add 0, 0, [fdc_cmd_sector]

fdc_exec_read_id_terminated:
    # Raise INT 0e = IRQ6
    add 1, 0, [fdc_interrupt_pending]
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    arb 1
    ret 0
.ENDFRAME

##########
fdc_exec_format_track:
.FRAME
    # Execute format track
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_scan_equal:
.FRAME
    # Execute scan equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_scan_low_or_equal:
.FRAME
    # Execute scan low or equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_scan_high_or_equal:
.FRAME
    # Execute scan high or equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    ret 0
.ENDFRAME

##########
fdc_exec_recalibrate:
.FRAME
    # Execute recalibrate
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is a floppy inserted?
    add fdc_config_inserted_units, [fdc_cmd_unit_selected], [ip + 1]
    jnz [0], fdc_exec_recalibrate_have_floppy

    # Floppy is not inserted, set up ST0 (not ready, seek end, abnormal termination)
    add 0b01101000, [fdc_cmd_st0], [fdc_cmd_st0]
    jz  0, fdc_exec_recalibrate_terminated

fdc_exec_recalibrate_have_floppy:
    # Floppy is inserted, retract the head to track 0
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add 0, 0, [0]

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Set up STO to report a successful seek (seek end)
    add 0b00010000, [fdc_cmd_st0], [fdc_cmd_st0]

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
    # Execute sense drive status
    # TODO

    ret 0
.ENDFRAME

##########
fdc_exec_seek:
.FRAME
    # Execute seek
    # TODO

    # TODO handle units that are not present/no floppy, see docs what to do then
    # TODO during seek compare PCN with fdc_cmd_cylinder which is the target cylinder

    # TODO interrupt
    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt
    # TODO during command phase of seek fdc is in busy state (in MSR), during execution it's not

    ret 0
.ENDFRAME

.EOF
