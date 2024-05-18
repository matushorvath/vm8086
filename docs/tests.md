Filtering
=========
C7 is filtered by "reg"
C8 is filtered completely

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

bug (TBD):
baf64ec03e2a347afebd39642fb5ee4a32574da0
/tmp/vm8086-XXXXXXht2uu9/baf64ec03e2a347afebd39642fb5ee4a32574da0

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
