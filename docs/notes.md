Decoding
========

Instruction set 2-51 p70  
Instruction encoding 4-22 p259  

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

Possible Optimizations
======================

- Use macros for inc_ip_b, inc_ip_w, inc_sp_w, dec_sp_w, execute_inc, execute_dec, read_b, write_b. The same algorithm is in many places.
- Use macros for all the arg_* functions, there's a lot of copy pasta there.
- Look at the most used path in decode_mod_rm, make sure it is fast.

- Use a second level table for decoding the group instructions
  e.g. exec_fn, args_fn, N           means call it directly
       second_level_table, -1, -1   means split away the MOD, go through a second level table
  The second level table would allow its own args_fn to handle instructions with strange parameter count

- Optimize physical address calculation (calc_seg_off_addr_*), it's very heavy and used a lot.


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
