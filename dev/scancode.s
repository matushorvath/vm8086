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

    db  1, 0x0f, 0x8f                   # 9 tab

    ds  3, 0                            # 10-12
    ds  3, 0
    ds  3, 0

    db  1, 0x1c, 0x9c                   # 13 enter

    ds  18, 0                           # 14-31
    ds  18, 0
    ds  18, 0

    db  1, 0x39, 0xb9                   # 32 space
    db  2, 0x02, 0x82                   # 33 !
    db  2, 0x28, 0xa8                   # 34 "
    db  2, 0x04, 0x84                   # 35 #
    db  2, 0x05, 0x85                   # 36 $
    db  2, 0x06, 0x86                   # 37 %
    db  2, 0x08, 0x88                   # 38 &
    db  1, 0x28, 0xa8                   # 39 '
    db  2, 0x0a, 0x8a                   # 40 (
    db  2, 0x0b, 0x8b                   # 41 )
    db  2, 0x09, 0x89                   # 42 *
    db  2, 0x0d, 0x0d                   # 43 +
    db  1, 0x33, 0xb3                   # 44 ,
    db  1, 0x0c, 0x8c                   # 45 -
    db  1, 0x34, 0xb4                   # 46 .
    db  1, 0x35, 0xb5                   # 47 /
    db  1, 0x0b, 0x8b                   # 48 0
    db  1, 0x02, 0x82                   # 49 1
    db  1, 0x03, 0x83                   # 50 2
    db  1, 0x04, 0x84                   # 51 3
    db  1, 0x05, 0x85                   # 52 4
    db  1, 0x06, 0x86                   # 53 5
    db  1, 0x07, 0x87                   # 54 6
    db  1, 0x08, 0x88                   # 55 7
    db  1, 0x09, 0x89                   # 56 8
    db  1, 0x0a, 0x8a                   # 57 9
    db  2, 0x27, 0xa7                   # 58 :
    db  1, 0x27, 0xa7                   # 59 ;
    db  2, 0x33, 0xb3                   # 60 <
    db  1, 0x0d, 0x8d                   # 61 =
    db  2, 0x34, 0xb4                   # 62 >
    db  2, 0x35, 0xb5                   # 63 ?
    db  2, 0x03, 0x83                   # 64 @
    db  2, 0x1e, 0x9e                   # 65 A
    db  2, 0x30, 0xb0                   # 66 B
    db  2, 0x2e, 0xae                   # 67 C
    db  2, 0x20, 0xa0                   # 68 D
    db  2, 0x12, 0x92                   # 69 E
    db  2, 0x21, 0xa1                   # 70 F
    db  2, 0x22, 0xa2                   # 71 G
    db  2, 0x23, 0xa3                   # 72 H
    db  2, 0x17, 0x97                   # 73 I
    db  2, 0x24, 0xa4                   # 74 J
    db  2, 0x25, 0xa5                   # 75 K
    db  2, 0x26, 0xa6                   # 76 L
    db  2, 0x32, 0xb2                   # 77 M
    db  2, 0x31, 0xb1                   # 78 N
    db  2, 0x18, 0x98                   # 79 O
    db  2, 0x19, 0x99                   # 80 P
    db  2, 0x10, 0x90                   # 81 Q
    db  2, 0x13, 0x93                   # 82 R
    db  2, 0x1f, 0x9f                   # 83 S
    db  2, 0x14, 0x94                   # 84 T
    db  2, 0x16, 0x96                   # 85 U
    db  2, 0x2f, 0xaf                   # 86 V
    db  2, 0x11, 0x91                   # 87 W
    db  2, 0x2d, 0xad                   # 88 X
    db  2, 0x15, 0x95                   # 89 Y
    db  2, 0x2c, 0xac                   # 90 Z
    db  1, 0x1a, 0x9a                   # 91 [
    db  1, 0x2b, 0xab                   # 92 \
    db  1, 0x1b, 0x9b                   # 93 ]
    db  2, 0x07, 0x87                   # 94 ^
    db  2, 0x0c, 0x8c                   # 95 _
    db  1, 0x29, 0xa9                   # 96 `
    db  1, 0x1e, 0x9e                   # 97 a
    db  1, 0x30, 0xb0                   # 98 b
    db  1, 0x2e, 0xae                   # 99 c
    db  1, 0x20, 0xa0                   # 100 d
    db  1, 0x12, 0x92                   # 101 e
    db  1, 0x21, 0xa1                   # 102 f
    db  1, 0x22, 0xa2                   # 103 g
    db  1, 0x23, 0xa3                   # 104 h
    db  1, 0x17, 0x97                   # 105 i
    db  1, 0x24, 0xa4                   # 106 j
    db  1, 0x25, 0xa5                   # 107 k
    db  1, 0x26, 0xa6                   # 108 l
    db  1, 0x32, 0xb2                   # 109 m
    db  1, 0x31, 0xb1                   # 110 n
    db  1, 0x18, 0x98                   # 111 o
    db  1, 0x19, 0x99                   # 112 p
    db  1, 0x10, 0x90                   # 113 q
    db  1, 0x13, 0x93                   # 114 r
    db  1, 0x1f, 0x9f                   # 115 s
    db  1, 0x14, 0x94                   # 116 t
    db  1, 0x16, 0x96                   # 117 u
    db  1, 0x2f, 0xaf                   # 118 v
    db  1, 0x11, 0x91                   # 119 w
    db  1, 0x2d, 0xad                   # 120 x
    db  1, 0x15, 0x95                   # 121 y
    db  1, 0x2c, 0xac                   # 122 z
    db  2, 0x1a, 0x9a                   # 123 {
    db  2, 0x2b, 0xab                   # 124 |
    db  2, 0x1b, 0x9b                   # 125 }
    db  2, 0x29, 0xa9                   # 126 ~
    db  1, 0x0e, 0x8e                   # 127 backspace

    ds  128, 0                          # ASCII 127-255
    ds  128, 0
    ds  128, 0

.EOF
