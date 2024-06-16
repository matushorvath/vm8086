.EXPORT fdc_data_write
.EXPORT fdc_data_read

.EXPORT fdc_cmd_state
.EXPORT fdc_cmd_result_phase

.EXPORT fdc_cmd_multi_track
.EXPORT fdc_cmd_unit_selected

.EXPORT fdc_cmd_cylinder
.EXPORT fdc_cmd_head
.EXPORT fdc_cmd_sector

.EXPORT fdc_cmd_hlt_nd

.EXPORT fdc_cmd_st0
.EXPORT fdc_cmd_st1
.EXPORT fdc_cmd_st2
.EXPORT fdc_cmd_st3

# From the config file
.IMPORT config_log_fdc

# From fdc_commands.s
.IMPORT fdc_exec_read_data
.IMPORT fdc_exec_read_deleted_data
.IMPORT fdc_exec_write_data
.IMPORT fdc_exec_write_deleted_data

.IMPORT fdc_exec_read_track
.IMPORT fdc_exec_read_id
.IMPORT fdc_exec_format_track

.IMPORT fdc_exec_scan_equal
.IMPORT fdc_exec_scan_low_or_equal
.IMPORT fdc_exec_scan_high_or_equal

.IMPORT fdc_exec_recalibrate
.IMPORT fdc_exec_specify
.IMPORT fdc_exec_sense_drive_status
.IMPORT fdc_exec_seek

# From fdc_control.s
.IMPORT fdc_interrupt_pending

# From fdc_drives.s
.IMPORT fdc_present_cylinder_units

# From util/bits.s
.IMPORT bits

# From util/nibbles.s
.IMPORT nibbles

# From libxib.a
.IMPORT print_str
.IMPORT print_num_2_b
.IMPORT print_num_16_b

##########
fdc_data_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    # Floppy logging
    jz  [config_log_fdc], fdc_data_write_after_log_fdc

    add [rb + value], 0, [rb - 1]
    arb -1
    call fdc_data_write_log_fdc

fdc_data_write_after_log_fdc:
    # Is the FDC processing a command?
    jz  [fdc_cmd_state], fsm_w_idle

    # Yes, is this the command phase?
    jnz [fdc_cmd_result_phase], fsm_w_invalid

    # Yes, use the state as a label to jump to
    jz  0, [fdc_cmd_state]

##########
# Idle state

fsm_w_idle:
    # Parse the first byte of a new command
    # MT MF SK CMD_CODE(5)
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Save MT, ignore SK since there are no deleted records
    add [rb + value_bits], 7, [ip + 1]
    add [0], 0, [fdc_cmd_multi_track]

    # Read bottom 5 bits as the command code
    add [rb + value_bits], 4, [ip + 1]
    mul [0], 0b00010000, [fdc_cmd_code]

    mul [rb + value], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], [fdc_cmd_code], [fdc_cmd_code]

    # We are now in command phase
    add 0, 0, [fdc_cmd_result_phase]

    # Handle the state transition
    add fsm_w_idle_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fsm_w_idle_table:
    db  fsm_w_invalid                                       #          00000
    db  fsm_w_invalid                                       #          00001
    db  fsm_w_idle_to_hd_us_with_mf_check                   #  0 MF SK 00010: read_track
    db  fsm_w_idle_to_srt_hut                               #  0  0  0 00011: specify
    db  fsm_w_idle_to_hd_us                                 #  0  0  0 00100: sense_drive_status
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF  0 00101: write_data
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF SK 00110: read_data
    db  fsm_w_idle_to_hd_us                                 #  0  0  0 00111: recalibrate
    db  fsm_w_idle_to_exec_sense_interrupt_status           #  0  0  0 01000: sense_interrupt_status
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF  0 01001: write_deleted_data
    db  fsm_w_idle_to_hd_us_with_mf_check                   #  0 MF  0 01010: read_id
    db  fsm_w_invalid                                       #          01011
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF SK 01100: read_deleted_data
    db  fsm_w_idle_to_hd_us_with_mf_check                   #  0 MF  0 01101: format_track
    db  fsm_w_invalid                                       #          01110
    db  fsm_w_idle_to_hd_us                                 #  0  0  0 01111: seek
    db  fsm_w_invalid                                       #          10000
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF SK 10001: scan_equal
    db  fsm_w_invalid                                       #          10010
    db  fsm_w_invalid                                       #          10011
    db  fsm_w_invalid                                       #          10100
    db  fsm_w_invalid                                       #          10101
    db  fsm_w_invalid                                       #          10110
    db  fsm_w_invalid                                       #          10111
    db  fsm_w_invalid                                       #          11000
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF SK 11001: scan_low_or_equal
    db  fsm_w_invalid                                       #          11010
    db  fsm_w_invalid                                       #          11011
    db  fsm_w_invalid                                       #          11100
    db  fsm_w_idle_to_hd_us_with_mf_check                   # MT MF SK 11101: scan_high_or_equal
    db  fsm_w_invalid                                       #          11110
    db  fsm_w_invalid                                       #          11111

