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
- Optimize read_cs_ip_* to call read_b directly, to avoid multiple function calls.
- Look at the most used path in decode_mod_rm, make sure it is fast.

- Use a second level table for decoding the group instructions
  e.g. exec_fn, args_fn, N           means call it directly
       second_level_table, -1, -1   means split away the MOD, go through a second level table
  The second level table would allow its own args_fn to handle instructions with strange parameter count

- Avoid args_fn as much as possible, I think the whole locations concept is eating too much performance.
  Wait for performance measurements first.
- read_cs_ip_b is quite heavy (because of calc_cs_ip_addr mostly) and seems to be used a lot, try to optimize

To analyze:
add.s
bitwise.s
decode.s
group1.s
group2.s
group_immed.s
inc_dec.s
location.s
sub_cmp.s

Times:
baseline:
real    0m30.908s
user    0m30.710s
sys     0m0.205s

after removing modulo:
real    0m27.808s
user    0m27.585s
sys     0m0.234s

Emulators
=========

https://i8086emu.sourceforge.net/
https://github.com/YJDoc2/8086-Emulator/
https://github.com/adriancable/8086tiny
https://bochs.sourceforge.io/
https://github.com/86Box/86Box


Tests for 8086
==============

https://github.com/TomHarte/ProcessorTests  
https://github.com/SingleStepTests/8088  
https://github.com/barotto/test386.asm  
https://github.com/xoreaxeaxeax/sandsifter  
https://www.pcjs.org/software/pcx86/test/cpu/  


Results
=======

- Freeze:
  - 3A
    - 3093506565e4803bf150e0e36d3e846edb6f1c3a
  - 53
- OOM: 5B
- few failed: 40-4F, 50, 5A, 57, 17
- no passed: 54, 0F, 
- slow: ?


Filtering
=========
C7 is filtered by "reg"
C8 is filtered completely
