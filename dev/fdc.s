.EXPORT init_fdc

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# From cpu/interrupt.s
.IMPORT interrupt

# From util/bits.s
.IMPORT bits

# From util/nibbles.s
.IMPORT nibbles

# TODO remove
.IMPORT print_num_radix

# TODO fdc should not work while fdc_dor_reset == 0
# TODO fdc should not read/write data or seek etc while the motor is off fdc_dor_enable_motor_a/b
# TODO fdc should complain about fdc_dor_enable_dma 

##########
fdc_ports:
    db  0xf2, 0x03, 0, fdc_dor_write                        # Digital Output Register
    db  0xf4, 0x03, fdc_status_read, 0                      # Main Status Register
    db  0xf5, 0x03, fdc_data_read, fdc_data_write           # Diskette Data Register
    db  0xf7, 0x03, fdc_dir_read, fdc_control_write         # Digital Input Register/Diskette Control Register

    db  -1, -1, -1, -1

##########
init_fdc:
.FRAME
    # Register I/O ports
    add fdc_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
fdc_dor_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    out 'A' # TODO remove
    out 'w'
    out '_'
    add [rb + value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix
    out ' '

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Save the original fdc_dor_reset value before changing it
    eq  [fdc_dor_reset], 0, [rb + tmp]
    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [fdc_dor_reset]
    add [fdc_dor_reset], [rb + tmp], [rb + tmp]

    # If fdc_dor_reset was low and now is high, reset the floppy controller
    eq  [rb + tmp], 2, [rb + tmp]
    jz  [rb + tmp], fdc_dor_write_after_reset
    call fdc_d765ac_reset

fdc_dor_write_after_reset:
    # Save the other bits
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [fdc_dor_drive_a_select]

    add [rb + value_bits], 3, [ip + 1]
    jnz [0], fdc_dor_write_dma_enabled

    add fdc_error_non_dma, 0, [rb - 1]
    arb -1
    call report_error

fdc_dor_write_dma_enabled:
    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_a]

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_b]

    arb 2
    ret 2
.ENDFRAME

