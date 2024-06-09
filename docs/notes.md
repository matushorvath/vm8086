Notes
=====

Run without interpreting ANSI escape sequences:
make && ~/intcode/xzintbit/vms/c/ic bin/vm.bios-xt.input | tr '\33' '\n'

Decoding
========

Instruction set 2-51 p70  
Instruction encoding 4-22 p259  

Possible Optimizations
======================

- Use macros for inc_ip_b, inc_ip_w, inc_sp_w, dec_sp_w, execute_inc, execute_dec, read_b, write_b. The same algorithm is in many places.
- Use macros for all the arg_* functions, there's a lot of copy pasta there.
- Look at the most used path in decode_mod_rm, make sure it is fast.

- Use a second level table for decoding the group instructions
  e.g. exec_fn, args_fn, N           means call it directly
       second_level_table, -1, -1   means split away the MOD, go through a second level table
  The second level table would allow its own args_fn to handle instructions with strange parameter count

- Optimize physical address calculation (calc_seg_off_addr_*), it's very heavy and used a lot. It's mostly heavy to handle corner cases (integer overflows).

TODO
====

- Make sure makefiles display and delete output files when compilation fails.
- All generated tables should be changed to avoid multiplying the input number by N

VM:
- nmi_mask_reg
- ppi_cwd_reg
- DMAC (8237) dmac_ch0_count_reg
- PIC (8259) pic1_reg0
- keyboard controller (8242) ppi_pb_reg; also read ppi_pb_reg

Emulators
=========

https://i8086emu.sourceforge.net/
https://github.com/YJDoc2/8086-Emulator/
https://github.com/adriancable/8086tiny
https://bochs.sourceforge.io/
https://github.com/86Box/86Box

Tests for 8086
==============

https://github.com/SingleStepTests/8088  
https://github.com/TomHarte/ProcessorTests  
https://github.com/barotto/test386.asm  
https://github.com/xoreaxeaxeax/sandsifter  
https://www.pcjs.org/software/pcx86/test/cpu/  

DAA behavior with AF=1
https://draft.blogger.com/comment.g?blogID=6264947694886887540&postID=1529067761550380331&bpli=1&pli=1
https://github.com/shirriff/DAA

BIOS
====

https://github.com/skiselev/8088_bios.git
make -C vm clean
BIOS_LOAD_ADDRESS=fc000 BIOS_BIN=~/intcode/8088_bios/binaries/bios-xt.bin make && ~/intcode/xzintbit/vms/c/ic bin/vm.input

listing:
set(CMAKE_ASM_NASM_FLAGS "-O9 -l $(basename $@).lst")
./build/CMakeFiles/bios-xt.bin.dir/src/bios.asm.lst

https://glabios.org/
BIOS_BIN=~/intcode/GLABIOS_0.2.5_8X.ROM make (does not work yet)

https://github.com/virtualxt/pcxtbios
chmod a+x make_linux.sh
install freebasic
compile toolsrc using fbc -lang qb file.bas
move the compiled tools to ./linux
eproms/2764/pcxtbios.rom at 0xfe000 is mandatory, the rest is optional

make -C vm clean
BIOS_LOAD_ADDRESS=fe000 BIOS_BIN=~/intcode/pcxtbios/eproms/2764/pcxtbios.rom make && ~/intcode/xzintbit/vms/c/ic bin/vm.input

make -C vm clean
cat ~/intcode/pcxtbios/eproms/2764/basicfc.rom ~/intcode/pcxtbios/eproms/2764/pcxtbios.rom > bios.tmp
BIOS_LOAD_ADDRESS=fc000 BIOS_BIN=$(pwd)/bios.tmp make && ~/intcode/xzintbit/vms/c/ic bin/vm.input

CGA
===

http://nerdlypleasures.blogspot.com/2016/05/ibms-cga-hardware-explained.html?m=1
https://www.seasip.info/VintagePC/cga.html

https://en.wikipedia.org/wiki/ANSI_escape_code
https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html

PIT Programmable Interval Timer 8253
====================================

https://wiki.osdev.org/Programmable_Interval_Timer

PPI Programmable Peripheral Interface 8255
==========================================

https://www.geeksforgeeks.org/programmable-peripheral-interface-8255/
https://www.renesas.com/us/en/document/dst/82c55a-datasheet
http://aturing.umcs.maine.edu/~meadow/courses/cos335/Intel8255A.pdf
https://www.learn-c.com/8255.pdf

ppi_pa_reg 60h: 8255 PPI port A
read keyboard data

ppi_pb_reg 61h: 8255 PPI port B
write

ppi_pc_reg 62h: 8255 PPI port C
read

ppi_cwd_reg	63h: 8255 PPI control word register
0b10011001

DOS
===

https://github.com/codercowboy/freedosbootdisks
FDC
===

https://www.pcjs.org/machines/pcx86/ibm/hdc/
https://www.datasheet.live/pdfviewer?url=https%3A%2F%2Fpdf.datasheet.live%2F3fe4a52f%2Fintel.com%2FP8272A.pdf
https://en.m.wikipedia.org/wiki/Floppy-disk_controller
https://retrocmp.de/fdd/general/floppy-formats.htm

config_tracing_cs:
    db  0xf000
config_tracing_ip:
    db  0xe6f2 # int_19
    db  0xec59 # int_13
    db  0xc425 # int_13_fn00
    db  0xc42f # fdc_init

fdc_init:

