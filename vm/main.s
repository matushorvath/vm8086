# From cga.s
.IMPORT init_cga

# From devices.s
.IMPORT init_ports

# From exec.s
.IMPORT execute

# From init_binary.s
.IMPORT init_binary

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
    call init_cga
    call init_ports

    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF

# TODO

PIT pit_ctl_reg
nmi_mask_reg
ppi_cwd_reg
DMAC (8237) dmac_ch0_count_reg
PIC (8259) pic1_reg0
keyboard controller (8242) ppi_pb_reg; also read ppi_pb_reg