##########
fdc_status_read:
.FRAME addr; value, tmp
    arb -2

    out 'S' # TODO remove
    out 'r'
    out '_'

    # Controller is busy in non-idle command state
    # Bit 4 CB  - Controller is busy reading or writing
    lt  0, [fdc_cmd_state], [rb + tmp]
    mul [rb + tmp], 0b00010000, [rb + value]

    # Data transfer direction is CPU to FDC in command phase, FDC to CPU in result phase
    # Bit 6 DIO - data input/output, 0 - from CPU to FDC, 1 - from FDC to CPU
    mul [fdc_cmd_result_phase], 0b01000000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    # Following bits have fixed values, since seeking, reading and writing is immediate,
    # and we only support DMA mode:
    # Bit 0 DAB - FDD A is busy seeking
    # Bit 1 DBB - FDD B is busy seeking
    # Bit 2 reserved
    # Bit 3 reserved
    # Bit 5 NDM - non-DMA mode
    # Bit 7 RQM - data register is ready for data transfer
    add [rb + value], 0b10000000, [rb + value]

    # TODO remove
    add [rb + value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix
    out ' '

    arb 2
    ret 1
.ENDFRAME

# TODO after the execution phase, interrupt will occur

##########
fdc_data_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    # TODO remove
    jnz [fdc_cmd_state], TODO_fdc_data_write_skip_nl
    out 10

TODO_fdc_data_write_skip_nl:
    out 'D'
    out 'w'
    out '_'

    add [rb + value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    # Is the FDC processing a command?
    jz  [fdc_cmd_state], fdc_data_write_idle

    # Yes, is this the command phase?
    jnz [fdc_cmd_result_phase], fdc_data_write_invalid

    # Yes, use the state as a label to jump to
    jz  0, [fdc_cmd_state]

##########
# Idle state

fdc_data_write_idle:
    # Parse the first byte of a new command
    # MT MF SK CMD_CODE(5)
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Save MT, MF, SK
    add [rb + value_bits], 7, [ip + 1]
    add [0], 0, [fdc_cmd_multi_track] # TODO execute multitrack operation

    add [rb + value_bits], 6, [ip + 1]
    add [0], 0, [fdc_cmd_mfm] # TODO validate that FM/MFM encoding matches the disk type

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [fdc_cmd_skip_deleted] # TODO execute support for skip deleted data

    # Read bottom 5 bits as the command code
    add [rb + value_bits], 4, [ip + 1]
    mul [0], 0b00010000, [fdc_cmd_code]

    mul [rb + value], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], [fdc_cmd_code], [fdc_cmd_code]

    # We are now in command phase
    add 0, 0, [fdc_cmd_result_phase]

    # Handle the state transition
    add fdc_data_write_idle_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fdc_data_write_idle_table:
    db  fdc_data_write_invalid                              #          00000
    db  fdc_data_write_invalid                              #          00001
    db  fdc_data_write_idle_to_hd_us                        #  0 MF SK 00010: read_track
    db  fdc_data_write_idle_to_srt_hut                      #  0  0  0 00011: specify
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 00100: sense_drive_status
    db  fdc_data_write_idle_to_hd_us                        # MT MF  0 00101: write_data
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 00110: read_data
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 00111: recalibrate
    db  fdc_data_write_exec_sense_interrupt_status          #  0  0  0 01000: sense_interrupt_status
    db  fdc_data_write_idle_to_hd_us                        # MT MF  0 01001: write_deleted_data
    db  fdc_data_write_idle_to_hd_us                        #  0 MF  0 01010: read_id
    db  fdc_data_write_invalid                              #          01011
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 01100: read_deleted_data
    db  fdc_data_write_idle_to_hd_us                        #  0 MF  0 01101: format_track
    db  fdc_data_write_invalid                              #          01110
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 01111: seek
    db  fdc_data_write_invalid                              #          10000
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 10001: scan_equal
    db  fdc_data_write_invalid                              #          10010
    db  fdc_data_write_invalid                              #          10011
    db  fdc_data_write_invalid                              #          10100
    db  fdc_data_write_invalid                              #          10101
    db  fdc_data_write_invalid                              #          10110
    db  fdc_data_write_invalid                              #          10111
    db  fdc_data_write_invalid                              #          11000
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 11001: scan_low_or_equal
    db  fdc_data_write_invalid                              #          11010
    db  fdc_data_write_invalid                              #          11011
    db  fdc_data_write_invalid                              #          11100
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 11101: scan_high_or_equal
    db  fdc_data_write_invalid                              #          11110
    db  fdc_data_write_invalid                              #          11111

fdc_data_write_idle_to_hd_us:
    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is write HD US
    add fdc_data_write_hd_us, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_idle_to_srt_hut:
    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is write SRT HUT
    add fdc_data_write_srt_hut, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

##########
# HD US state

fdc_data_write_hd_us:
    # Parse head and unit select information
    # X X X X X HD US(2)

    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Save HD and US
    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [fdc_cmd_head]

    add [rb + value_bits], 1, [ip + 1]
    mul [0], 0x00000010, [fdc_cmd_unit_selected]
    add [rb + value_bits], 0, [ip + 1]
    add [0], [fdc_cmd_unit_selected], [fdc_cmd_unit_selected]

    # Handle the state transition
    add fdc_data_write_hd_us_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fdc_data_write_hd_us_table:
    ds  2, 0                                               # 00000, 00001
    db  fdc_data_write_hd_us_to_c                           # 00010: read_track
    db  0                                                   # 00011: specify
    db  fdc_data_write_exec_sense_drive_status              # 00100: sense_drive_status
    db  fdc_data_write_hd_us_to_c                           # 00101: write_data
    db  fdc_data_write_hd_us_to_c                           # 00110: read_data
    db  fdc_data_write_exec_recalibrate                     # 00111: recalibrate
    db  0                                                   # 01000: sense_interrupt_status
    db  fdc_data_write_hd_us_to_c                           # 01001: write_deleted_data
    db  fdc_data_write_exec_read_id                         # 01010: read_id
    db  0                                                   # 01011
    db  fdc_data_write_hd_us_to_c                           # 01100: read_deleted_data
    db  fdc_data_write_hd_us_to_format_track_n              # 01101: format_track
    db  0                                                   # 01110
    db  fdc_data_write_hd_us_to_exec_seek                   # 01111: seek
    db  0                                                   # 10000
    db  fdc_data_write_hd_us_to_c                           # 10001: scan_equal
    ds  7, 0                                                # 10010-11000
    db  fdc_data_write_hd_us_to_c                           # 11001: scan_low_or_equal
    ds  3, 0                                                # 11010-11100
    db  fdc_data_write_hd_us_to_c                           # 11101: scan_high_or_equal
    ds  2, 0                                                # 11110, 11111

fdc_data_write_hd_us_to_c:
    # Next state is write C
    add fdc_data_write_c, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_hd_us_to_format_track_n:
    # Next state is write N
    add fdc_data_write_format_track_n, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_hd_us_to_exec_seek:
    # Next state is write NCN + execute seek
    add fdc_data_write_exec_seek, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

##########
# C, H, R, N states

fdc_data_write_c:
    # Save C (cylinder)
    add [rb + value], 0, [fdc_cmd_cylinder]

    # Next state is write H
    add fdc_data_write_h, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_h:
    # Is head number from the first byte equal to the head number here?
    eq  [fdc_cmd_head], [rb + value], [rb + tmp]

    # If it isn't, that's not valid
    jz  [rb + tmp], fdc_data_write_invalid

    # Next state is write R
    add fdc_data_write_r, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

    jz  0, fdc_data_write_done

fdc_data_write_r:
    # Save R (record, sector number)
    add [rb + value], 0, [fdc_cmd_sector]

    # Next state is write N
    add fdc_data_write_n, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_n:
    # Save N (number of bytes in sector)
    # TODO how is this used, do we need to save it?
    add [rb + value], 0, [fdc_cmd_bytes]

    # Next state is write EOT (outside of format track command)
    add fdc_data_write_eot, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

##########
# EOT, GPL, DTL/STP states

fdc_data_write_eot:
    # Save EOT (end of track, final sector number on a cylinder)
    # TODO how is this used, do we need to save it?
    add [rb + value], 0, [fdc_cmd_end_of_track]

    # Next state is write GPL
    add fdc_data_write_gpl, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_gpl:
    # Save GPL (gap 3 length, spacing between sectors)
    # TODO how is this used, do we need to save it? maybe just verify it is correct for this floppy type?
    add [rb + value], 0, [fdc_cmd_gap_length]

    # Next state is write DTL/STP (outside of format track command)
    add fdc_data_write_dtl_stp, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_dtl_stp:
    # Save DTL or STP, they share the same variable
    # DTL (data length, if N is 0, DTL is the length to read/write to a sector)
    # STP (1=compare contiguous sectors, 2=compare alternate sectors)
    add [rb + value], 0, [fdc_cmd_data_length_or_step]

    # Next state is always read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]

    # Execute the command
    add fdc_data_write_dtl_stp_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fdc_data_write_dtl_stp_table:
    ds  2, 0                                                # 00000, 00001
    db  fdc_data_write_exec_read_track                      # 00010: read_track
    ds  2, 0                                                # 00011, 00100: specify, sense_drive_status
    db  fdc_data_write_exec_write_data                      # 00101: write_data
    db  fdc_data_write_exec_read_data                       # 00110: read_data
    ds  2, 0                                                # 00111, 01000: recalibrate, sense_interrupt_status
    db  fdc_data_write_exec_write_deleted_data              # 01001: write_deleted_data
    ds  2, 0                                                # 01010, 01011: read_id
    db  fdc_data_write_exec_read_deleted_data               # 01100: read_deleted_data
    ds  4, 0                                                # 01101-10000: format_track, seek
    db  fdc_data_write_exec_scan_equal                      # 10001: scan_equal
    ds  7, 0                                                # 10010-11000
    db  fdc_data_write_exec_scan_low_or_equal               # 11001: scan_low_or_equal
    ds  3, 0                                                # 11010-11100
    db  fdc_data_write_exec_scan_high_or_equal              # 11101: scan_high_or_equal
    ds  2, 0                                                # 11110, 11111

##########
# Format track states: N, SC, GPL, D

fdc_data_write_format_track_n:
    # Save N (number of bytes in sector)
    # TODO how is this used, do we need to save it?
    add [rb + value], 0, [fdc_cmd_bytes]

    # Format track command, next state is write SC
    add fdc_data_write_format_track_sc, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_format_track_sc:
    # Save SC (number of sectors per cylinder)
    add [rb + value], 0, [fdc_cmd_sectors_per_cylinder]

    # Next state is write GPL
    add fdc_data_write_format_track_gpl, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_format_track_gpl:
    # Save GPL (gap 3 length, spacing between sectors)
    # TODO how is this used, do we need to save it? maybe just verify it is correct for this floppy type?
    add [rb + value], 0, [fdc_cmd_gap_length]

    # Format track command, next state is write D + execute format track
    add fdc_data_write_exec_format_track, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

##########
# Specify state: SRT/HUT

fdc_data_write_srt_hut:
    # Next state is write HLT ND + execute specify
    add fdc_data_write_exec_specify, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

##########
# Command execution

fdc_data_write_exec_read_data:
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
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_read_deleted_data:
    # Execute read deleted data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_write_data:
    # Execute write data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_write_deleted_data:
    # Execute write deleted data
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_read_track:
    # Execute read track
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_read_id:
    # Execute read id
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_format_track:
    # Save D (data pattern to be written to a sector)
    add [rb + value], 0, [fdc_cmd_data_pattern]

    # Execute format track
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_scan_equal:
    # Execute scan equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_scan_low_or_equal:
    # Execute scan low or equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_scan_high_or_equal:
    # Execute scan high or equal
    # TODO

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]
    # TODO raise interrupt here
    # TODO set up next state

    jz  0, fdc_data_write_done