- OK timer turns off motors by writing 0x0c to DOR
- OK fdc_dor_reset
    - pulse bit 2 in DOR to reset (reset state if FDC)
    - make sure it keeps DMA on
    - then it waits for IRQ6 = INT 0E
- OK read status register, fail if not bit 7, fail if bit 6
- OK fdc sense interrupt status
    - al = 0x08 -> fdc_write
    - fdc_read -> ST0 (if carry, error)
    - fdc_read -> current cylinder (if carry, error) PCN
    - if ST0 has 0x0c bits set, pass
- fdc_send_specify
    - sends data based on int_1E
    - I think the only interesting bit is ND, we need to check it's 0 (DMA mode)

int_19
setloc	0E6F2h

<bin/vm.bios-xt.input.map.yaml yq '.symbols.fdc_dor_write.export|(.module)+(.offset)'

- OK int_13_fn08 get drive params
    - in: dl=0, drive 0
    - out: dl, number of drives
    - call get_drive_type
    - call get_media_state
    - call set_media_state
    - looks like no use of fdc
- int_13_fn02 read sector
    - al=1
    - dx=0 (head 0, drive 0)
    - cx=1 (track 0, sector 1)
    - es:bx target buffer (0000:7c00)
    - out: CF=0 success
    - OK fdc_motor_on
    - fdc_disk_change
    - fdc_set_rate
    - fdc_detect_media
        - get_drive_type (hardcoded 1.44 3.5")
        - fdc_read_id
            - fdc_set_rate Cw
            - fdc_recalibrate Dw 111
    - fdc_configure_dma
        - dmac_mode_reg
        - dmac_ff_reg
        - dmac_ch2_count_reg
        - dmac_ch2_addr_reg
        - dmapage_ch2_reg
        - dmac_mask_reg
    - fdc_seek
        - fdc_recalibrate
    - fdc_send_cmd 0e6
    - fdc_wait_irq
    - fdc_get_result

Booting OS...
reset fdc fn00              i13 Aw_00001000 Aw_00001100 R Sr_10000000 Sr_10000000
sense interrupt status      Dw_00001000 Sr_11000000 Sr_11000000 Dr_11000000 Sr_11000000 Sr_11000000 Dr_00000000 Sr_10000000
specify                     Dw_00000011 Sr_10000000 Dw_10101111 Sr_10000000 Dw_00000010
get drive parameters fn08   i13
read sector fn02            i13 Aw_00011100 Cw_00000000 Sr_10000000
recalibrate                 Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000
Dw_00000111 Sr_10000000 Dw_00000000 Cw_00000010 Sr_10000000
Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000
Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000
Dw_00000011 Sr_10000000 Dw_11011111 Sr_10000000 Dw_00000010 Sr_10000000
Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000
Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000

(after recalibrate works)
Booting OS...
reset fdc fn00              i13 Aw_00001000 Aw_00001100 R Sr_10000000 Sr_10000000
sense interrupt status      Dw_00001000 Sr_11000000 Sr_11000000 Dr_11000000 Sr_11000000 Sr_11000000 Dr_00000000 Sr_10000000
specify                     Dw_00000011 Sr_10000000 Dw_10101111 Sr_10000000 Dw_00000010
get drive parameters fn08   i13
read sector fn02            i13 Aw_00011100 Cw_00000000 Sr_10000000
recalibrate                 Dw_00000111 Sr_10000000 Dw_00000000 Sr_10000000
sense interrupt status      Dw_00001000 Sr_11000000 Sr_11000000 looks unfinished
Cw_00000010 Sr_11000000 Sr_11000000 Sr_11000000

reset fdc fn00              i13 Aw_00011000 Aw_00011100 R Sr_11000000
reset fdc fn00 attempt 2    Aw_00011000 Aw_00011100 R Sr_11000000
reset fdc fn00              i13 Aw_00011000 Aw_00011100 R Sr_11000000
reset fdc fn00 attempt 2    Aw_00011000 Aw_00011100 R Sr_11000000
reset fdc fn00              i13 Aw_00011000 Aw_00011100 R Sr_11000000
reset fdc fn00 attempt 2    Aw_00011000 Aw_00011100 R Sr_11000000
                            i13

(after fdc busy flag)
Booting OS...
reset fdc fn00              i13_00 Aw_00001000 Aw_00001100 R Sr_10000000 Sr_10000000
sense interrupt status      Dw_00001000 Sr_11010000 Sr_11010000 Dr_11000000 Sr_11010000 Sr_11010000 Dr_00000000 Sr_10000000
specify                     Dw_00000011 Sr_10010000 Dw_10101111 Sr_10010000 Dw_00000010
get drive parameters fn08   i13_08
read sector fn02            i13_02 Aw_00011100 Cw_00000000 Sr_10000000
recalibrate                 Dw_00000111 Sr_10010000 Dw_00000000 Sr_10000000
sense interrupt status      Dw_00001000 Sr_11010000 Dr_10000000 Sr_10000000 Sr_10000000
read id                     Dw_01001010 Sr_10010000 Dw_00000000 (waits, probably for interrupt) Cw_00000010 Sr_11010000 Sr_11010000 Sr_11010000

reset fdc fn00              i13_00 Aw_00011000 Aw_00011100 R Sr_11010000 Aw_00011000 Aw_00011100 R Sr_11010000
                            i13_00 Aw_00011000 Aw_00011100 R Sr_11010000 Aw_00011000 Aw_00011100 R Sr_11010000
                            i13_00 Aw_00011000 Aw_00011100 R Sr_11010000 Aw_00011000 Aw_00011100 R Sr_11010000
                            i13_0d