fsm_w_idle_to_hd_us_with_mf_check:
    # Require MF=1 since we don't support 8" floppies
    add [rb + value_bits], 6, [ip + 1]
    jz  [0], fsm_w_invalid

    # fall through

fsm_w_idle_to_hd_us:
    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is write HD US
    add fsm_w_hd_us, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_idle_to_srt_hut:
    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is write SRT HUT
    add fsm_w_srt_hut, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_idle_to_exec_sense_interrupt_status:
    # Sense interrupt status is an invalid command if interrupt is not pending
    jz  [fdc_interrupt_pending], fsm_w_invalid

    # ST0 bits 0, 5, 6, 7 as well as PCN are set up by a previous seek or recalibrate command
    # If another command was executed, it also should set ST0 accordingly, so there is nothing to do

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st0, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

##########
# HD US state

fsm_w_hd_us:
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
    add fsm_w_hd_us_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fsm_w_hd_us_table:
    ds  2, 0                                                # 00000, 00001
    db  fsm_w_hd_us_to_c                                    # 00010: read_track
    db  0                                                   # 00011: specify
    db  fsm_w_hd_us_to_exec_sense_drive_status              # 00100: sense_drive_status
    db  fsm_w_hd_us_to_c                                    # 00101: write_data
    db  fsm_w_hd_us_to_c                                    # 00110: read_data
    db  fsm_w_hd_us_to_exec_recalibrate                     # 00111: recalibrate
    db  0                                                   # 01000: sense_interrupt_status
    db  fsm_w_hd_us_to_c                                    # 01001: write_deleted_data
    db  fsm_w_hd_us_to_exec_read_id                         # 01010: read_id
    db  0                                                   # 01011
    db  fsm_w_hd_us_to_c                                    # 01100: read_deleted_data
    db  fsm_w_hd_us_to_format_track_n                       # 01101: format_track
    db  0                                                   # 01110
    db  fsm_w_hd_us_to_ncn                                  # 01111: seek
    db  0                                                   # 10000
    db  fsm_w_hd_us_to_c                                    # 10001: scan_equal
    ds  7, 0                                                # 10010-11000
    db  fsm_w_hd_us_to_c                                    # 11001: scan_low_or_equal
    ds  3, 0                                                # 11010-11100
    db  fsm_w_hd_us_to_c                                    # 11101: scan_high_or_equal
    ds  2, 0                                                # 11110, 11111

fsm_w_hd_us_to_c:
    # Next state is write C
    add fsm_w_c, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_hd_us_to_exec_sense_drive_status:
    # Next state is read ST3
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st3, 0, [fdc_cmd_state]

    # Execute sense drive status
    call fdc_exec_sense_drive_status
    jz  0, fsm_w_done

fsm_w_hd_us_to_exec_recalibrate:
    # Next state is idle
    add 0, 0, [fdc_cmd_state]

    # Execute recalibrate
    call fdc_exec_recalibrate
    jz  0, fsm_w_done

