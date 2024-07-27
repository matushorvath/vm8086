Notes
=====

Run without interpreting ANSI escape sequences:
make && ~/intcode/xzintbit/vms/c/ic bin/vm.bios-xt.input | tr '\33' '\n'

Instruction Decoding
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
- higher level floppy logging (read CHS+count -> target buffer)

VM:
- nmi_mask_reg
- keyboard controller (8242) ppi_pb_reg; also read ppi_pb_reg

- support missing floppy commands

- support CGA paging (affects start address where we read CGA data from mem)
- investigate whether we can speed up full redraw by switching to alternate buffer
- consider using strings for the palettes, avoid printb to speed up; e.g. string "170;170;0;" for yellow

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

8086_bios
---------

https://github.com/skiselev/8088_bios.git

listing:
set(CMAKE_ASM_NASM_FLAGS "-O9 -l $(basename $@).lst)"
./build/CMakeFiles/bios-xt.bin.dir/src/bios.asm.lst

GLaBIOS
-------

https://glabios.org/

f000:e0c2 end of BIOS checksum
f000:e0e9 PIT test LOOP	INIT_PIT1_TEST
it keeps looping forever
because it's trying to test PIT channel 1 and we don't have it
if DRAM_REFRESH <= 0 it will instead use channel 0

PCXTBIOS
--------

https://github.com/virtualxt/pcxtbios
- chmod a+x make_linux.sh
- install freebasic
- compile toolsrc using fbc -lang qb file.bas
- move the compiled tools to ./linux
- eproms/2764/pcxtbios.rom at 0xfe000 is mandatory, the rest is optional

pcxtbios + BASIC:
- make -C vm clean
- cat ~/intcode/pcxtbios/eproms/2764/basicfc.rom ~/intcode/pcxtbios/eproms/2764/pcxtbios.rom > - bios.tmp
- BIOS_LOAD_ADDRESS=fc000 BIOS_BIN=$(pwd)/bios.tmp make && ~/intcode/xzintbit/vms/c/ic bin/vm.input

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

Floppy Disk Controller
======================

https://www.pcjs.org/machines/pcx86/ibm/hdc/  
https://www.datasheet.live/pdfviewer?url=https%3A%2F%2Fpdf.datasheet.live%2F3fe4a52f%2Fintel.com%2FP8272A.pdf  
https://en.m.wikipedia.org/wiki/Floppy-disk_controller  
https://retrocmp.de/fdd/general/floppy-formats.htm  
https://wiki.osdev.org/Floppy_Disk_Controller  
https://www.isdaman.com/alsos/hardware/fdc/floppy.htm  

```
config_tracing_cs:
    db  0xf000
config_tracing_ip:
    db  0xe6f2 # int_19
    db  0xec59 # int_13
    db  0xc425 # int_13_fn00
    db  0xc42f # fdc_init
```

<bin/vm.bios-xt.input.map.yaml yq '.symbols.fdc_dor_write.export|(.module)+(.offset)'

Interrupts
==========

https://wiki.osdev.org/8259_PIC
http://www.brokenthorn.com/Resources/OSDevPic.html
https://helppc.netcore2k.net/hardware/8259
https://stanislavs.org/helppc/idx_interrupt.html

FreeDOS Plan
============

https://github.com/codercowboy/freedosbootdisks

tools (sorted by priority):
 - unit tests for fdc
    - investigate if bochs has upd765ac or something else, how compatible it is
    - infrastructure based on test-bochs, with libdev and libfdc
    - floppy image with a test pattern

 - 8086 monitor with code listing
    - investigate if we can get NASM lst for FreeDOS bootstrap code
    - investigate what format does FreeDOS use for C debug info
    - compile 8088_bios with NASM lst
    - add a new 8086 tracing mode that outputs JSONs
       - current 8086 address
       - state of all registers, stack
       - relevant memory locations (every location read/written during instruction execution?)
    - monitor in js that parses the JSONs and .lst files (and C debug info) and displays source code and state

 - DONE logging based on config.s, multiple configurable subsystems
    - or better, preprocessor with ifdef support and a debug version, don't even compile in the logging

 - improve xzintbit debugging
    - as option to export all symbols, maybe add a new section to .o with non-exported symbols (asd debug version)
    - as option to map line number to memory address, maybe also add a new section to .o for that (asd debug version)
    - ldmap to include all that information in map, ld to ignore new sections if present
        - for symbols and line addresses, they need to be relocated same as exported symbols
        - for lines, we also need to somehow know file name for the line number (perhaps an additional input to asd, same as bin2obj)

FreeDOS Prompt
==============

good addresses to start tracing:
1254:0005 (after FreeDOS and a lot of disk reading)
1212:0000
9001:9f61
9001:050f
9001:129f

Q: Why does it not even display the F5/F8 message in bochs?

kbc_data_reg	equ	60h
kbc_status_reg	equ	64h

MACHINE_HOMEBREW8088 is like MACHINE_XT, but AT keyboard controller and no DMA ch0 setup

also interesting
9001:0240 INT IMMED8(cd) 2a
00d8:118a IRET(cf)
9001:0242 POP AX(58)

INT 2a = critical section and NETBIOS (could be keyboard busy loop if AH=84)
https://stanislavs.org/helppc/int_2a.html

f000:cb32 "fdc reset controller" - what happens before that, why is it resetting the fdc?

Keyboard
========

https://en.wikipedia.org/wiki/ANSI_escape_code

type 0Ft

ESC SP F:
    ACS6 Announce Code Structure 6
    S7C1T Send 7-bit C1 Control Character to the Host
    Makes the function keys send ESC + letter instead of 8-bit C1 codes.
ESC SP G:
    ACS7 Announce Code Structure 7
    S8C1T Send 8-bit C1 Control Character to the Host
    Makes the function keys send 8-bit C1 codes.

Terminal input sequences

non-blocking input options:
 - modify ICVM
    - address 0: arb 0 will enable extensions, write IC version to address 0 for one cycle only
    - add a FEATURE instruction, param feature_id, returns version, 0=feature unsupported
       - perhaps feature id = instruction opcode? return also for standard instructions?
    - other options:
       - jnz 0, 0
       - jz [0], [0]
       - eq 0, 1, [2] write to address 3
    - add non-blocking IN instruction
       - return e.g. -1 if no character available
    - don't forget that instructions < 100
 - pre-filter: read stdin, respond to reads on stdout
    - needs to be synchronous, only generate on stdout if there is a request, avoid buffering - can that be done?
 - think about fallbacks - running with standard ICVM (disable keyboard?), running without filter (how to even detect that?)

https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
https://c-faq.com/osdep/cbreak.html
https://digitalmars.com/rtl/conio.html#_kbhit

Shutdown and Reboot
===================

https://gitlab.com/FreeDOS/base/fdapm
gttps://wiki.osdev.org/APM

https://wiki.osdev.org/%228042%22_PS/2_Controller
reboot via keyboard controller: port 64h <- 0feh

Text602 3.0
===========

Matus Horvath
TK376658
