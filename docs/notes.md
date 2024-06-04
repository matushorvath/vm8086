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
