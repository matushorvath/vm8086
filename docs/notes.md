Decoding
========

Instruction set 2-51 p70  
Instruction encoding 4-22 p259

Reset
=====

FFFF0H through FFFFFH (16 bytes) system reset
2-29

```
CPU COMPONENT CONTENT
Flags Clear
Instruction Pointer OOOOH
CS Register FFFFH
DS Register OOOOH
SS Register OOOOH
ES Register OOOOH
Queue Empty
```

first instruction is FFFF0H

Memory
======

```
00H through 7FH (128 bytes) interrupt (system + reserved)
+80H - 3FFH (available)
1k memory total, 256 interrupts
00, 01: IP offset
02, 03: CS base address
```

```
IO:
F8H through FFH (eight of the 64k locations) in the I/O space are reserved by Intel Corporation for use by future Intel hardware
```
