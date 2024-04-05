0x10000 - N

          lo c hi h+c-1
0000 0000 00 1 00 00
0001 ffff ff 0 00 ff
0002 fffe fe 0 00 ff
007f ff81 81 0 00 ff
0080 ff80 80 0 00 ff
0081 ff7f 7f 0 00 ff
00fe ff02 02 0 00 ff
00ff ff01 01 0 00 ff
0100 ff00 00 1 ff ff
0101 feff ff 0 ff fe
017f fe81 81 0 ff fe
0180 fe80 80 0 ff fe
7ffe 8002 02 0 81 80
7fff 8001 01 0 81 80
8000 8000 00 1 80 80
8001 7fff ff 0 80 7f
fffe 0002 02 0 01 00
ffff 0001 01 0 01 00

0x100 - a_lo (c)
0x100 - a_hi + c - 1

a_lo == 0:
    a_hi == 0:
        pass
    else:
        a_hi = 0x100 - a_hi
else:
    a_lo = 0x100 - a_lo
    a_hi == 0:
        pass
    else:
        a_hi = 0x100 - a_hi
    a_hi -= 1

a_hi != 0:
    a_hi = 0x100 - a_hi
a_lo != 0:
    a_lo = 0x100 - a_lo
    a_hi = a_hi - 1

12 00 01 7f 80 81 fe ff
  100 ff 81 80 7f 02 01
00  0  1  1  1  1  1  1
    1  0  0  0  0  0  0
01  0  0  1  1  1  1  1
    1  1  0  0  0  0  0
7f  0  0  0  1  1  1  1
    1  1  1  0  0  0  0
80  0  0  0  0  1  1  1
    1  1  1  1  0  0  0
81  0  0  0  0  0  1  1
    1  1  1  1  1  0  0
fe  0  0  0  0  0  0  1
    1  1  1  1  1  1  0
ff  0  0  0  0  0  0  0
    1  1  1  1  1  1  1