fdc_data_write_exec_recalibrate:
    # Execute recalibrate
    mul [fdc_cmd_head], 0b00000100, [fdc_cmd_st0]
    add [fdc_cmd_unit_selected], [fdc_cmd_st0], [fdc_cmd_st0]

    # Is this unit 0/1?
    lt  [fdc_cmd_unit_selected], 2, [rb + tmp]
    jnz [rb + tmp], fdc_data_write_exec_recalibrate_unit01

    # Unit 2/3 is not present, set up ST0 to report a failure
    # (not ready, equipment check, seek end, abnormal termination)
    add 0b01111000, [fdc_cmd_st0], [fdc_cmd_st0]

    jz  0, fdc_data_write_exec_recalibrate_terminated

fdc_data_write_exec_recalibrate_unit01:
    # Unit 0/1
    # TODO these units could also be not present or not ready, make it configurable

    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt

    # Retract the head of this unit to track 0
    add fdc_present_cylinder_units, [fdc_cmd_unit_selected], [ip + 3]
    add 0, 0, [0]

    # Set up STO for a successful seek (seek end)
    add 0b00010000, [fdc_cmd_st0], [fdc_cmd_st0]

fdc_data_write_exec_recalibrate_terminated:
    # Next state is idle
    add 0, 0, [fdc_cmd_state]

    # Raise INT 0e = IRQ6, since the recalibration is finished
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, fdc_data_write_done

