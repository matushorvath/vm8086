# From ports.s
.IMPORT init_ports

# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/init_binary.s
.IMPORT init_binary

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
    call init_binary
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
