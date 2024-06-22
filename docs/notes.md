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

listing:
set(CMAKE_ASM_NASM_FLAGS "-O9 -l $(basename $@).lst")
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

FreeDOS Boot
============

FreeDOS
fdc dor write, value 00011100                   select A, enable A motor
fdc status read, value 10000000                 data ready, to controller, not busy
===== fdc state machine, new command started
fdc data write, value 00000011 (0x03)           specify
fdc status read, value 10010000                 data ready, busy
fdc data write, value 10111111 (0xbf)           srt/hut
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)           hlt/nd (dma on)
dma ch02, write count L ff
dma ch02, write count H 1ff                     DMA 512 bytes
dma ch02, write address L 0
dma ch02, write address H 600                   DMA address 0x000600
dma ch02, write page 0
fdc status read, value 10000000                 data ready, to controller, not busy
===== fdc state machine, new command started
fdc data write, value 11100110 (0xe6)           read data, MT=1
fdc status read, value 10010000
fdc data write, value 00000100 (0x04)           H=1
fdc status read, value 10010000
fdc data write, value 00000000 (0x00)           C=0
fdc status read, value 10010000
fdc data write, value 00000001 (0x01)           H=1
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)           R=2
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)           N=02->512
fdc status read, value 10010000
fdc data write, value 00100100 (0x24)           EOT=36 (18 * 2 sectors per cylinder)
fdc status read, value 10010000
fdc data write, value 00011011 (0x1b)           GPL
fdc status read, value 10010000
fdc data write, value 11111111 (0xff)           DTL=0xff
dma ch02, receive data, count 512               read 512 bytes from C=0 H=1 R=2 = start at (18 + 2 - 1) * 512 = 0x2600
fdc status read, value 11010000                 data ready, from controller, busy
fdc data read, value 00000100 (0x04)            ST0 (head 1, unit 0, OK)
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            ST1
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            ST2
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            C=0
fdc status read, value 11010000
fdc data read, value 00000001 (0x01)            H=1
fdc status read, value 11010000
fdc data read, value 00000011 (0x03)            R=3
fdc status read, value 11010000
fdc data read, value 00000010 (0x02)            N=02->512
fdc status read, value 10000000                 data ready, to controller, not busy
int 13, fn 2                                    BIOS floppy read data
fdc dor write, value 00011100                   select A, enable A motor
fdc status read, value 10000000                 data ready, to controller, not busy
===== fdc state machine, new command started
fdc data write, value 00000011 (0x03)           specify
fdc status read, value 10010000
fdc data write, value 10111111 (0xbf)           srt/hut
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)           hlt/nd (dma on)
dma ch02, write count L ff
dma ch02, write count H 1ff                     DMA 512 bytes
dma ch02, write address L 0
dma ch02, write address H 800                   DMA addres 0x000800
dma ch02, write page 0
fdc status read, value 10000000                 data ready, to controller, not busy
===== fdc state machine, new command started
fdc data write, value 11100110 (0xe6)           read data, MT=1
fdc status read, value 10010000
fdc data write, value 00000100 (0x04)           head 1
fdc status read, value 10010000
fdc data write, value 00000000 (0x00)           C=0
fdc status read, value 10010000
fdc data write, value 00000001 (0x01)           H=1
fdc status read, value 10010000
fdc data write, value 00000011 (0x03)           R=3
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)           N=02->512
fdc status read, value 10010000
fdc data write, value 00100100 (0x24)           EOT=36
fdc status read, value 10010000
fdc data write, value 00011011 (0x1b)           GPT
fdc status read, value 10010000
fdc data write, value 11111111 (0xff)           DTL=0xff
fdc status read, value 11010000
fdc data read, value 10001100 (0x8c)            S0 (head 1, unit 0, not ready, OK) TODO why is the unit not ready?
fdc status read, value 11010000
fdc data read, value 00000101 (0x05)            S1 (missing address mark, no data) TODO why?
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            S2
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            C=0
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            H=0
fdc status read, value 11010000
fdc data read, value 00000000 (0x00)            R=0
fdc status read, value 11010000
fdc data read, value 00000010 (0x02)            N=02->512
fdc status read, value 10000000
int 13, fn 0                                    FDC reset
fdc dor write, value 00011000
fdc dor write, value 00011100
fdc reset controller

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

