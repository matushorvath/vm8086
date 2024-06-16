# From bios.o
.IMPORT bios_count
.IMPORT bios_header
.IMPORT bios_data

# From bios_address.template
.IMPORT bios_address

# From floppy.o
.IMPORT floppy_count
.IMPORT floppy_header
.IMPORT floppy_data

# From ports.s
.IMPORT init_vm_ports

# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/images.s
.IMPORT init_images

# From dev/dma.s
.IMPORT init_dma_8237a

# From dev/fdc.s
.IMPORT init_fdc

# From dev/pit_8253.s
.IMPORT init_pit_8253

# From dev/ppi_8255a.s
.IMPORT init_ppi_8255a

# TODO make the BIOS read-only by registering a NOP write handler

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
    add [bios_address], 0, [rb - 1]
    add [bios_count], 0, [rb - 2]
    add bios_header, 0, [rb - 3]
    add bios_data, 0, [rb - 4]
    add [floppy_count], 0, [rb - 5]
    add floppy_header, 0, [rb - 6]
    add floppy_data, 0, [rb - 7]
    arb -7
    call init_images

    call init_pit_8253
    call init_ppi_8255a
    call init_dma_8237a
    call init_cga
    call init_fdc
    call init_vm_ports

    call execute

    ret 0
.ENDFRAME

##########
    ds  1000, 0
stack:

.EOF
