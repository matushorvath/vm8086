# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/init_binary.s
.IMPORT init_binary

# From shutdown.s
.IMPORT init_shutdown_port

# From test_cga.o
.IMPORT cga_test_count
.IMPORT cga_test_header
.IMPORT cga_test_data

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
    add [cga_test_count], 0, [rb - 1]
    add cga_test_header, 0, [rb - 2]
    add cga_test_data, 0, [rb - 3]
    arb -3
    call init_binary

    call init_cga
    call init_shutdown_port

    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