(steps to get from FreeDOS starting to boot all the way to FreeDOS A> prompt)

looping this:

f000:c402 RETN(c3)
f000:c3e3 SUB REG16/MEM16, REG16(29) c1 29 cb
f000:c3e5 SUB REG16/MEM16, REG16(29) cb 89 c1
f000:c3e7 MOV REG16/MEM16, REG16(89) c1 83 da
f000:c3e9 ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG16/MEM16, IMMED8(83) da 00 73 f2
f000:c3ec JNC SHORT-LABEL(73) f2
f000:c3e0 CALL NEAR-PROC(e8) 10 00
f000:c3f3 MOV AL, IMMED8(b0) 00
f000:c3f5 PUSHF(9c)
f000:c3f6 CLI(fa)
f000:c3f7 OUT AL, IMMED8(e6) 43
f000:c3f9 IN AL, IMMED8(e4) 40
f000:c3fb MOV REG8/MEM8, REG8(88) c4 e4 40
f000:c3fd IN AL, IMMED8(e4) 40
f000:c3ff POPF(9d)
f000:c400 XCHG REG8, REG8/MEM8(86) c4 c3 8b
f000:c402 RETN(c3)

(not sure if above is really the loop or just something done 10+ times)

other approach:

looking at fdc logs, there is a fdc reset after a read that looks successful
MF=1 H=1 C=3 J=1 S=7 N=512 EOT=36 GPT DTL=ff
ST0=0b00000100 etc

after that:

int 13, fn 0
int 13, fn 8
int 13, fn 21
int 13, fn 8
int 13, fn 21
int 13, fn 8
int 13, fn 22
fdc dor write, value 00011100
int 13, fn 22
fdc dor write, value 00011100
int 13, fn 0
fdc dor write, value 00011000
fdc dor write, value 00011100
fdc reset controller
irq 6
fdc status read, value 10000000
fdc status read, value 10000000
===== fdc state machine, new command started
fdc data write, value 00001000 (0x08)
fdc status read, value 11010000
fdc status read, value 11010000
fdc data read, value 11000000 (0xc0)
fdc status read, value 11010000
fdc status read, value 11010000
fdc data read, value 00000011 (0x03)
fdc status read, value 10000000

looks like int 13 fn 22 does not work (twice, then BIOS resets fdc)
fn 8 and fn 21 are also done multiple times, could also be wrong

then there are some reads and then there is no more floppy activity

good addresses to start tracing:
1254:0005 (after FreeDOS and a lot of disk reading)

maybe print CS:IP every time we load reg_cs?
maybe print CS:IP every time hi byte of reg_ip changes by incrementing IP?

1212:0000

write CS: 9090:a1a1
write CS: f0f0:e8e8

f000:c400
f000:c3f3 is the function that is called in a loop
it's also called at the very beginning of boot, part of BIOS
something related to PIT (port 40, 43)

it's delay_15us/io_wait_latch
maybe reading keyboard controller? it's waiting for F5/F8?
could be kbc_data_read kbc_wait_write kbc_flush
not kbd_key_fail probably, since there is no POST code

