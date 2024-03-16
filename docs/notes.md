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
- If we ever have macros, look at all the heavily used functions like read_b, inc_ip, mod and try them as macros.

Possible Improvements
=====================
- Support some type of sparse image, so the binary does not always have 1MB of mostly zeros.
  Make bin2obj generate an .o file with multiple sections (each with its own load address).
  It probably requires bin2obj to load the whole input and then detect runs of zeros of some minimum length.

  db  2             # number of sections
  db  0x1234        # load address of section 0
  db  0x100         # length of section 0
  ds  0x100, 0      # data of section 0
  db  0x5678        # load address of section 1
  db  0x400         # length of section 1
  ds  0x400, 0      # data of section 1