fsm_w_hd_us_to_exec_read_id:
    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st0, 0, [fdc_cmd_state]

    # Execute read id
    call fdc_exec_read_id
    jz  0, fsm_w_done

fsm_w_hd_us_to_format_track_n:
    # Next state is write N (for format track)
    add fsm_w_format_track_n, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_hd_us_to_ncn:
    # Next state is write NCN
    add fsm_w_ncn, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

##########
# C, H, R, N states

fsm_w_c:
    # Save C (cylinder)
    add [rb + value], 0, [fdc_cmd_cylinder]

    # Next state is write H
    add fsm_w_h, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_h:
    # Head number from the first byte must be equal to the head number here
    eq  [fdc_cmd_head], [rb + value], [rb + tmp]
    jz  [rb + tmp], fsm_w_invalid

    # Next state is write R
    add fsm_w_r, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

    jz  0, fsm_w_done

fsm_w_r:
    # Save R (record, sector number)
    add [rb + value], 0, [fdc_cmd_sector]

    # Next state is write N
    add fsm_w_n, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_n:
    # Number of bytes per sector must be 512 (N=0x02)
    # TODO docs say when N=0, DTL is used to determine byte count
    eq  [rb + value], 0x02, [rb + tmp]
    jz  [rb + tmp], fsm_w_invalid

    # Next state is write EOT (outside of format track command)
    add fsm_w_eot, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

##########
# EOT and GPL states

fsm_w_eot:
    # Save EOT (end of track, final sector number on a cylinder)
    # TODO how is this used, do we need to save it?
    add [rb + value], 0, [fdc_cmd_end_of_track]

    # Next state is write GPL
    add fsm_w_gpl, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_gpl:
    # Save GPL (gap 3 length, spacing between sectors)
    # TODO how is this used, do we need to save it? maybe just verify it is correct for this floppy type?
    add [rb + value], 0, [fdc_cmd_gap_length]

    # Next state is write DTL/STP (outside of format track command)
    add fsm_w_dtl_stp, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

##########
# DTL/STP state

fsm_w_dtl_stp:
    # Save DTL or STP, they share the same variable
    # DTL (data length, if N is 0, DTL is the length to read/write to a sector)
    # STP (1=compare contiguous sectors, 2=compare alternate sectors)
    add [rb + value], 0, [fdc_cmd_data_length_or_step]

    # Next state is always read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st0, 0, [fdc_cmd_state]

    # Execute the command
    add fsm_w_dtl_stp_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fsm_w_dtl_stp_table:
    ds  2, 0                                                # 00000, 00001
    db  fsm_w_dtl_stp_to_exec_read_track                    # 00010: read_track
    ds  2, 0                                                # 00011, 00100: specify, sense_drive_status
    db  fsm_w_dtl_stp_to_exec_write_data                    # 00101: write_data
    db  fsm_w_dtl_stp_to_exec_read_data                     # 00110: read_data
    ds  2, 0                                                # 00111, 01000: recalibrate, sense_interrupt_status
    db  fsm_w_dtl_stp_to_exec_write_deleted_data            # 01001: write_deleted_data
    ds  2, 0                                                # 01010, 01011: read_id
    db  fsm_w_dtl_stp_to_exec_read_deleted_data             # 01100: read_deleted_data
    ds  4, 0                                                # 01101-10000: format_track, seek
    db  fsm_w_dtl_stp_to_exec_scan_equal                    # 10001: scan_equal
    ds  7, 0                                                # 10010-11000
    db  fsm_w_dtl_stp_to_exec_scan_low_or_equal             # 11001: scan_low_or_equal
    ds  3, 0                                                # 11010-11100
    db  fsm_w_dtl_stp_to_exec_scan_high_or_equal            # 11101: scan_high_or_equal
    ds  2, 0                                                # 11110, 11111

