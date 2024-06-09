.EXPORT init_dma_8237a

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
# TODO .IMPORT report_error

##########
dma_ports:
    db  0x02, 0x00, 0, dma_start_address_ch1_write          # start address register channel 1
    db  0x03, 0x00, 0, dma_count_ch1_write                  # count register channel 1
    db  0x04, 0x00, 0, dma_start_address_ch2_write          # start address register channel 2
    db  0x05, 0x00, 0, dma_count_ch2_write                  # count register channel 2
    db  0x06, 0x00, 0, dma_start_address_ch3_write          # start address register channel 3
    db  0x07, 0x00, 0, dma_count_ch3_write                  # count register channel 3

    db  0x08, 0x00, dma_status_read, 0                      # status register
    db  0x08, 0x00, 0, dma_command_write                    # command register
    db  0x09, 0x00, 0, dma_request_write                    # request register
    db  0x0a, 0x00, 0, dma_single_channel_mask_write        # single channel mask register
    db  0x0b, 0x00, 0, dma_mode_write                       # mode register
    db  0x0c, 0x00, 0, dma_flip_flop_reset_write            # flip-flop reset register
    db  0x0d, 0x00, dma_intermediate_read, 0                # intermediate register
    db  0x0d, 0x00, 0, dma_master_reset_write               # master reset register
    db  0x0e, 0x00, 0, dma_mask_reset_write                 # mask reset register
    db  0x0f, 0x00, 0, dma_multi_channel_mask_write         # multichannel mask register

    db  0x81, 0x00, dma_page_ch2_read, dma_page_ch2_write   # channel 2 page address register
    db  0x82, 0x00, dma_page_ch3_read, dma_page_ch3_write   # channel 3 page address register
    db  0x83, 0x00, dma_page_ch1_read, dma_page_ch1_write   # channel 1 page address register

    db  -1, -1, -1, -1

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
dma_status_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_command_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_request_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_single_channel_mask_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_mode_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_flip_flop_reset_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_intermediate_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_master_reset_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_mask_reset_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_multi_channel_mask_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_page_ch1_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch2_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch3_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch1_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_page_ch2_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

##########
dma_page_ch3_write:
.FRAME addr, value;
    # TODO
    ret 2
.ENDFRAME

.EOF