fdc_data_write_exec_sense_interrupt_status:
    # Execute sense interrupt status; invalid command if interrupt is not pending
    jz  [fdc_interrupt_pending], fdc_data_write_invalid

    # ST0 bits 0, 5, 6, 7 as well as PCN are set up by a previous seek or recalibrate command
    # If another command was executed, it also should set ST0 accordingly

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_specify:
    # Execute specify
    # We ignore all the timings, but verify that ND (bit 0) is zero for DMA mode
    add bits, [rb + value], [ip + 1]
    jnz [0], fdc_data_write_exec_specify_non_dma

    # Next state is idle
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_specify_non_dma:
    add fdc_error_non_dma, 0, [rb - 1]
    arb -1
    call report_error

fdc_data_write_exec_sense_drive_status:
    # Execute sense drive status
    # TODO

    # Next state is read ST3
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st3, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_seek:
    # Save NCN (next cylinder number)
    add [rb + value], 0, [fdc_cmd_cylinder]

    # Execute seek
    # TODO

    # TODO handle units 2 and 3, they're not ready, see docs what to do then
    # TODO during seek compare PCN with fdc_cmd_cylinder which is the target cylinder

    # TODO interrupt
    # TODO set floppy busy with seek in MSR, it is cleared by sense interrupt
    # TODO clear floppy busy in MSR when sense interrupt
    # TODO during command phase of seek fdc is in busy state (in MSR), during execution it's not

    # Next state is idle
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_invalid:
    # Whatever the command code was, set it to zero
    add 0, 0, [fdc_cmd_code]

    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]

fdc_data_write_done:
    arb 2
    ret 2
.ENDFRAME