fsm_w_dtl_stp_to_exec_read_track:
    # Execute read track
    call fdc_exec_read_track
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_write_data:
    # Execute write data
    call fdc_exec_write_data
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_read_data:
    # Execute read data
    call fdc_exec_read_data
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_write_deleted_data:
    # Execute write deleted data
    call fdc_exec_write_deleted_data
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_read_deleted_data:
    # Execute read deleted data
    call fdc_exec_read_deleted_data
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_scan_equal:
    # Execute scan equal
    call fdc_exec_scan_equal
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_scan_low_or_equal:
    # Execute scan low or equal
    call fdc_exec_scan_low_or_equal
    jz  0, fsm_w_done

fsm_w_dtl_stp_to_exec_scan_high_or_equal:
    # Execute scan high or equal
    call fdc_exec_scan_high_or_equal
    jz  0, fsm_w_done

##########
# Format track states: N, SC, GPL, D

fsm_w_format_track_n:
    # Number of bytes per sector must be 512 (N=0x02)
    eq  [rb + value], 0x02, [rb + tmp]
    jz  [rb + tmp], fsm_w_invalid

    # Format track command, next state is write SC
    add fsm_w_format_track_sc, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_format_track_sc:
    # Save SC (number of sectors per cylinder)
    add [rb + value], 0, [fdc_cmd_sectors_per_cylinder]

    # Next state is write GPL
    add fsm_w_format_track_gpl, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_format_track_gpl:
    # Save GPL (gap 3 length, spacing between sectors)
    # TODO how is this used, do we need to save it? maybe just verify it is correct for this floppy type?
    add [rb + value], 0, [fdc_cmd_gap_length]

    # Format track command, next state is write D
    add fsm_w_format_track_d, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_format_track_d:
    # Save D (data pattern to be written to a sector)
    add [rb + value], 0, [fdc_cmd_data_pattern]

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st0, 0, [fdc_cmd_state]

    # Execute format track
    call fdc_exec_format_track
    jz  0, fsm_w_done

##########
# Specify states: SRT/HUT, HLT/ND

fsm_w_srt_hut:
    # Next state is write HLT ND
    add fsm_w_hlt_nd, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

fsm_w_hlt_nd:
    # Save the HLT ND byte
    add [rb + value], 0, [fdc_cmd_hlt_nd]

    # Next state is idle
    add 0, 0, [fdc_cmd_state]

    # Execute specify
    call fdc_exec_specify
    jz  0, fsm_w_done

##########
# Seek state: NCN

fsm_w_ncn:
    # Save NCN (next cylinder number)
    add [rb + value], 0, [fdc_cmd_cylinder]

    # Execute seek
    call fdc_exec_seek

    # Next state is idle
    add 0, 0, [fdc_cmd_state]
    jz  0, fsm_w_done

##########
# Invalid state

fsm_w_invalid:
    # Whatever the command code was, set it to zero
    add 0, 0, [fdc_cmd_code]

    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fsm_r_st0, 0, [fdc_cmd_state]

fsm_w_done:
    arb 2
    ret 2
.ENDFRAME

##########
fdc_data_write_log_fdc:
.FRAME value;

    jnz [fdc_cmd_state], fdc_data_write_log_fdc_have_command

    add fdc_data_write_log_fdc_new_command, 0, [rb - 1]
    arb -1
    call print_str

    out 10

fdc_data_write_log_fdc_have_command:
    add fdc_data_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    add fdc_data_write_log_fdc_hex, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b
    out ')'

    out 10
    ret 1

fdc_data_write_log_fdc_new_command:
    db  "===== fdc state machine, new command started", 0
fdc_data_write_log_fdc_start:
    db  "fdc data write, value ", 0
fdc_data_write_log_fdc_hex:
    db  " (0x", 0
.ENDFRAME

