.EXPORT pit_data_read_ch1
.EXPORT pit_data_write_ch1
.EXPORT pit_mode_command_write_ch1

# From the config file
.IMPORT config_log_pit

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num_16_b

# Channel 1 is only active if config_dram_refresh flag is set to 1

##########
pit_data_read_ch1:
.FRAME addr; value, tmp                 # returns value
    arb -2

    # Return last data that was read or written minus 1
    #
    # This makes IBM BIOS think the counter is moving, so it continues booting
    # (it wants to see the counter move from 00h to ffh and then again from ffh to a different value)

    add [pit_ch1_last_data], -1, [pit_ch1_last_data]

    lt  [pit_ch1_last_data], 0, [rb + tmp]
    jz  [rb + tmp], .after_borrow

    add [pit_ch1_last_data], 0x100, [pit_ch1_last_data]

.after_borrow:
    add [pit_ch1_last_data], 0, [rb + value]

    # Timer logging
    jz  [config_log_pit], .done

    call log_start

    add .log_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10

.done:
    arb 2
    ret 1

.log_msg:
    db  "pit data read: ch1, value 0x", 0
.ENDFRAME

##########
pit_data_write_ch1:
.FRAME addr, value;
    # Save data that was written
    add [rb + value], 0, [pit_ch1_last_data]

    # Timer logging
    jz  [config_log_pit], .done

    call log_start

    add .log_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10

.done:
    ret 2

.log_msg:
    db  "pit data write: ch1, value 0x", 0
.ENDFRAME

##########
pit_mode_command_write_ch1:
.FRAME data;
    # Writes to channel 1 are silently ignored
    ret 1
.ENDFRAME

##########
pit_ch1_last_data:
    db  0

.EOF