##########
fdc_data_read:
.FRAME addr; value, tmp
    arb -2

    out 'D' # TODO remove
    out 'r'
    out '_'

    # Is the FDC processing a command?
    jz  [fdc_cmd_state], fdc_data_read_invalid

    # Yes, is this the result phase?
    jz  [fdc_cmd_result_phase], fdc_data_read_invalid

    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Yes, use the state as a label to jump to
    jz  0, [fdc_cmd_state]

##########
# ST0, ST1, ST2, ST3 states

fdc_data_read_st0:
    # Is this the invalid command?
    jz  [fdc_cmd_code], fdc_data_read_invalid

    # Read ST0
    add [fdc_cmd_st0], 0, [rb + value]

    # Is this the sense interrupt status command?
    eq  [fdc_cmd_code], 0b01000, [rb + tmp]
    jnz [rb + tmp], fdc_data_read_st0_sense_interrupt_status

    # No, default next state is read ST1
    add fdc_data_read_st1, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_st0_sense_interrupt_status:
    # Sense interrupt status command, next state is read PCN
    add fdc_data_read_pcn, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_st1:
    # Read ST1
    add [fdc_cmd_st1], 0, [rb + value]

    # Next state is read ST2
    add fdc_data_read_st2, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_st2:
    # Read ST2
    add [fdc_cmd_st2], 0, [rb + value]

    # Next state is read C
    add fdc_data_read_c, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_st3:
    # Read ST3
    add [fdc_cmd_st3], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

##########
# C, H, R, N states

fdc_data_read_c:
    # Read C (cylinder)
    add [fdc_cmd_cylinder], 0, [rb + value]

    # Next state is read H
    add fdc_data_read_h, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_h:
    # Read H (head)
    add [fdc_cmd_head], 0, [rb + value]

    # Next state is read R
    add fdc_data_read_r, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_r:
    # Read R (record, sector number)
    add [fdc_cmd_sector], 0, [rb + value]

    # Next state is read N
    add fdc_data_read_n, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_n:
    # Read N (number of bytes)
    add [fdc_cmd_bytes], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

##########
# Misc other states

fdc_data_read_pcn:
    # Read PCN (present cylinder number, position of the head)
    # Determine which unit was used by last command from bit 0 of ST0 (US0)
    mul [fdc_cmd_st0], 8, [rb + tmp]
    add bits, [rb + tmp], [ip + 1]
    add [0], fdc_present_cylinder_units, [ip + 1]
    add [0], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_read_done

fdc_data_read_invalid:
    # Invalid command, either unexpected read or unexpected write
    add 0, 0, [fdc_cmd_code]

    # Return 0x80 as ST0 error code
    add 0x80, 0, [fdc_cmd_st0]
    add [fdc_cmd_st0], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]