##########
fdc_data_read:
.FRAME addr; value, tmp
    arb -2

    # Is the FDC processing a command?
    jz  [fdc_cmd_state], fsm_r_invalid

    # Yes, is this the result phase?
    jz  [fdc_cmd_result_phase], fsm_r_invalid

    # Any interrupt is cleared
    add 0, 0, [fdc_interrupt_pending]

    # Yes, use the state as a label to jump to
    jz  0, [fdc_cmd_state]

##########
# ST0, ST1, ST2, ST3 states

fsm_r_st0:
    # Is this the invalid command?
    jz  [fdc_cmd_code], fsm_r_invalid

    # Read ST0
    add [fdc_cmd_st0], 0, [rb + value]

    # Is this the sense interrupt status command?
    eq  [fdc_cmd_code], 0b01000, [rb + tmp]
    jnz [rb + tmp], fsm_r_st0_sense_interrupt_status

    # No, default next state is read ST1
    add fsm_r_st1, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_st0_sense_interrupt_status:
    # Sense interrupt status command, next state is read PCN
    add fsm_r_pcn, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_st1:
    # Read ST1
    add [fdc_cmd_st1], 0, [rb + value]

    # Next state is read ST2
    add fsm_r_st2, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_st2:
    # Read ST2
    add [fdc_cmd_st2], 0, [rb + value]

    # Next state is read C
    add fsm_r_c, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_st3:
    # Read ST3
    add [fdc_cmd_st3], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

##########
# C, H, R, N states

fsm_r_c:
    # Read C (cylinder)
    add [fdc_cmd_cylinder], 0, [rb + value]

    # Next state is read H
    add fsm_r_h, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_h:
    # Read H (head)
    add [fdc_cmd_head], 0, [rb + value]

    # Next state is read R
    add fsm_r_r, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_r:
    # Read R (record, sector number)
    add [fdc_cmd_sector], 0, [rb + value]

    # Next state is read N
    add fsm_r_n, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_n:
    # Read N (number of bytes per sector), fixed to 512 (N=0x02)
    add 0x02, 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

##########
# Misc other states

fsm_r_pcn:
    # Read PCN (present cylinder number, position of the head)
    # Determine which unit was used by last command from bit 0 of ST0 (US0)
    mul [fdc_cmd_st0], 8, [rb + tmp]
    add bits, [rb + tmp], [ip + 1]
    add [0], fdc_present_cylinder_units, [ip + 1]
    add [0], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]
    jz  0, fsm_r_done

fsm_r_invalid:
    # Invalid command, either unexpected read or unexpected write
    add 0, 0, [fdc_cmd_code]

    # Return 0x80 as ST0 error code
    add 0x80, 0, [fdc_cmd_st0]
    add [fdc_cmd_st0], 0, [rb + value]

    # Next state is idle
    add 0, 0, [fdc_cmd_result_phase]
    add 0, 0, [fdc_cmd_state]

fsm_r_done:
    # Floppy logging
    jz  [config_log_fdc], fdc_data_read_after_log_fdc

    add [rb + value], 0, [rb - 1]
    arb -1
    call fdc_data_read_log_fdc

fdc_data_read_after_log_fdc:
    arb 2
    ret 1
.ENDFRAME

##########
fdc_data_read_log_fdc:
.FRAME value;
    add fdc_data_read_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    add fdc_data_read_log_fdc_hex, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b
    out ')'

    out 10
    ret 1

fdc_data_read_log_fdc_start:
    db  "fdc data read, value ", 0
fdc_data_read_log_fdc_hex:
    db  " (0x", 0
.ENDFRAME

##########
fdc_cmd_state:
    db  0
fdc_cmd_result_phase:
    db  0

fdc_cmd_code:
    db  0

fdc_cmd_multi_track:
    db  0
fdc_cmd_unit_selected:
    db  0

fdc_cmd_cylinder:
    db  0
fdc_cmd_head:
    db  0
fdc_cmd_sector:
    db  0

fdc_cmd_end_of_track:
    db  0
fdc_cmd_gap_length:
    db  0
fdc_cmd_data_length_or_step:
    db  0

fdc_cmd_hlt_nd:
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

.EOF
