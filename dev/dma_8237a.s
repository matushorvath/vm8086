.EXPORT init_dma_8237a

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
# TODO .IMPORT report_error

# From util/bits.s
.IMPORT bits

##########
dma_ports:
    db  0x02, 0x00, 0, dma_start_address_ch1_write          # start address register channel 1
    db  0x03, 0x00, 0, dma_count_ch1_write                  # count register channel 1
    db  0x04, 0x00, 0, dma_start_address_ch2_write          # start address register channel 2
    db  0x05, 0x00, 0, dma_count_ch2_write                  # count register channel 2
    db  0x06, 0x00, 0, dma_start_address_ch3_write          # start address register channel 3
    db  0x07, 0x00, 0, dma_count_ch3_write                  # count register channel 3

    db  0x08, 0x00, dma_status_read, dma_command_write      # status register, command register
    db  0x0a, 0x00, 0, dma_single_channel_mask_write        # single channel mask register
    db  0x0b, 0x00, 0, dma_mode_write                       # mode register
    db  0x0c, 0x00, 0, dma_flip_flop_reset_write            # flip-flop reset register
    db  0x0d, 0x00, 0, dma_master_reset_write               # master reset register
    db  0x0e, 0x00, 0, dma_mask_reset_write                 # mask reset register
    db  0x0f, 0x00, 0, dma_multi_channel_mask_write         # multichannel mask register

    db  0x81, 0x00, dma_page_ch2_read, dma_page_ch2_write   # channel 2 page address register
    db  0x82, 0x00, dma_page_ch3_read, dma_page_ch3_write   # channel 3 page address register
    db  0x83, 0x00, dma_page_ch1_read, dma_page_ch1_write   # channel 1 page address register

    db  -1, -1, -1, -1

# Following ports are not required:
#  - 0x00 start adddress register channel 0
#  - 0x01 count register channel 0
#  - 0x09 request register
#  - 0x0d intermediate register (read)
#  - 0x87 channel 0 page address register

##########
init_dma_8237a:
.FRAME
    # Register I/O ports
    add dma_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
dma_mode_write:
.FRAME addr, value; value_x8, channel, transfer_type, dma_mode, tmp
    arb -5

    # Set DMA mode
    mul [rb + value], 8, [rb + value_x8]

    # Read channel number from bits 0 and 1
    add bits + 1, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read transfer type from bits 2 and 3
    add bits + 3, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + transfer_type]
    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], [rb + transfer_type], [rb + transfer_type]

    # Transfer type 0b11 is invalid
    eq  [rb + transfer_type], 0b11, [rb + tmp]
    jnz [rb + tmp], dma_mode_write_done

    # Read DMA mode from bits 6 and 7
    add bits + 7, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + dma_mode]
    add bits + 6, [rb + value_x8], [ip + 1]
    add [0], [rb + dma_mode], [rb + dma_mode]

    # DMA mode 0b11 (cascade) is invalid
    eq  [rb + dma_mode], 0b11, [rb + tmp]
    jnz [rb + tmp], dma_mode_write_done

    # Save transfer type
    add dma_transfer_type_channels, [rb + channel], [ip + 3]
    add [rb + transfer_type], 0, [0]

    # Save DMA mode
    add dma_mode_channels, [rb + channel], [ip + 3]
    add [rb + dma_mode], 0, [0]

    # Read and save auto init mode
    add bits + 4, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_auto_init_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

    # Read and save decrement mode
    add bits + 5, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_decrement_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

dma_mode_write_done:
    arb 5
    ret 2
.ENDFRAME

##########
dma_command_write:
.FRAME addr, value; value_x8
    arb -1

    # Only bit 3 is useful, it disables the DMA controller
    mul [rb + value], 8, [rb + value_x8]
    add bits + 3, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_disable_controller]

    arb 1
    ret 2
.ENDFRAME

##########
dma_status_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_master_reset_write:
.FRAME addr, value;
    # Set the flip-flop to access the low byte
    add 0, 0, [dma_flip_flop]

    # TODO clear status

    # Set all channel masks to 1
    add 1, 0, [dma_mask_ch0]
    add 1, 0, [dma_mask_ch1]
    add 1, 0, [dma_mask_ch2]
    add 1, 0, [dma_mask_ch3]

    ret 2
.ENDFRAME

##########
dma_flip_flop_reset_write:
.FRAME addr, value;
    # Set the flip-flop to access the low byte
    add 0, 0, [dma_flip_flop]
    ret 2
.ENDFRAME

##########
dma_single_channel_mask_write:
.FRAME addr, value; value_x8, channel, mask
    arb -3

    # Mask a single channel
    mul [rb + value], 8, [rb + value_x8]

    # Read channel number from bits 0 and 1
    add bits + 1, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read mask/unmask value from bit 2
    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + mask]

    # Mask/unmask the channel
    add dma_mask_channels, [rb + channel], [ip + 3]
    add [rb + mask], 0, [0]

    arb 3
    ret 2
.ENDFRAME

##########
dma_multi_channel_mask_write:
.FRAME addr, value; value_x8
    arb -1

    # Mask a all channels
    mul [rb + value], 8, [rb + value_x8]

    # Set mask for individual channels
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch0]

    add bits + 1, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch1]

    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch2]

    add bits + 3, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch3]

    arb 1
    ret 2
.ENDFRAME

##########
dma_mask_reset_write:
.FRAME addr, value;
    # Reset all channel masks to 0
    add 0, 0, [dma_mask_ch0]
    add 0, 0, [dma_mask_ch1]
    add 0, 0, [dma_mask_ch2]
    add 0, 0, [dma_mask_ch3]

    ret 2
.ENDFRAME

##########
dma_start_address_ch1_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_start_address_ch2_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_start_address_ch3_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_count_ch1_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_count_ch2_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_count_ch3_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_page_ch1_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch1], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch2_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch2], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch3_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch3], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch1_write:
.FRAME addr, value;
    add [rb + value], 0, [dma_page_ch1]
    ret 2
.ENDFRAME

##########
dma_page_ch2_write:
.FRAME addr, value;
    add [rb + value], 0, [dma_page_ch2]
    ret 2
.ENDFRAME

##########
dma_page_ch3_write:
.FRAME addr, value;
    add [rb + value], 0, [dma_page_ch3]
    ret 2
.ENDFRAME

##########
dma_disable_controller:
    db  0

dma_flip_flop:
    db  0

dma_mask_channels:
dma_mask_ch0:
    db  1
dma_mask_ch1:
    db  1
dma_mask_ch2:
    db  1
dma_mask_ch3:
    db  1

dma_transfer_type_channels:
dma_transfer_type_ch0:
    db  0
dma_transfer_type_ch1:
    db  0
dma_transfer_type_ch2:
    db  0
dma_transfer_type_ch3:
    db  0

dma_mode_channels:
dma_mode_ch0:
    db  0
dma_mode_ch1:
    db  0
dma_mode_ch2:
    db  0
dma_mode_ch3:
    db  0

dma_auto_init_channels:
dma_auto_init_ch0:
    db  0
dma_auto_init_ch1:
    db  0
dma_auto_init_ch2:
    db  0
dma_auto_init_ch3:
    db  0

dma_decrement_channels:
dma_decrement_ch0:
    db  0
dma_decrement_ch1:
    db  0
dma_decrement_ch2:
    db  0
dma_decrement_ch3:
    db  0

dma_page_ch1:
    db  0
dma_page_ch2:
    db  0
dma_page_ch3:
    db  0

.EOF