or fdc_recalibrate fdc_seek fdc_motor_on fdc_reset
or beep (beeping because boot has failed? - but I don't see that in BIOS sources)
or int_17_fn01

the "Press F8 to trace or F5 to skip CONFIG.SYS/AUTOEXEC.BAT" line does not appear in bochs, it clears screen and displays A>

this probably freezes
key = GetBiosKey(InitKernelConfig.SkipConfigSeconds);

-> same issue as pcxtbios, reading address 0x46c and expecting to see a changing number from INT0
ticks_lo	equ	6Ch	; word - timer ticks - low word
ticks_hi	equ	6Eh	; word - timer ticks - high word

int_08

Q: Why does it not even display the F5/F8 message in bochs?

kbc_data_reg	equ	60h
kbc_status_reg	equ	64h

MACHINE_HOMEBREW8088 is like MACHINE_XT, but AT keyboard controller and no DMA ch0 setup

vm8086 error: fdc: requested read data command variant is not supported (cs:ip f000:c94e)

dma ch02, write count L 255
dma ch02, write count H 1023
dma ch02, write address 0xL e0
dma ch02, write address 0xH 1e0
dma ch02, write page 0x0
...
===== fdc state machine, new command started
fdc data write, value 11100110 (0xe6)
fdc status read, value 10010000
fdc data write, value 00000100 (0x04)
fdc status read, value 10010000
fdc data write, value 00000011 (0x03)
fdc status read, value 10010000
fdc data write, value 00000001 (0x01)
fdc status read, value 10010000
fdc data write, value 00010001 (0x11)
fdc status read, value 10010000
fdc data write, value 00000010 (0x02)
fdc status read, value 10010000
fdc data write, value 00010010 (0x12)
fdc status read, value 10010000
fdc data write, value 00011011 (0x1b)
fdc status read, value 10010000
fdc data write, value 11111111 (0xff)

-> crash because DMA count is not 512

-----
searching for 'int 13, fn 22' to find a later CS:IP to use as breakpoint:
9001:9f61 INT IMMED8(cd) 13
int 13, fn 22
f000:ec59 STI(fb)
...
f000:ec76 CALL NEAR-PROC(e8) 1a df
f000:cb93 MOV AL, IMMED8(b0) 44
...
f000:cbb0 RETN(c3)
f000:ec79 ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8(80) fc 08 75 03

---
9001:050f CALL NEAR-PROC(e8) 47 9a
9001:9f59 POP AX(58)
9001:9f5a POP DX(5a)
9001:9f5b PUSH AX(50)
9001:9f5c PUSH SI(56)
9001:9f5d MOV AH, IMMED8(b4) 16
9001:9f5f XOR REG16/MEM16, REG16(31) f6 cd 13
9001:9f61 INT IMMED8(cd) 13
int 13, fn 22
f000:ec59 STI(fb)
---
9001:0e5f CALL NEAR-PROC(e8) ec 90
9001:9f4e POP AX(58)
9001:9f4f POP DX(5a)
9001:9f50 PUSH AX(50)
9001:9f51 MOV AH, IMMED8(b4) 00
9001:9f53 INT IMMED8(cd) 13
int 13, fn 0
f000:ec59 STI(fb)
---
f000:ca0e CALL NEAR-PROC(e8) 14 01
f000:cb25 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1(d0) c8 d0 c8
f000:cb27 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1(d0) c8 d0 c8
f000:cb29 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1(d0) c8 d0 c8
f000:cb2b ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1(d0) c8 0c 08
f000:cb2d OR AL, IMMED8(0c) 08
f000:cb2f MOV DX, IMMED16(ba) f2 03
f000:cb32 OUT AL, DX(ee)
fdc dor write, value 00011100
fdc reset controller
irq 6
f000:ef57 PUSH AX(50)

loop:

9001:129f POP AX(58)
9001:12a0 PUSH BP(55)
9001:12a1 MOV REG16/MEM16, REG16(89) e5 53 51
9001:12a3 PUSH BX(53)
9001:12a4 PUSH CX(51)
9001:12a5 PUSH ES(06)
9001:12a6 PUSH SI(56)
9001:12a7 PUSH DI(57)
9001:12a8 PUSH DS(1e)
9001:12a9 PUSH DS(1e)
9001:12aa POP ES(07)
9001:12ab CLD(fc)
9001:12ac MOV BL, IMMED8(b3) 06
9001:12ae MOV REG16, REG16/MEM16(8b) 4e 04 8b
9001:12b1 MOV REG16, REG16/MEM16(8b) 76 06 8b
9001:12b4 MOV REG16, REG16/MEM16(8b) 7e 08 ff
9001:12b7 INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) e0 e8 e3
9001:13ab XCHG REG16, REG16/MEM16(87) f7 e3 04
9001:13ad JCXZ SHORT-LABEL(e3) 04
9001:13af REPZ(f3)
9001:13b0 CMPS DEST-STR8, SRC-STR8(a6)
9001:13b1 JNZ SHORT-LABEL(75) 04
9001:13b7 LAHF(9f)
9001:13b8 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG8/MEM8, 1(d0) cc e9 33
9001:13ba JMP NEAR-LABEL(e9) 33 ff
9001:12f0 LDS REG16, MEM16(c5) 7e 00 b7
9001:12f3 MOV BH, IMMED8(b7) 00
9001:12f5 ADD REG16/MEM16, REG16(01) dd 8c 5e
9001:12f7 MOV REG16/MEM16, SEGREG(8c) 5e 02 89
9001:12fa MOV REG16/MEM16, REG16(89) 7e 00 1f
9001:12fd POP DS(1f)
9001:12fe POP DI(5f)
9001:12ff POP SI(5e)
9001:1300 POP ES(07)
9001:1301 POP CX(59)
9001:1302 POP BX(5b)
9001:1303 MOV REG16/MEM16, REG16(89) ec 5d c3
9001:1305 POP BP(5d)
9001:1306 RETN(c3)
9001:41f0 TEST REG16/MEM16, REG16(85) c0 75 04
9001:41f2 JNZ SHORT-LABEL(75) 04
9001:41f8 XOR REG16/MEM16, REG16(31) c0 c3 51
9001:41fa RETN(c3)
9001:4225 TEST REG16/MEM16, REG16(85) c0 74 15
9001:4227 JZ SHORT-LABEL(74) 15
9001:423e MOV REG16, REG16/MEM16(8b) 77 02 ff
9001:4241 INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) 44 0d eb
9001:4244 JMP SHORT-LABEL(eb) ca
9001:4210 MOV REG16/MEM16, REG16(89) d8 e8 60
9001:4212 CALL NEAR-PROC(e8) 60 f9
9001:3b75 PUSH BX(53)
9001:3b76 PUSH CX(51)
9001:3b77 PUSH DX(52)
9001:3b78 PUSH SI(56)
9001:3b79 PUSH DI(57)
9001:3b7a PUSH ES(06)
9001:3b7b PUSH BP(55)
9001:3b7c MOV REG16/MEM16, REG16(89) e5 50 50
9001:3b7e PUSH AX(50)
9001:3b7f PUSH AX(50)
9001:3b80 MOV REG16/MEM16, REG16(89) c6 c4 5c
9001:3b82 LES REG16, MEM16(c4) 5c 29 26
9001:3b85 ES:(26)
9001:3b86 MOV REG16, REG16/MEM16(8b) 47 02 89
9001:3b89 MOV REG16/MEM16, REG16(89) 46 fe 8b
9001:3b8c MOV REG16, REG16/MEM16(8b) 7c 02 8b
9001:3b8f MOV REG16, REG16/MEM16(8b) 45 0d 89
9001:3b92 MOV REG16/MEM16, REG16(89) 46 fc 3d
9001:3b95 CMP AX, IMMED16(3d) ff ff
9001:3b98 JC SHORT-LABEL(72) 06
9001:3ba0 MOV REG16, REG16/MEM16(8b) 45 11 0b
9001:3ba3 OR REG16, REG16/MEM16(0b) 45 0f 75
9001:3ba6 JNZ SHORT-LABEL(75) 22
9001:3ba8 MOV REG16, REG16/MEM16(8b) 46 fc 26
9001:3bab ES:(26)
9001:3bac CMP REG16, REG16/MEM16(3b) 47 09 73
9001:3baf JNC SHORT-LABEL(73) e9
9001:3bb1 MOV CL, IMMED8(b1) 05
9001:3bb3 MOV REG16, REG16/MEM16(8b) 7e fe d3
9001:3bb6 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, CL(d3) ef 31 d2
9001:3bb8 XOR REG16/MEM16, REG16(31) d2 f7 f7
9001:3bba TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG16/MEM16 (IMMED16)(f7) f7 26 03 47 11
9001:3bbc ES:(26)
9001:3bbd ADD REG16, REG16/MEM16(03) 47 11 89
9001:3bc0 MOV REG16/MEM16, REG16(89) 44 24 c7
9001:3bc3 MOV MEM16, IMMED16(c7) 44 26 00 00 eb
9001:3bc8 JMP SHORT-LABEL(eb) 56
9001:3c20 LES REG16, MEM16(c4) 5c 29 26
9001:3c23 ES:(26)
9001:3c24 MOV REG8, REG8/MEM8(8a) 07 98 8b
9001:3c26 CBW(98)
9001:3c27 MOV REG16, REG16/MEM16(8b) 54 24 8b
9001:3c2a MOV REG16, REG16/MEM16(8b) 7c 26 31
9001:3c2d XOR REG16/MEM16, REG16(31) c9 89 c3
9001:3c2f MOV REG16/MEM16, REG16(89) c3 89 d0
9001:3c31 MOV REG16/MEM16, REG16(89) d0 89 fa
9001:3c33 MOV REG16/MEM16, REG16(89) fa e8 44
9001:3c35 CALL NEAR-PROC(e8) 44 dc
9001:187c PUSH SI(56)
9001:187d PUSH DI(57)
9001:187e PUSH ES(06)
9001:187f PUSH BP(55)
9001:1880 MOV REG16/MEM16, REG16(89) e5 50 50
9001:1882 PUSH AX(50)
9001:1883 PUSH AX(50)
9001:1884 PUSH AX(50)
9001:1885 MOV REG16/MEM16, REG16(89) d7 89 5e
9001:1887 MOV REG16/MEM16, REG16(89) 5e fc e8
9001:188a CALL NEAR-PROC(e8) b0 fe
9001:173d PUSH CX(51)
9001:173e PUSH SI(56)
9001:173f PUSH DI(57)
9001:1740 PUSH ES(06)
9001:1741 PUSH BP(55)
9001:1742 MOV REG16/MEM16, REG16(89) e5 50 50
9001:1744 PUSH AX(50)
9001:1745 PUSH AX(50)
9001:1746 PUSH AX(50)
9001:1747 PUSH DX(52)
9001:1748 PUSH BX(53)
9001:1749 XOR REG16/MEM16, REG16(31) d2 31 c9
9001:174b XOR REG16/MEM16, REG16(31) c9 89 56
9001:174d MOV REG16/MEM16, REG16(89) 56 fc 8b
9001:1750 MOV REG16, REG16/MEM16(8b) 36 6d 00
9001:1754 MOV AX, MEM16(a1) 6f 00
9001:1757 MOV REG16/MEM16, REG16(89) f3 89 46
9001:1759 MOV REG16/MEM16, REG16(89) 46 fe 8e
9001:175c MOV SEGREG, REG16/MEM16(8e) 46 fe 26
9001:175f ES:(26)
9001:1760 MOV REG16, REG16/MEM16(8b) 44 08 3b
9001:1763 CMP REG16, REG16/MEM16(3b) 46 f8 75
9001:1766 JNZ SHORT-LABEL(75) 31
9001:1768 ES:(26)
9001:1769 MOV REG16, REG16/MEM16(8b) 44 06 3b
9001:176c CMP REG16, REG16/MEM16(3b) 46 fa 75
9001:176f JNZ SHORT-LABEL(75) 28
9001:1771 ES:(26)
9001:1772 TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG8/MEM8 (IMMED8)(f6) 44 05 20 74
9001:1776 JZ SHORT-LABEL(74) 21
9001:1778 ES:(26)
9001:1779 MOV REG8, REG8/MEM8(8a) 44 04 98
9001:177c CBW(98)
9001:177d CMP REG16, REG16/MEM16(3b) 46 f6 75
9001:1780 JNZ SHORT-LABEL(75) 17
9001:1782 ES:(26)
9001:1783 ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8(80) 64 05 fe 39
9001:1787 CMP REG16/MEM16, REG16(39) de 74 0b
9001:1789 JZ SHORT-LABEL(74) 0b
9001:1796 JMP NEAR-LABEL(e9) 67 00
9001:1800 MOV REG16, REG16/MEM16(8b) 56 fe 89
9001:1803 MOV REG16/MEM16, REG16(89) f0 89 ec
9001:1805 MOV REG16/MEM16, REG16(89) ec 5d 07
9001:1807 POP BP(5d)
9001:1808 POP ES(07)
9001:1809 POP DI(5f)
9001:180a POP SI(5e)
9001:180b POP CX(59)
9001:180c RETN(c3)
9001:188d MOV REG16/MEM16, REG16(89) c3 89 c6
9001:188f MOV REG16/MEM16, REG16(89) c6 8e c2
9001:1891 MOV SEGREG, REG16/MEM16(8e) c2 89 56
9001:1893 MOV REG16/MEM16, REG16(89) 56 fe 26
9001:1896 ES:(26)
9001:1897 TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG8/MEM8 (IMMED8)(f6) 47 05 01 74
9001:189b JZ SHORT-LABEL(74) 4b
9001:18e8 MOV REG16/MEM16, REG16(89) d8 89 ec
9001:18ea MOV REG16/MEM16, REG16(89) ec 5d e9
9001:18ec POP BP(5d)
9001:18ed JMP NEAR-LABEL(e9) 49 fe
9001:1739 POP ES(07)
9001:173a POP DI(5f)
9001:173b POP SI(5e)
9001:173c RETN(c3)
9001:3c38 MOV REG16/MEM16, REG16(89) c3 85 d2
9001:3c3a TEST REG16/MEM16, REG16(85) d2 75 09
9001:3c3c JNZ SHORT-LABEL(75) 09
9001:3c47 MOV SEGREG, REG16/MEM16(8e) c2 26 80
9001:3c49 ES:(26)
9001:3c4a ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8(80) 67 05 d1 26
9001:3c4e ES:(26)
9001:3c4f ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG8/MEM8, IMMED8(80) 4f 05 24 b1
9001:3c53 MOV CL, IMMED8(b1) 05
9001:3c55 MOV REG16, REG16/MEM16(8b) 7e fe d3
9001:3c58 ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, CL(d3) ef 8b 46
9001:3c5a MOV REG16, REG16/MEM16(8b) 46 fc 31
9001:3c5d XOR REG16/MEM16, REG16(31) d2 f7 f7
9001:3c5f TEST/NOT/NEG/MUL/IMUL/DIV/IDIV REG16/MEM16 (IMMED16)(f7) f7 88 54 28 8d
9001:3c61 MOV REG8/MEM8, REG8(88) 54 28 8d
9001:3c64 LEA REG16, MEM16(8d) 54 04 1e
9001:3c67 PUSH DS(1e)
9001:3c68 PUSH DX(52)
9001:3c69 MOV REG8, REG8/MEM8(8a) 44 28 30
9001:3c6c XOR REG8/MEM8, REG8(30) e4 d3 e0
9001:3c6e ROL/ROR/RCL/RCR/SHL/SHR/SAR REG16/MEM16, CL(d3) e0 83 c3
9001:3c70 ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG16/MEM16, IMMED8(83) c3 14 01 d8
9001:3c73 ADD REG16/MEM16, REG16(01) d8 06 50
9001:3c75 PUSH ES(06)
9001:3c76 PUSH AX(50)
9001:3c77 MOV AX, IMMED16(b8) 20 00
9001:3c7a PUSH AX(50)
9001:3c7b CALL NEAR-PROC(e8) 47 d6
9001:12c5 CALL NEAR-PROC(e8) d7 ff
...
9001:129f POP AX(58)
9001:12a0 PUSH BP(55)

