Filtering
=========
C7 is filtered by "reg"
C8 is filtered completely

Notes
=====

27 many failed (DAA)
2F many failed (DAS)
37, 3F as well

17 one failed (49e1bb2fdf1cedfcf36c13de46ff9691318ee728)
pop ss

one failed: 50, 57, 5A, 5D

17 49e1bb2fdf1cedfcf36c13de46ff9691318ee728
===========================================

"pop ss"

+ actual - expected

  {
    ip: 33738,
    sp: 1,
+   ss: 37
-   ss: 42021
  }

actual: { regs: { ss: 37, sp: 1, ip: 33738 }, ram: [] }
expected: { regs: { ss: 42021, sp: 1, ip: 33738 }, ram: [] }

initial:
        "regs": {
            "ss": 57814,
            "sp": 65535,
        },

        "ram": [
            [253864, 38],
            [253865, 23],
            [253866, 144],
            [925024, 164],
            [990559, 37]
        ],

final:
        "regs": {
            "ss": 42021,
            "sp": 1,
        },

 38=0x26 ES:
 23=0x17 POP SS
144=0x90 NOP

164=0xa4 

 37=0x25 

42021=0xa425

pop where the value is on segment border, clearly the but is not wrapping SP between the bytes

3E 3093506565e4803bf150e0e36d3e846edb6f1c3a
===========================================

/tmp/vm8086-XXXXXXq4HkVY/3093506565e4803bf150e0e36d3e846edb6f1c3a

cmp dl, byte [cs:bx+di]

[278856, 46], 2e  CS:
[278857, 58], 3a  0011 1010   CMP d=1 w=0
[278858, 17], 11  00 010 001  MOD=memory, no displacement; REG=DL; R/M=BX+DI
[278859, 10], 0a

3A MOD REG R/M (DISP-LO) (DISP-HI)
CMP REG8 REG8/MEM8

bug:
I believe in file 3A.json the test case 3093506565e4803bf150e0e36d3e846edb6f1c3a has a bug:
The initial RAM for this test case is:
        "ram": [
            [278856, 46],
            [278857, 58],
            [278858, 17],
            [278859, 10],
            [278860, 144],
            [278861, 144]
        ],

Which decodes to:

 46=0x2E ->              CS: (prefix)
 58=0x3A -> 0011 1010    CMP with d=1 w=0
 17=0x11 -> 00 010 001   MOD=memory, no displacement; REG=DL; R/M=BX+DI
 10=0x0a -> ???
144=0x90 -> NOP
144=0x90 -> NOP

The CMP instruction is only 3 bytes long, because MOD=00 means there is no displacement.
The byte afterwards - [278859, 10] - starts another instruction with opcode 0x0A, which would be OR.

When I'm testing my VM, decodes this OR instruction as 4 bytes long, so it "eats" the next 4 bytes of code, and it never encounters a NOP instruction.

I believe the correct initial RAM should be:
        "ram": [
            [278856, 46],
            [278857, 58],
            [278858, 17],
            [278859, 144],    <--- this value is changed
            [278860, 144],
            [278861, 144]
        ],

Thank you very much for your test cases! They're extremely useful, and it is a miracle that something like this is freely available.

5B
==

bug:
baf64ec03e2a347afebd39642fb5ee4a32574da0
/tmp/vm8086-XXXXXXht2uu9/baf64ec03e2a347afebd39642fb5ee4a32574da0

"pop bx"

        "ram": [
            [586898, 91],
            [586899, 126],
            [586900, 250]
        ],

misses the NOP

 91=0x5B -> POP BX
126=0x7E -> JNG SHORT-LABEL
250=0xFA -> IP-INC8

they are trying to pop FA7E into BX, clearly

should be
        "ram": [
            [586898, 91],
            [586898, 144],
            [586901, 250]
        ],
        + adjust bx by 144-126, since we will be poping a different number (low byte is taken from the NOP)

? but strange that the data is so close to instruction, perhaps it's intentional
they might not consider it a bug, but: "All bytes after the initial instruction bytes are set to 0x90 (144) (NOP)."

70
==