fdc_data_read_done:
    # TODO remove
    add [rb + value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix
    out ' '

    arb 2
    ret 1
.ENDFRAME

##########
fdc_control_write:
.FRAME addr, value;
    # TODO this is I think used to detect floppy type
    # if yes, we need to return errors (when reading?) unless the speed is set correctly

    out 'C' # TODO remove
    out 'w'
    out '_'
    add [rb + value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    arb -3
    call print_num_radix
    out ' '

    # Bits 7-2 Reserved
    # Bits 2-0 Diskette Data Rate (00 500000, 01 300000, 10 250000, 11 125000)

    ret 2
.ENDFRAME

##########
fdc_dir_read:
.FRAME addr; value
    arb -1

    out 'A' # TODO remove
    out 'r'
    out ' '

    # The only bit related to floppy operation is bit 7 - diskette change
    # We don't support changing the diskette, so return all zeros
    add 0, 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
fdc_d765ac_reset:
.FRAME
    # TODO reset D765AC registers to zero, but don't touch the DOR,
    # also don't touch SRT HUT HLT in Specify command

    # Mark interrupt pending
    add 1, 0, [fdc_interrupt_pending]

    # After reset both units have changed ready status, so sense interrupt status
    # returns ST0 with bits 6 and 7 set
    add 0b11000000, 0, [fdc_cmd_st0]

    # Raise INT 0e = IRQ6 if the FDD is ready, which we assume it always is
    # TODO if the motor is off, is the FDD ready? also, the FDD may not be present
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    out 'R' # TODO remove
    out ' '

    ret 0
.ENDFRAME

##########
fdc_dor_drive_a_select:                 # 0 = drive A selected, 1 = drive B selected
    db  0
fdc_dor_reset:                          # 0 = reset
    db  0
fdc_dor_enable_motor_a:
    db  0
fdc_dor_enable_motor_b:
    db  0

fdc_cmd_state:
    db  0
fdc_cmd_result_phase:
    db  0

fdc_cmd_code:
    db  0

fdc_cmd_multi_track:
    db  0
fdc_cmd_mfm:
    db  0
fdc_cmd_skip_deleted:
    db  0
fdc_cmd_unit_selected:
    db  0

fdc_cmd_cylinder:
    db  0
fdc_cmd_head:
    db  0
fdc_cmd_sector:
    db  0
fdc_cmd_bytes:
    db  0

fdc_cmd_end_of_track:
    db  0
fdc_cmd_gap_length:
    db  0
fdc_cmd_data_length_or_step:
    db  0

fdc_cmd_sectors_per_cylinder:
    db  0
fdc_cmd_data_pattern:
    db  0

fdc_cmd_st0:
    db  0
fdc_cmd_st1:
    db  0
fdc_cmd_st2:
    db  0
fdc_cmd_st3:
    db  0

fdc_present_cylinder_units:
fdc_present_cylinder_unit0:
    db  0
fdc_present_cylinder_unit1:
    db  0

fdc_interrupt_pending:
    db  0

fdc_error_non_dma:
    db  "fdc: Non-DMA operation is not supported", 0



# TODO remove
.EXPORT fdc_dor_write
.EXPORT fdc_dor_write_after_reset
.EXPORT fdc_status_read
.EXPORT fdc_data_write
.EXPORT fdc_data_write_idle
.EXPORT fdc_data_write_idle_table
.EXPORT fdc_data_write_idle_to_hd_us
.EXPORT fdc_data_write_idle_to_srt_hut
.EXPORT fdc_data_write_hd_us
.EXPORT fdc_data_write_hd_us_table
.EXPORT fdc_data_write_hd_us_to_c
.EXPORT fdc_data_write_hd_us_to_format_track_n
.EXPORT fdc_data_write_hd_us_to_exec_seek
.EXPORT fdc_data_write_c
.EXPORT fdc_data_write_h
.EXPORT fdc_data_write_r
.EXPORT fdc_data_write_n
.EXPORT fdc_data_write_eot
.EXPORT fdc_data_write_gpl
.EXPORT fdc_data_write_dtl_stp
.EXPORT fdc_data_write_dtl_stp_table
.EXPORT fdc_data_write_format_track_n
.EXPORT fdc_data_write_format_track_sc
.EXPORT fdc_data_write_format_track_gpl
.EXPORT fdc_data_write_srt_hut
.EXPORT fdc_data_write_exec_read_data
.EXPORT fdc_data_write_exec_read_deleted_data
.EXPORT fdc_data_write_exec_write_data
.EXPORT fdc_data_write_exec_write_deleted_data
.EXPORT fdc_data_write_exec_read_track
.EXPORT fdc_data_write_exec_read_id
.EXPORT fdc_data_write_exec_format_track
.EXPORT fdc_data_write_exec_scan_equal
.EXPORT fdc_data_write_exec_scan_low_or_equal
.EXPORT fdc_data_write_exec_scan_high_or_equal
.EXPORT fdc_data_write_exec_recalibrate
.EXPORT fdc_data_write_exec_sense_interrupt_status
.EXPORT fdc_data_write_exec_specify
.EXPORT fdc_data_write_exec_sense_drive_status
.EXPORT fdc_data_write_exec_seek
.EXPORT fdc_data_write_invalid
.EXPORT fdc_data_write_done
.EXPORT fdc_data_read
.EXPORT fdc_data_read_st0
.EXPORT fdc_data_read_st0_sense_interrupt_status
.EXPORT fdc_data_read_st1
.EXPORT fdc_data_read_st2
.EXPORT fdc_data_read_st3
.EXPORT fdc_data_read_c
.EXPORT fdc_data_read_h
.EXPORT fdc_data_read_r
.EXPORT fdc_data_read_n
.EXPORT fdc_data_read_pcn
.EXPORT fdc_data_read_invalid
.EXPORT fdc_data_read_done
.EXPORT fdc_control_write
.EXPORT fdc_dir_read
.EXPORT fdc_d765ac_reset

.EOF