also interesting
0070:02bc CS:(2e)
0070:02bd MOV SEGREG, REG16/MEM16(8e) 1e 27 01
0070:02c1 CLD(fc)
0070:02c2 CS:(2e)
0070:02c3 INC/DEC/CALL NEAR/CALL FAR/JMP NEAR/JMP FAR/PUSH REG16/MEM16(ff) 64 01 2e
0070:017b CS:(2e)
0070:017c MOV AL, MEM8(a0) 29 01
0070:017f OR REG8/MEM8, REG8(08) c0 75 1e
0070:0181 JNZ SHORT-LABEL(75) 1e
0070:0183 MOV AH, IMMED8(b4) 01
0070:0185 CS:(2e)
0070:0186 ADD REG8, REG8/MEM8(02) 26 2a 01
0070:018a INT IMMED8(cd) 16

INT 16 keyboard services, AH=01
get keystroke status

also interesting
9001:0240 INT IMMED8(cd) 2a
00d8:118a IRET(cf)
9001:0242 POP AX(58)

INT 2a = critical section and NETBIOS (could be keyboard busy loop if AH=84)
https://stanislavs.org/helppc/int_2a.html

---
debug points:
 - why are there no INT 8 = IRQ0 visible? or are they visible? maybe it's some of the f000 code
    - that said, is CLI/STI even doing anything? is it blocking IRQ0? I don't think so
    - are we maybe getting too many IRQs so we spend all time handling IRQ0?
    - are we getting IRQs in the middle of processing another IRQ?
 - f000:cb32 "fdc reset controller" - what happens before that, why is it resetting the fdc?

