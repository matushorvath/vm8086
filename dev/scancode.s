.EXPORT scancode

# TODO support more keys

# 0x1d = ctrl
# 0x2a = left shift
# 0x36 = right shift
# 0x37 = print screen
# 0x38 = alt
# 0x3a = caps lock
# 0x45 = num lock
# 0x46 = scroll lock

# 1b 5b 5a = shift+tab
# 0a = ctrl+enter

# 0x3b-0x44 = f1-f10
#
# 1b 4f 50 = f1
# 1b 4f 51 = f2
# 1b 4f 52 = f3
# 1b 4f 53 = f4
#
# 1b 5b 31 35 7e = f5
# 1b 5b 31 37 7e = f6
# 1b 5b 31 38 7e = f7
# 1b 5b 31 39 7e = f8
#
# 1b 5b 32 30 7e = f9
# 1b 5b 32 31 7e = f10

# 0x47-0x53 = num pad: 789- 456+ 123 ins del
#
# 1b 5b 41 up
# 1b 5b 42 down
# 1b 5b 44 left
# 1b 5b 43 right
# (but check these on numeric keyboard)

scancode:
    ds  9, 0                            # 0-8
    ds  9, 0
    ds  9, 0

    db  0, 0x0f, 0x8f                   # 9 tab

    ds  3, 0                            # 10-12
    ds  3, 0
    ds  3, 0

    db  0, 0x1c, 0x9c                   # 13 enter

    ds  18, 0                           # 14-31
    ds  18, 0
    ds  18, 0

    db  0, 0x39, 0xb9                   # 32 space
    db  1, 0x02, 0x82                   # 33 !
    db  1, 0x28, 0xa8                   # 34 "
    db  1, 0x04, 0x84                   # 35 #
    db  1, 0x05, 0x85                   # 36 $
    db  1, 0x06, 0x86                   # 37 %
    db  1, 0x08, 0x88                   # 38 &
    db  0, 0x28, 0xa8                   # 39 '
    db  1, 0x0a, 0x8a                   # 40 (
    db  1, 0x0b, 0x8b                   # 41 )
    db  1, 0x09, 0x89                   # 42 *
    db  1, 0x0d, 0x0d                   # 43 +
    db  0, 0x33, 0xb3                   # 44 ,
    db  0, 0x0c, 0x8c                   # 45 -
    db  0, 0x34, 0xb4                   # 46 .
    db  0, 0x35, 0xb5                   # 47 /
    db  0, 0x0b, 0x8b                   # 48 0
    db  0, 0x02, 0x82                   # 49 1
    db  0, 0x03, 0x83                   # 50 2
    db  0, 0x04, 0x84                   # 51 3
    db  0, 0x05, 0x85                   # 52 4
    db  0, 0x06, 0x86                   # 53 5
    db  0, 0x07, 0x87                   # 54 6
    db  0, 0x08, 0x88                   # 55 7
    db  0, 0x09, 0x89                   # 56 8
    db  0, 0x0a, 0x8a                   # 57 9
    db  1, 0x27, 0xa7                   # 58 :
    db  0, 0x27, 0xa7                   # 59 ;
    db  1, 0x33, 0xb3                   # 60 <
    db  0, 0x0d, 0x8d                   # 61 =
    db  1, 0x34, 0xb4                   # 62 >
    db  1, 0x35, 0xb5                   # 63 ?
    db  1, 0x03, 0x83                   # 64 @
    db  1, 0x1e, 0x9e                   # 65 A
    db  1, 0x30, 0xb0                   # 66 B
    db  1, 0x2e, 0xae                   # 67 C
    db  1, 0x20, 0xa0                   # 68 D
    db  1, 0x12, 0x92                   # 69 E
    db  1, 0x21, 0xa1                   # 70 F
    db  1, 0x22, 0xa2                   # 71 G
    db  1, 0x23, 0xa3                   # 72 H
    db  1, 0x17, 0x97                   # 73 I
    db  1, 0x24, 0xa4                   # 74 J
    db  1, 0x25, 0xa5                   # 75 K
    db  1, 0x26, 0xa6                   # 76 L
    db  1, 0x32, 0xb2                   # 77 M
    db  1, 0x31, 0xb1                   # 78 N
    db  1, 0x18, 0x98                   # 79 O
    db  1, 0x19, 0x99                   # 80 P
    db  1, 0x10, 0x90                   # 81 Q
    db  1, 0x13, 0x93                   # 82 R
    db  1, 0x1f, 0x9f                   # 83 S
    db  1, 0x14, 0x94                   # 84 T
    db  1, 0x16, 0x96                   # 85 U
    db  1, 0x2f, 0xaf                   # 86 V
    db  1, 0x11, 0x91                   # 87 W
    db  1, 0x2d, 0xad                   # 88 X
    db  1, 0x15, 0x95                   # 89 Y
    db  1, 0x2c, 0xac                   # 90 Z
    db  0, 0x1a, 0x9a                   # 91 [
    db  0, 0x2b, 0xab                   # 92 \
    db  0, 0x1b, 0x9b                   # 93 ]
    db  1, 0x07, 0x87                   # 94 ^
    db  1, 0x0c, 0x8c                   # 95 _
    db  0, 0x29, 0xa9                   # 96 `
    db  0, 0x1e, 0x9e                   # 97 a
    db  0, 0x30, 0xb0                   # 98 b
    db  0, 0x2e, 0xae                   # 99 c
    db  0, 0x20, 0xa0                   # 100 d
    db  0, 0x12, 0x92                   # 101 e
    db  0, 0x21, 0xa1                   # 102 f
    db  0, 0x22, 0xa2                   # 103 g
    db  0, 0x23, 0xa3                   # 104 h
    db  0, 0x17, 0x97                   # 105 i
    db  0, 0x24, 0xa4                   # 106 j
    db  0, 0x25, 0xa5                   # 107 k
    db  0, 0x26, 0xa6                   # 108 l
    db  0, 0x32, 0xb2                   # 109 m
    db  0, 0x31, 0xb1                   # 110 n
    db  0, 0x18, 0x98                   # 111 o
    db  0, 0x19, 0x99                   # 112 p
    db  0, 0x10, 0x90                   # 113 q
    db  0, 0x13, 0x93                   # 114 r
    db  0, 0x1f, 0x9f                   # 115 s
    db  0, 0x14, 0x94                   # 116 t
    db  0, 0x16, 0x96                   # 117 u
    db  0, 0x2f, 0xaf                   # 118 v
    db  0, 0x11, 0x91                   # 119 w
    db  0, 0x2d, 0xad                   # 120 x
    db  0, 0x15, 0x95                   # 121 y
    db  0, 0x2c, 0xac                   # 122 z
    db  1, 0x1a, 0x9a                   # 123 {
    db  1, 0x2b, 0xab                   # 124 |
    db  1, 0x1b, 0x9b                   # 125 }
    db  1, 0x29, 0xa9                   # 126 ~
    db  0, 0x0e, 0x8e                   # 127 backspace

    ds  128, 0                          # ASCII 127-255
    ds  128, 0
    ds  128, 0

.EOF
