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

- Use macros for inc_ip, inc_2_sp, dec_2_sp, execute_inc, execute_dec. The same algorithm is in many places.
- Use macros for all the arg_* functions, there's a lot of copy pasta there.
- Optimize read_cs_ip_* to call read_b directly, to avoid multiple function calls.
- Look at the most used path in decode_mod_rm, make sure it is fast. It could even be handled by a single 256 byte table,
  no 8-bit splitting needed and much fewer conditions.
- If we ever have macros, look at all the heavily used functions like read_b, inc_ip, modulo and try them as macros.

- Use a second level table for decoding the group instructions
  e.g. exec_fn, args_fn, N           means call it directly
       second_level_table, -1, -1   means split away the MOD, go through a second level table
  The second level table would allow its own args_fn to handle instructions with strange parameter count

- Avoid args_fn as much as possible, I think the whole locations concept is eating too much performance.
  Wait for performance measurements first.

Emulators
=========

https://i8086emu.sourceforge.net/
https://github.com/YJDoc2/8086-Emulator/
https://github.com/adriancable/8086tiny
https://bochs.sourceforge.io/
https://github.com/86Box/86Box