Interrupts
==========

https://wiki.osdev.org/8259_PIC
http://www.brokenthorn.com/Resources/OSDevPic.html
https://helppc.netcore2k.net/hardware/8259

Broken FreeDOS Boot
===================

Boot freedos with bochs 298de90                             8088 OK
PIT logging bb2f957                                         8088 OK, pcxt OK (no hard disks detected -> read data command variant is not supported)
INT0 generation from PIT d38b71e                            8088 OK, pcxt opcode error: ip 4 oc 0
Document current crash 686a0d0                              8088 OK, pcxt opcode error: ip 4 oc 0
Update crash analysis 7d1abe8                               8088 OK
Add some notes 8582a10                                      8088 OK
New disk reading algorithm acd96c0                          8088 OK
Interrupt logging 4737cdd                                   8088 OK
Make timer logging more useful 608da33                      8088 OK
Design a more performant PIT 79904b4                        8088 OK
Initial version of PIC f27acbb                              (PIC bug)
Fix ICW1 handling 9db2440                                   8088 freezes on POST 06

---
rebase last 2

Design a more performant PIT 79904b4                        8088 OK
Initial implementation of PIC 8259A 1a10eed                 8088 OK
(+stash with PIT changes, freezes on POST 06)

pcxtbios started crashing when IRQ0 was enabled
probably it's not expecting IRQ0 when IF=0

with IRQ0 disabled, pcxtbios loads extremely slowly, lots of disk operations (blinking FDD LED)
not sure if it even loads in the end
