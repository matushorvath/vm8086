# From bios.o
.IMPORT bios_address

# From ports.s
.IMPORT init_ports

# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/init_binary.s
.IMPORT init_memory

# From dev/pit_8253.s
.IMPORT init_pit_8253

# From dev/ppi_8255a.s
.IMPORT init_ppi_8255a

# From the BIOS binary
.IMPORT binary_count
.IMPORT binary_header
.IMPORT binary_data

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
    add [binary_count], 0, [rb - 2]
    add binary_header, 0, [rb - 3]
    add binary_data, 0, [rb - 4]
    arb -4
    call init_memory

    call init_pit_8253
    call init_ppi_8255a
    call init_cga
    call init_ports

    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