bug:
fdd4d9a8227ea4b1edc23c8ba00a87b488aab656 /tmp/vm8086-XXXXXXMlQ0jt/fdd4d9a8227ea4b1edc23c8ba00a87b488aab656

"jo 0000h"

"flags": 64707=0xFCC3=0b_1111_1100_1100_0011
OF=1

        "ram": [
            [635861, 46],
            [635862, 112],
            [635863, 253],
            [635864, 144]
        ],

 46=0x2e CS: (prefix)
112=0x70 JO SHORT-LABEL
253=0xfd IP-INC8
144=0x90 NOP

Description says JO 0000h, and it is encoding JO 0xfd, which is jump backwards by -3. This creates and endless loop, the NOP never gets executed.

(I verified the my VM is actually looping on JO).

bug:

3214d182b8baae08fcfb75642416725e22abd357 /tmp/vm8086-XXXXXXyoVUpe/3214d182b8baae08fcfb75642416725e22abd357
same as above, also jo 0000h

bug:
50e1fb3e0778912b4efe4b7dbff2800978499c36 jo 0001h

8E
==

e85bdbc0b719a815caff37ac8ac02711fb56aeb7 /tmp/vm8086-XXXXXXhx3RiR/e85bdbc0b719a815caff37ac8ac02711fb56aeb7

"mov cs, word [ss:bp+di+50h]"
"bytes": [142, 75, 80],

        "regs": {
            "ax": 21153,
            "bx": 59172,
            "cx": 33224,
            "dx": 61687,
            "cs": 12781,
            "ss": 7427,
            "ds": 600,
            "es": 52419,
            "sp": 49014,
            "bp": 9736,
            "si": 52001,
            "di": 10025,
            "ip": 694,
            "flags": 62546
        },

        "ram": [
            [138673, 100],
            [138674, 144],
            [205190, 142],
            [205191, 75],
            [205192, 80],
            [205193, 144],
            [205194, 144]
        ],

100=0x64
144=0x90

142=0x8e MOV SEGREG,REG16/MEM16
 75=0x4b MOD 0SR R/M 01 001 011     MOD=memory mode, 8-bit displacement; SR=CS; R/M=BP+DI
 80=0x50 (DISP-LO)                  DISP=0x50
144=0x90 NOP
144=0x90 NOP

mov cs, word [ss:bp+di+50h]
            "ss": 7427,         0x1d03
            "bp": 9736,         0x2608
            "di": 10025,        0x2729

mov cs, word [0x1d03:0x2608+0x2729+0x0050]
mov cs, word [0x1d03:0x4d81]
mov cs, word [0x1d03 * 0x10 + 0x4d81]
mov cs, word [0x21db1]

0x21db1 = 138673

mov cs, 0x9064

0x9064 = 36964

next instruction is:
0x9064:ip = 0x9064:697 = 0x9064:0x0296 = 0x9064 * 0x10 + 0x02b9 = 0x908F9 = 592121

It jumps (using mov cs) to address 0x9064:ip = 592118, which does not contain a NOP.

fix: Change 0x21db1 to contain a NOP

        "ram": [
            [138673, 100],
            [138674, 144],
            [205190, 142],
            [205191, 75],
            [205192, 80],
            [205193, 144],
            [205194, 144],
            [592121, 144]           <--- added
        ],


bug:
b5463ccac25f40ef9ec4b67d817bbd9014cf2dda /tmp/vm8086-XXXXXXjhcdRw/b5463ccac25f40ef9ec4b67d817bbd9014cf2dda

00 dc1341932faabf1e04f5aef1ffd78ccf2894eb51
===========================================

