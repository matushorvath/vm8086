.EXPORT extended_vm

# From callback.s
.IMPORT init_vm_callback

# From headers.s
.IMPORT rom_headers

# From images.s
.IMPORT images

# From menu.s
.IMPORT init_menu

# From vm_ports.s
.IMPORT init_vm_ports

# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/regions.s
.IMPORT register_region

# From dev/dma_8237a.s
.IMPORT init_dma_8237a

# From dev/pic_8259a_ports.s
.IMPORT init_pic_8259a

# From dev/pit_8253.s
.IMPORT init_pit_8253

# From dev/ppi_8255a.s
.IMPORT init_ppi_8255a

# From dev/ps2_8042.s
.IMPORT init_ps2_8042

# From fdc/init.s
.IMPORT init_fdc

# From img/floppy.s
.IMPORT floppy_size

# From img/init.s
.IMPORT init_images

##########
# Entry point
    # magic instruction; extended VM starts at extended_init
    jnz 0, extended_init

    # standard VM starts here
    jz  0, init

extended_init:
    # extended VM starts here; check for required features
    db  110, 10, tmp                    # check for ftr instruction; ftr 10, [res]
    jz  [tmp], init
    db  110, 13, tmp                    # check for ina instruction; ftr 13, [res]
    jz  [tmp], init

    # running on extended VM and all required features are present
    add 1, 0, [extended_vm]

init:
    arb stack

    # Overwrite the first instruction with 'hlt', so in case
    # we ever jump to 0 by mistake, we halt immediately
    add 99, 0, [0]

    call main
    hlt

##########
main:
.FRAME tmp
    arb -1

    call init_vm_callback
    call init_menu

    # Initialize the ROM and floppy images
    add rom_headers, 0, [rb - 1]
    add images, 0, [rb - 2]
    arb -2
    call init_images

    # Make the ROM read-only; to avoid creating multiple regions (which slows down every memory access),
    # we mark all memory between 0xf0000 and 0xfffff as read-only, which is a reasonable approximation
    add 0xf0000, 0, [rb - 1]
    add 0x100000, 0, [rb - 2]
    add 0, 0, [rb - 3]
    add write_rom, 0, [rb - 4]
    arb -4
    call register_region

    # Initialize PPI using correct floppy drive count
    lt  0, [floppy_size + 0], [rb + tmp]
    lt  0, [floppy_size + 1], [rb - 1]
    add [rb - 1], [rb + tmp], [rb - 1]
    arb -1
    call init_ppi_8255a

    # Initialize floppy drives with images 0 (A) and 1 (B)
    add 0, 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call init_fdc

    # Initialize other devices
    call init_pic_8259a
    call init_pit_8253
    call init_ps2_8042
    call init_dma_8237a
    call init_cga
    call init_vm_ports

    # Start the CPU
    call execute

    arb 1
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
extended_vm:
    db  0
tmp:
    db  0

##########
    ds  1000, 0
stack:

.EOF
