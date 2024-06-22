# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/images.s
.IMPORT init_rom_image

# From shutdown.s
.IMPORT init_shutdown_port

# From test_cga.o
.IMPORT cga_test_image

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
    add 0xf0000, 0, [rb - 1]
    add cga_test_image, 0, [rb - 2]
    arb -2
    call init_rom_image

    call init_cga
    call init_shutdown_port

    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
