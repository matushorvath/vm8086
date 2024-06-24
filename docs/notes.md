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
- https://wiki.osdev.org/APM APM for poweroff, FreeDOS should support it

VM:
- nmi_mask_reg
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

listing:
set(CMAKE_ASM_NASM_FLAGS "-O9 -l $(basename $@).lst)"
./build/CMakeFiles/bios-xt.bin.dir/src/bios.asm.lst

https://glabios.org/

https://github.com/virtualxt/pcxtbios
chmod a+x make_linux.sh
install freebasic
compile toolsrc using fbc -lang qb file.bas
move the compiled tools to ./linux
eproms/2764/pcxtbios.rom at 0xfe000 is mandatory, the rest is optional

pcxtbios + BASIC:
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

Floppy Disk Controller
======================

https://www.pcjs.org/machines/pcx86/ibm/hdc/
https://www.datasheet.live/pdfviewer?url=https%3A%2F%2Fpdf.datasheet.live%2F3fe4a52f%2Fintel.com%2FP8272A.pdf
https://en.m.wikipedia.org/wiki/Floppy-disk_controller
https://retrocmp.de/fdd/general/floppy-formats.htm
https://wiki.osdev.org/Floppy_Disk_Controller
https://www.isdaman.com/alsos/hardware/fdc/floppy.htm

config_tracing_cs:
    db  0xf000
config_tracing_ip:
    db  0xe6f2 # int_19
    db  0xec59 # int_13
    db  0xc425 # int_13_fn00
    db  0xc42f # fdc_init

<bin/vm.bios-xt.input.map.yaml yq '.symbols.fdc_dor_write.export|(.module)+(.offset)'

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

pcxtbios
========

delay_keypress f000:f9b3

int 16h, ah=1 check for keypress
int 16h, ah=1 flush keyboard buffer

f000:f9bb is where the int 16h happens

bx starts as 3*18
add [es:46Ch] to bx (0000:046C = 0040:006C)

problem: [es:46Ch] always is 0x00ca, it's supposed to be current ticks but it never changes
-> investigate how [es:46Ch] is updated, probably from something we don't have implemented in timer

	dw	?		; 40:6C		; Ticks since midnite (lo)
	dw	?		; 40:6E		; Ticks since midnite (hi)

updated by:
INT_8:  STI                                     ; Routine services clock tick
also
INT_1A: STI (but that seems to be the API to set time of day)

proc	int_8	far hardware clock
8259 chip

-> we need something to trigger int 8
that will change the ticks count and make the delay eventually expire

int8 is irq 0, timer interrupt that we don't have

-> workaround: in boot_basic comment out delay_keypress

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

Interrupts
==========

https://wiki.osdev.org/8259_PIC
http://www.brokenthorn.com/Resources/OSDevPic.html
https://helppc.netcore2k.net/hardware/8259
https://stanislavs.org/helppc/idx_interrupt.html

FreeDOS Crash
=============

1000:01f0 MOV REG16, REG16/MEM16(8b) d7 8b de
1000:01f2 MOV REG16, REG16/MEM16(8b) de ff 3b
1000:01f4 INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) 3b df 74

01e0-01ef don't seem to be executed

Booting OS...
FreeDOS kernel - SVN (build 2040 OEM:0xfd) [compiled Apr  7 2012]
Kernel compatibility 7.10 - WATCOMC - FAT32 support

(C) Copyright 1995-2011 Pasquale J. Villani and The FreeDOS Project.
All Rights Reserved. This is free software and comes with ABSOLUTELY NO
WARRANTY; you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation;
either version 2, or (at your option) any later version.
 - InitDiskno hard disks detected
Press F8 to trace or F5 to skip CONFIG.SYS/AUTOEXEC.BAT

-> crashing after EXEC A:\COMMAND.COM
in DOS log, search EXEC

(1000:0000) CS changed
(20ce:0006) CS changed

1000:0000 has valid code

1000:0000 MOV CX, IMMED16(b9) 61 4f
1000:0003 MOV SI, IMMED16(be) c0 9e
1000:0006 MOV REG16/MEM16, REG16(89) f7 1e a9
1000:0008 PUSH DS(1e)
1000:0009 TEST AX, IMMED16(a9) b5 80
1000:000c MOV REG16/MEM16, SEGREG(8c) c8 05 05
1000:000e ADD AX, IMMED16(05) 05 00
1000:0011 MOV SEGREG, REG16/MEM16(8e) d8 05 e9
1000:0013 ADD AX, IMMED16(05) e9 06
1000:0016 MOV SEGREG, REG16/MEM16(8e) c0 fd f3
1000:0018 STD(fd)
1000:0019 REPZ(f3)
1000:001a MOVS DEST-STR16, SRC-STR16(a5)
1000:001b CLD(fc)
1000:001c CS:(2e)
1000:001d ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8(80) 6c 12 10 73
1000:0021 JNC SHORT-LABEL(73) e7
1000:0023 XCHG AX, DX(92)
1000:0024 SCAS DEST-STR16(af)
1000:0025 LODS SRC-STR16(ad)
1000:0026 PUSH CS(0e)
1000:0027 PUSH CS(0e)
1000:0028 PUSH CS(0e)
1000:0029 PUSH ES(06)
1000:002a POP DS(1f)
1000:002b POP ES(07)
1000:002c PUSH SS(16)
1000:002d MOV BP, IMMED16(bd) 06 00
1000:0030 MOV BX, IMMED16(bb) 5f 80
1000:0033 PUSH BP(55)
1000:0034 RETF(cb)
(20ce:0006) CS changed

20ce:0006 only has 00 bytes until 20ce:01ec:

20ce:01e8 ADD REG8/MEM8, REG8(00) 00 00 00
20ce:01ea ADD REG8/MEM8, REG8(00) 00 ff 00
20ce:01ec INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) 00 f0 0f
20ce:01ee LOCK(f0)
20ce:01ef (invalid)(0f)
1000:01f0 MOV REG16, REG16/MEM16(8b) d7 8b de
1000:01f2 MOV REG16, REG16/MEM16(8b) de ff 3b
1000:01f4 INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) 3b df 74

(I don't know how it jumps from 20ce: back to 1000:)

addr 20ce6:

lo   0xe6
hi   0x0c
page 0x02

9216=0x2400
18 sectors - track - TODO is it trying to actually do a "read track" fdc command? because we don't have that

at 105e0 cnt 9215+1 = up to 129e0
129e0 9215
14de0 9215
171e0 3071

14944 411

TODO:
 - higher level floppy logging (read CHS+count -> target buffer)
 - maybe BUG: I think the fdc code always reads 512 bytes max, even when more is requested (DMA never receives more than 512 bytes)
