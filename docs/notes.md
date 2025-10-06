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

- Use macros for inc_ip_b, inc_ip_w, inc_sp_w, dec_sp_w, execute_inc, execute_dec. The same algorithm is in many places.
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

- support CGA text mode cursor on/off (currently it's always off)
- support CGA paging (affects start address where we read CGA data from mem)
- investigate whether we can speed up full redraw by switching to alternate buffer

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

8088_bios
---------

https://github.com/skiselev/8088_bios.git

listing:
set(CMAKE_ASM_NASM_FLAGS "-O9 -l $(basename $@).lst)"
./build/CMakeFiles/bios-xt.bin.dir/src/bios.asm.lst

IDE support:

memory map:
(bios-book8088-xtide.rom)

0xf0000 - 0xf1fff: XT-IDE (8kB)
0xf2000 - 0xfbfff: gap (40kB)
0xfc000 - 0xfffff: BIOS (16kB)

300h vs 320h refers to the port for XT-CF-Lite, not to memory address

-> use bios-xt.bin at 0xfc000 and ide_xt-cf-lite_300h.bin at 0xf0000

ICVM_TYPE=c-ext make run ROMS=bios-xt,ide-xt DISKS=msdos3-xtidecfg

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

update: actually, it's enough to install support for i386 in debian (via multiarch),
no need to recompile using freebasic

pcxtbios + ROM BASIC:

ICVM_TYPE=c-ext make run ROMS=pcxtbios,basicf6,basicf8,basicfa,basicfc DISKS=empty-180
(needs all four BASIC ROMs)

ICVM_TYPE=c-ext make run ROMS=pcxtbios,basicf6,basicf8,basicfa,basicfc DISKS=pcdos1
A> basica
(does not work if there is no ROM BASIC)

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

 - improve xzintbit debugging
    - as option to export all symbols, maybe add a new section to .o with non-exported symbols (asd debug version)
    - as option to map line number to memory address, maybe also add a new section to .o for that (asd debug version)
    - ldmap to include all that information in map, ld to ignore new sections if present
        - for symbols and line addresses, they need to be relocated same as exported symbols
        - for lines, we also need to somehow know file name for the line number (perhaps an additional input to asd, same as bin2obj)

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

https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
https://c-faq.com/osdep/cbreak.html
https://digitalmars.com/rtl/conio.html#_kbhit

hardware:

int_09 (IRQ1)
int_16 (BIOS functions)

in	al, 60h ; get keyboard data / scancode

in	al, 61h
out 61h, (al | 0b10000000) ; clear keyboard (set bit 7)
out 61h, (al & 0b01111111) ; unset clear keyboard (unset bit 7)

https://cosmodoc.org/topics/keyboard-functions/

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

Profiling
=========

handle_memory_read
read_b
handle_memory_read, different part
read_cs_ip_b
vm_callback
read_location_b
read_cs_ip_w
write_b
handle_memory_write

TODO profiling
 - optimize calc_addr_w, perhaps inline that as well
 - find a design that avoids searching the list of regions for every memory access
    - could use some kind of table (use segment as a key?)
    - could cache last used region registration, so we can reuse it for multiple operations
      - or at least cache it for word-sized operations, currently those get split to two bytes
    - could use a fixed number of region registrations, currently 2 would be probably enough
 - re-profile with keyboard input, I suspect vm_callback is very slow now

Phoenix BIOS
============

http://www.hampa.ch/pce/download.html

BIOS sets PPI mode to 0x89, which means port A is output - normally port A is input
Then it attempts to read from port A (which is related to keyboard), which seems wrong.
It also prints "Keyboard Bad" but then continues, and the keyboard does work.
Eventually it writes the correct value 0x99 into PPI mode and continues to boot.

ppi_mode_write needed a hack to allow both 0x89 and 0x99 to make this work.

Windows
=======

ICVM_TYPE=c-ext make run DISKS=msdos3-min-1440,win203-disk1,win203-disk2,win203-disk3,win203-disk4,win203-disk5
ICVM_TYPE=c-ext make run DISKS=msdos3-min-1440,win211-disk1,win211-disk2,win211-disk3,win211-disk4

run B:\setup, install to A:
F12, select disk in B: drive

Hard Drive
==========

MFM:
https://retrocmp.de/hardware/it-805/it805.htm
"very simple" with a small BIOS https://retrocmp.de/hardware/wd1002s-wx2a/wd1002s-wx2a.htm
WD1006?

PC AT https://retrocmp.de/ibm/cards/hdcfdc/16bit-at.htm
https://winworldpc.com/product/ibm-pc-at-fixed-disk-diskette-drive-adapter-test/100

https://xtideuniversalbios.org/

sudo apt instal git-svn
git svn clone https://xtideuniversalbios.org/svn/xtideuniversalbios

ICVM_TYPE=c-ext make run ROMS=bios-xt,ide-xt DISKS=msdos3-xtidecfg

XT IDE Notes
------------

printout:
```
-=XTIDE Universal BIOS (XT)=- @ F000h
r631 (2025-02-01)
Released under GNU GPL v2

Master at 300h: not found
Slave  at 300h: not found
Booting C»C
Error 1h!
Booting A»A
```

search for: ; XT and XT+ Build default settings ;
default mode for ide_xt.bin is DEVICE_8BIT_XTCF_PIO8 (XTCF PIO)
- ideal is probably DEVICE_8BIT_ATA, but DEVICE_8BIT_XTCF_PIO8 looks very similar
- it can be changed in the BIOS binary if needed
default port 300h

calculate checksum for the downloaded ROM:

EEPROM_GenerateChecksum
- 8 bit checksum (add each byte to an 8-bit register), then neg [al], then write the byte at the end of the ROM
BiosFile_SaveFile

boot initialization:

Initialize_AndDetectDrives
  DetectDrives_FromAllIDEControllers
    StartDetectionWithDriveSelectByteInBHandStringInCX
      DetectPrint_StartDetectWithMasterOrSlaveStringInCXandIdeVarsInCSBP
      - port is IDEVARS.wBasePort
      - prints "Master at 300h:"
      .ReadAtaInfoFromHardDisk
        Device_IdentifyToBufferInESSIwithDriveSelectByteInBH
          IdeCommand_IdentifyDeviceToBufferInESSIwithDriveSelectByteInBH
            (create fake DPT)
            IdeWait_PollStatusFlagInBLwithTimeoutInBH waiting for FLG_STATUS_BSY, so waits util BSY is clear
              IdeIO_InputStatusRegisterToAL
                IdeIO_InputToALfromIdeRegisterInDL with DL = STATUS_REGISTER_in (7) (does IN AL, 00DL = IN AL, 007h)
                  .InputToALfromRegisterInDX because AL = DEVICE_8BIT_XTCF_PIO8 which is < DEVICE_8BIT_JRIDE_ISA
              PollBsyOnly (because AH = FLG_STATUS_BSY)
            AH9h_Enable8bitModeForDevice8bitAta does nothing since device is not DEVICE_8BIT_ATA
            AH1Eh_GetCurrentXTCFmodeToAX
            AH9h_SetModeFromALtoXTCF
              AccessDPT_IsThisDeviceXTCF
              AccessDPT_SetXTCFmodeInDPTwithModeInAL
            Idepack_StoreNonExtParametersAndIssueCommandFromAL with COMMAND_IDENTIFY_DEVICE

        (currently prints g_szNotFound because CF is set after ^)
        CreateBiosTablesForHardDisk

Bitwise Test Error
==================

printf 'bitwise: [bochs] assembling ' >> /home/runner/work/vm8086/vm8086/vm8086/test-bochs/test.log
nasm -i /home/runner/work/vm8086/vm8086/vm8086/test-bochs/common -d BOCHS -f bin bitwise.asm -o obj/bitwise.bochs.bin || 	( echo "$(tput setaf 1)"FAILED"$(tput sgr0)" ; false ) >> /home/runner/work/vm8086/vm8086/vm8086/test-bochs/test.log
test_b.inc:31: error: invalid combination of opcode and operands
test_w.inc:31: error: invalid combination of opcode and operands
make[2]: *** [../test.mk:129: obj/bitwise.bochs.bin] Error 1

    mov bh, 0b_01010101
    mov byte [data], 0b_11001101
    clearf
>>> test bh, byte [data]                ; TEST REG8, MEM8
    pushf

    mov dx, 0b_01010101_11001101
    mov word [data], 0b_11001100_01010101
    clearf
>>> test dx, word [data]                ; TEST REG16, MEM16
    pushf
