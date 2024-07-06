.EXPORT fdc_activity_callback

# From bios.o
.IMPORT bios_image

# From bios_address.template
.IMPORT bios_address

# From floppy.o
.IMPORT floppy_image

# From ports.s
.IMPORT init_vm_ports

# From cga/cga.s
.IMPORT init_cga

# From cpu/devices.s
.IMPORT register_region

# From cpu/execute.s
.IMPORT execute

# From cpu/images.s
.IMPORT init_images

# From cga/status_bar.s
.IMPORT set_disk_active

# From dev/dma.s
.IMPORT init_dma_8237a

# From dev/fdc.s
.IMPORT init_fdc

# From dev/pic_8259a.s
.IMPORT init_pic_8259a

# From dev/pit_8253.s
.IMPORT init_pit_8253

# From dev/ppi_8255a.s
.IMPORT init_ppi_8255a

##########
# Entry point
    arb stack

    # Overwrite the first instruction with 'hlt', so in case
    # we ever jump to 0 by mistake, we halt immediately
    add 99, 0, [0]

    call main
    hlt

##########
main:
.FRAME
    # Initialize the ROM and floppy images
    add [bios_address], 0, [rb - 1]
    add bios_image, 0, [rb - 2]
    add 1474560, 0, [rb - 3]
    add floppy_image, 0, [rb - 4]
    arb -4
    call init_images

    # Make the ROM read-only
    add [bios_address], 0, [rb - 1]
    add 0x100000, 0, [rb - 2]
    add 0, 0, [rb - 3]
    add write_rom, 0, [rb - 4]
    arb -4
    call register_region

    # Initialize devices
    call init_pic_8259a
    call init_pit_8253
    call init_ppi_8255a
    call init_dma_8237a
    call init_cga
    call init_fdc
    call init_vm_ports

    # Start the CPU
    call execute

    ret 0
.ENDFRAME

##########
write_rom:
.FRAME addr, value; write_through
    arb -1

    # Silently throw away the data, the ROM is read only
    add 0, 0, [rb + write_through]

    arb 1
    ret 2
.ENDFRAME

##########
fdc_activity_callback:
.FRAME unit, active;
    add [rb + active], 0, [rb - 1]
    arb -1
    call set_disk_active

    ret 2
.ENDFRAME

##########
    ds  1000, 0
stack:

.EOF
