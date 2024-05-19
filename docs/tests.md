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