"add byte [ds:si-20FCh], al"

    "initial": {
        "regs": {
            "ax": 58491,
            "ds": 64513,
            "si": 4789,
            "flags": 64662
        },
        "ram": [
            [45513, 3],
            [1022667, 0],
            [1022668, 132],
            [1022669, 4],
            [1022670, 223],
            [1022671, 144],
            [1022672, 144],
            [1022673, 144]
        ],

bug: does not update address 45513 (likely updates a different address)

  0=0x00  ADD REG8 MEM8, REG8
132=0x84  MOD REG R/M 10 000 100     MOD=mem16, REG=AL, R/M=SI
  4=0x04  DISP=0xDF04
223=0xdf

seg = DS = 64513 = 0xfc01
off = 4789 + 0xDF04 = 0x12B5 + 0xDF04 = 0xF1B9 = 61881

addr = 0xfc01 * 0x10 + 0xF1B9 = 0x10b1c9 = 1094089
mod 2^20 = 0x0b1c9 = 45513

Possibly caused by missing wrapping in 8-bit locations.

A4 429
======

node test.js -f A4 -i 429 -e
be7487fbf0e1032110946e85dc69f435c05623eb

actual      [ 9, 190 ]          [ '0009', 'be' ]
expected    [ 1048575, 55 ]     [ 'fffff', '37' ]

    "name": "cs rep movsb",
    "bytes": [46, 243, 164],
    "initial": {
        "regs": {
            "ax": 19174,
            "bx": 56636,
            "cx": 34,
            "dx": 50904,
            "cs": 58344,
            "ss": 55729,
            "ds": 50256,
            "es": 61802,
            "sp": 49330,
            "bp": 24336,
            "si": 28260,
            "di": 59731,
            "ip": 50921,
            "flags": 61522
        },

prints ram like this:

    ram: [
      [ 0, 9 ],         [ 1, 149 ],       [ 2, 112 ],
      [ 3, 152 ],       [ 4, 86 ],        [ 5, 3 ],
      [ 6, 174 ],       [ 7, 67 ],        [ 8, 202 ],
      [ 9, 190 ],       [ 10, 188 ],      [ 11, 251 ],
      [ 12, 20 ],       [ 13, 5 ],        [ 14, 165 ],
      [ 15, 37 ],       [ 16, 85 ],       [ 17, 178 ],
      [ 18, 241 ],      [ 19, 45 ],       [ 20, 79 ],
      [ 1048563, 246 ], [ 1048564, 100 ], [ 1048565, 25 ],
      [ 1048566, 39 ],  [ 1048567, 104 ], [ 1048568, 115 ],
      [ 1048569, 250 ], [ 1048570, 157 ], [ 1048571, 13 ],
      [ 1048572, 248 ], [ 1048573, 220 ], [ 1048574, 201 ],
      [ 9, 190 ]
    ]

address 9 is printed twice, the last item should be [ 1048575, 55 ]
X hypothesis: the instruction works, the test output code has a bug when printing address 0xfffff

re-run after fix: A4, A5, AA, AB, C4

hypothesis: the instruction overwrites last byte of the input, which is 1048575
it's trying to write 9 to memory location 0, but it seems it writes it to memory location -1

actually, probably we set up the memory wrong, it starts at the last byte of input

confirmed that moving [mem] one address up solves the problem

FF.3 e05f59d79804b51a8a9fa738597bc7528712b1e5
=============================================

    "name": "callf word [ss:bp+si-64h]",
    "bytes": [255, 90, 156],
    "initial": {
        "regs": {
            "cs": 8178,
            "ss": 27703,
            "bp": 27342,
            "si": 52052,
            "ip": 9753,
        },
        "ram": [
            [140601, 255],
            [140602, 90],
            [140603, 156],
            [140604, 144],
            [140605, 144],
            [140606, 144],
            [140607, 144],
            [182502, 144],
            [457006, 134],
            [457007, 35],
            [457008, 86],
            [457009, 42]
        ],
    },
    "final": {
        "regs": {
            "cs": 10838,
            "ip": 9094
        },
        "ram": [
            [457003, 28],
            [457004, 38],
            [457005, 242],
            [457006, 31]
        ],
        "queue": []
    },

FF 255              group
5A  90 01 011 010   CALLF MEM16, MOD=mem 8-bit disp, R/M=BP+SI+DISP8
9C 156              DISP8

0x9C = -100
BP+SI+DISP8 = 27342 + 52052 - 100 = 79294 = 0x135BE
mod 2^16 = 0x35BE = 13758

SS<<4+^^ = 27703 * 16 + 13758 = 457006 = 0x6F92E

IP = 134+35*256 = 9094 = 0x2386
CS = 86+42*256 = 10838 = 0x2A56

actual:     ip: 8991 = 0x231f
expected:   ip: 9094 = 0x2386

hypothesis: stack overlaps with the CS:IP parameter of CALLF, so pushing current CS:IP overwrites the parameter

cs     = 8178 = 0x1FF2 = 242 31
ip + 3 = 9756 = 0x261C = 28 38

3F 8f6cb1eaaeaae5cbb1a8ab0a6cc2ddb4b3096d5e
===========================================

    "name": "aas",
    "bytes": [46, 63],
    "initial": {
        "regs": {
            "ax": 19200,
            "ip": 57474,
            "flags": 61650
        },
    },
    "final": {
        "regs": {
            "ax": 18954,
            "ip": 57476,
            "flags": 61591
        },
    },

 46 0x2e CS:
 63 0x3f AAS

19200 = 0x4B00
18954 = 0x4A0A expected
18698 = 0x490A actual

61650 = 11110000 11010010                       AF=1
61591 = 11110000 10010111 expected/actual

AL = 00

AX = AX - 6             0x4AFA
AH = AH - 1             0x49FA
AL = AL AND 0FH         0x490A

AL = AL - 6             0x4BFA
AH = AH - 1             0x4AFA
AL = AL AND 0FH         0x4A0A

27 8baa9594db1ba7a53ff4f4eaeb3141f7a27538be
===========================================

AX:
0xa39e input
0xa304 actual
0xa3a4 expected
AF=1
CF=0

AL AND 0Fh > 9 or AF=1 true

AL = AL + 06h = 9eh + 6h = a4h
CF=0 (old_CF=0, carry from ^=0)

old_AL > 99h false
old_Al = 9eh

AL = AL + 60h = a4h + 60h = 104h = 04h
CF=1

hypothesis: the documented algorithm is wrong, should not compare with 0x99, but 0x9f
(still does not work, fixes some cases and breaks others)

hypothesis: the documented algorithm is wrong, it breaks when 9a <= AL <= 9f, the result calculated differs in top nibble of AL (expected 9x, actual 0x)

all broken cases have AF=1 CF=0

9e -> a4 (not 04)

9 14 -> 10 4

-
AMD algorithm:
0xa39e,AF=1,CF=0

AL.l > 9h -> AL += 06h; AL = a4
ALorig > 99h -> AL += 60H; AL = 104 = 04

8C 3fa82cae1779fd13594b785fe8402218616b81c9
===========================================

    "name": "mov word [ss:bp+di+7Ch], cs",
    "bytes": [54, 140, 107, 124],

 54 = 0x36                      SS
140 = 0x8c                      MOV REG16/MEM16,SEGREG
107 = 0x6b = 01 101 011         (not used) MOD=mem 8-bit disp; SR=CS; R/M=BP+DI+DISP8
124 = 0x7c                      DISP8

caused by specifying MOD 1SR R/M, only 0SR is documented as valid but 1SR also works on real hardware

F6.7 idx: 1132 hash: b790653530d6a41cc6593b37876848e828a3015b

+ actual - expected

  {
+   ax: 7320,
+   ip: 40161
-   ax: 7272,
-   ip: -1008415
  }

The IP values need to be increased by 0x100000
https://github.com/SingleStepTests/8088/issues/1

IDIV 8-bit
==========

AX/op -> q=AL, r=AH

idx:

0, 68, 77, 81, 140, 183, 286, 288, 363, 406, 565, 654, 788, 803, 831, 907, 976, 1132, 1159, 1157, 1729, 1731, 1765, 1929, 2013, 2028, 2045, 2065, 2073, 2119, 2394, 2426, 2579, 2629, 2634, 2650, 2645, 2687, 2688, 2712, 2729, 2757, 2776, 2786, 2947, 2988, 3043, 3114, 3205, 3225, 3257, 3272, 3288, 3316, 3356, 3380, 3416, 3458, 3513, 3583, 3647, 3657, 3716, 3730, 3858, 3899, 3972, 4065, 4106, 4125, 4146, 4182, 4205, 4315, 4396, 4421, 4576, 4640, 4802, 4891, 5010, 5019, 5088, 5100, 5182, 5189, 5198, 5491, 5510, 5536, 5542, 5574, 5673, 5938, 6032, 6058, 6165, 6188, 6218, 6256, 6266, 6289, 6367, 6544, 6562, 6632, 6656, 6866, 6922, 6970, 7028, 7086, 7090, 7196, 7220, 7262, 7350, 7545, 7567, 7586, 7600, 7661, 7794, 7917, 7933, 8044, 8110, 8122, 8229, 8443, 8586, 8670, 8708, 8719, 8831, 8876, 8961, 8965, 8996, 8998, 9040, 9082, 9096, 9107, 9138, 9193, 9458, 9475, 9479, 9496, 9514, 9576, 9697, 9702, 9704, 9707, 9746, 9803, 9902, 9968

-> quotient is sometimes 100-quotient, why?

REP IDIV/IMUL negates the result:
http://www.righto.com/2023/07/undocumented-8086-instructions.html
https://www.reenigne.org/blog/8086-microcode-disassembled/

IDIV 16-bit
===========

F7.7: 1126, 8502

1126

actual:   {
  regs: {
    cs: '0000 (0)',
    sp: 'ffff (65535)',
    ip: '0400 (1024)',
    flags: 'f002 ----░dit ░░-░-░-░ (61442)'
  },
  ram: [
    [ 'ea300 (959232)', '22 (34)' ],
    [ 'ea301 (959233)', 'fd (253)' ],
    [ 'ea302 (959234)', 'a9 (169)' ],
    [ 'ea303 (959235)', '82 (130)' ] x
  ]
}
expected: {
  regs: {
    cs: '0000 (0)',
    sp: 'ffff (65535)',
    ip: '0400 (1024)',
    flags: 'f002 ----░dit ░░-░-░-░ (61442)'
  },
  ram: [
    [ 'ea300 (959232)', '22 (34)' ],
    [ 'ea301 (959233)', 'fd (253)' ],
    [ 'ea302 (959234)', 'a9 (169)' ],
    [ 'ea303 (959235)', '02 (2)' ] x
  ]
}

file:
    "final": {
        "regs": {
            "cs": 0,
            "sp": 65535,
            "ip": 1024,
            "flags": 61442
        },
        "ram": [
            [959232, 34],
            [959233, 253],
            [959234, 169],
            [959235, 2],
            [959236, 240],
            [1024767, 229]
        ],
        "queue": []
    },

-> adjustment in test.js deletes wrong records when trying to remove flags from stack

8502

actual:   {
  regs: {
    cs: '0000 (0)',
    sp: 'fffc (65532)',
    ip: '0400 (1024)',
    flags: 'f002 ----░dit ░░-░-░-░ (61442)'
  },
  ram: [
    [ 'b78a0 (751776)', '16 (22)' ], x
    [ 'b78a1 (751777)', 'f8 (248)' ], x
    [ 'c789c (817308)', 'c3 (195)' ],
    [ 'c789d (817309)', 'ab (171)' ]
  ]
}
expected: {
  regs: {
    cs: '0000 (0)',
    sp: 'fffc (65532)',
    ip: '0400 (1024)',
    flags: 'f002 ----░dit ░░-░-░-░ (61442)'
  },
  ram: [
    [ 'b78a0 (751776)', '86 (134)' ], x
    [ 'b78a1 (751777)', 'f0 (240)' ], x
    [ 'c789c (817308)', 'c3 (195)' ],
    [ 'c789d (817309)', 'ab (171)' ]
  ]
}

file:
        "ram": [
            [751776, 134],
            [751777, 240],
            [817308, 195],
            [817309, 171],
            [817310, 123],
            [817311, 158]
        ],
        "queue": []

IDIV 8-bit
==========

missed #DE

788: idiv byte [es:bp+si+6Ah]

ax: 1f24
op: c2 ?

-> docs say quotient 0x80 (and 0x8000) is not valid, even if the result is supposed to be negative
