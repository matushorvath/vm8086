.EXPORT init_cga

# From devices.s
.IMPORT register_region
.IMPORT register_ports

# From memory.s
.IMPORT write_memory_b8000
.IMPORT read_memory_bc000
.IMPORT write_memory_bc000

# From registers.s
.IMPORT mc6845_address_read
.IMPORT mc6845_address_write
.IMPORT mc6845_data_read
.IMPORT mc6845_data_write
.IMPORT mode_control_write
.IMPORT color_control_write
.IMPORT status_read
.IMPORT reset_screen

##########
cga_ports:
    db  0xd4, 0x03, mc6845_address_read, mc6845_address_write                   # MC6845 address register
    db  0xd5, 0x03, mc6845_data_read, mc6845_data_write                         # MC6845 data register

    db  0xd8, 0x03, 0, mode_control_write                                       # mode control register
    db  0xd9, 0x03, 0, color_control_write                                      # color control register
    db  0xda, 0x03, status_read, 0                                              # status register

    db  -1, -1, -1, -1

##########
init_cga:
.FRAME
    # Register video memory region 0xb8000
    add 0xb8000, 0, [rb - 1]
    add 0xbc000, 0, [rb - 2]
    add 0, 0, [rb - 3]
    add write_memory_b8000, 0, [rb - 4]
    arb -4
    call register_region

    # Same memory is aliased also at 0xbc000
    add 0xbc000, 0, [rb - 1]
    add 0xc0000, 0, [rb - 2]
    add read_memory_bc000, 0, [rb - 3]
    add write_memory_bc000, 0, [rb - 4]
    arb -4
    call register_region

    # Register I/O ports
    add cga_ports, 0, [rb - 1]
    arb -1
    call register_ports

    # Reset the screen
    call reset_screen

    ret 0
.ENDFRAME

.EOF
