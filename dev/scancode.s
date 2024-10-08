.EXPORT scancode

# TODO support more keys

# unsupported scan codes:
# 0x1d = ctrl
# 0x2a = left shift
# 0x36 = right shift
# 0x37 = print screen
# 0x38 = alt
# 0x3a = caps lock
# 0x45 = num lock
# 0x46 = scroll lock
# 0x4a = num pad -
# 0x4e = num pad +

# unsupported ANSI sequences:
# 1b 5b 5a = shift+tab
# 0a = ctrl+enter

# Alt+??: 1b ?? for many keys (including '[' = 5b, which conflicts with many escape sequences)

#       u d r l  1b 5b          41  1b 5b          42  1b 5b          43 1b  5b          44
# shift u d r l  1b 5b 31 3b 32 41  1b 5b 31 3b 32 42  1b 5b 31 3b 32 43 1b  5b 31 3b 32 44
# ctrl  u d r l  1b 5b 31 3b 35 41  1b 5b 31 3b 35 42  1b 5b 31 3b 35 43 1b  5b 31 3b 35 44
# alt   u d r l  1b 5b 31 3b 33 41  1b 5b 31 3b 33 42  1b 5b 31 3b 33 43 1b  5b 31 3b 33 44
# c+a   u d r l  1b 5b 31 3b 37 41  1b 5b 31 3b 37 42  1b 5b 31 3b 37 43 1b  5b 31 3b 37 44

#       f1-4   1b 4f          50  1b 4f          51  1b 4f          52  1b 4f          53
# shift f1-4   1b 5b 31 3b 32 50  1b 5b 31 3b 32 51  1b 5b 31 3b 32 52  1b 5b 31 3b 32 53
# ctrl  f1-4   1b 5b 31 3b 35 50  1b 5b 31 3b 35 51  1b 5b 31 3b 35 52  1b 5b 31 3b 35 53
# alt   f1-4   1b 5b 31 3b 33 50  1b 5b 31 3b 33 51  1b 5b 31 3b 33 52
# c+a   f1-4   1b 5b 31 3b 37 50  1b 5b 31 3b 37 51  1b 5b 31 3b 37 52

#       f5-10  1b 5b 31 35       7e  1b 5b 31 37       7e  1b 5b 31 38       7e  1b 5b 31 39       7e  1b 5b 32 30       7e  1b 5b 32 31       7e
# shift f5-10  1b 5b 31 35 3b 32 7e  1b 5b 31 37 3b 32 7e  1b 5b 31 38 3b 32 7e  1b 5b 31 39 3b 32 7e  1b 5b 32 30 3b 32 7e  1b 5b 32 31 3b 32 7e
# ctrl  f5-10  1b 5b 31 35 3b 35 7e  1b 5b 31 37 3b 35 7e  1b 5b 31 38 3b 35 7e  1b 5b 31 39 3b 35 7e  1b 5b 32 30 3b 35 7e  1b 5b 32 31 3b 35 7e
# alt   f5-10  1b 5b 31 35 3b 33 7e  1b 5b 31 37 3b 33 7e  1b 5b 31 38 3b 33 7e  1b 5b 31 39 3b 33 7e  1b 5b 32 30 3b 33 7e  1b 5b 32 31 3b 33 7e
# c+a   f5-10  1b 5b 31 35 3b 37 7e  1b 5b 31 37 3b 37 7e  1b 5b 31 38 3b 37 7e  1b 5b 31 39 3b 37 7e  1b 5b 32 30 3b 37 7e  1b 5b 32 31 3b 37 7e

#       a      61
# alt   a      1b 61
# ctrl  a      01
# c+a   a      1b 01

# ctrl a-z: 0x01-0x1a

scancode:
    ds  9, 0                            # 0-8
    ds  9, 0

    db  1, 0x0f                         # 9 tab

    ds  3, 0                            # 10-12
    ds  3, 0

    db  1, 0x1c                         # 13 enter

    ds  13, 0                           # 14-26
    ds  13, 0

    db  3,    0                         # 27 escape

    ds  4, 0                            # 28-31
    ds  4, 0

    db  1, 0x39                         # 32 space
    db  2, 0x02                         # 33 !
    db  2, 0x28                         # 34 "
    db  2, 0x04                         # 35 #
    db  2, 0x05                         # 36 $
    db  2, 0x06                         # 37 %
    db  2, 0x08                         # 38 &
    db  1, 0x28                         # 39 '
    db  2, 0x0a                         # 40 (
    db  2, 0x0b                         # 41 )
    db  2, 0x09                         # 42 *
    db  2, 0x0d                         # 43 +
    db  1, 0x33                         # 44 ,
    db  1, 0x0c                         # 45 -
    db  1, 0x34                         # 46 .
    db  1, 0x35                         # 47 /
    db  1, 0x0b                         # 48 0
    db  1, 0x02                         # 49 1
    db  1, 0x03                         # 50 2
    db  1, 0x04                         # 51 3
    db  1, 0x05                         # 52 4
    db  1, 0x06                         # 53 5
    db  1, 0x07                         # 54 6
    db  1, 0x08                         # 55 7
    db  1, 0x09                         # 56 8
    db  1, 0x0a                         # 57 9
    db  2, 0x27                         # 58 :
    db  1, 0x27                         # 59 ;
    db  2, 0x33                         # 60 <
    db  1, 0x0d                         # 61 =
    db  2, 0x34                         # 62 >
    db  2, 0x35                         # 63 ?
    db  2, 0x03                         # 64 @
    db  2, 0x1e                         # 65 A
    db  2, 0x30                         # 66 B
    db  2, 0x2e                         # 67 C
    db  2, 0x20                         # 68 D
    db  2, 0x12                         # 69 E
    db  2, 0x21                         # 70 F
    db  2, 0x22                         # 71 G
    db  2, 0x23                         # 72 H
    db  2, 0x17                         # 73 I
    db  2, 0x24                         # 74 J
    db  2, 0x25                         # 75 K
    db  2, 0x26                         # 76 L
    db  2, 0x32                         # 77 M
    db  2, 0x31                         # 78 N
    db  2, 0x18                         # 79 O
    db  2, 0x19                         # 80 P
    db  2, 0x10                         # 81 Q
    db  2, 0x13                         # 82 R
    db  2, 0x1f                         # 83 S
    db  2, 0x14                         # 84 T
    db  2, 0x16                         # 85 U
    db  2, 0x2f                         # 86 V
    db  2, 0x11                         # 87 W
    db  2, 0x2d                         # 88 X
    db  2, 0x15                         # 89 Y
    db  2, 0x2c                         # 90 Z
    db  1, 0x1a                         # 91 [
    db  1, 0x2b                         # 92 \
    db  1, 0x1b                         # 93 ]
    db  2, 0x07                         # 94 ^
    db  2, 0x0c                         # 95 _
    db  1, 0x29                         # 96 `
    db  1, 0x1e                         # 97 a
    db  1, 0x30                         # 98 b
    db  1, 0x2e                         # 99 c
    db  1, 0x20                         # 100 d
    db  1, 0x12                         # 101 e
    db  1, 0x21                         # 102 f
    db  1, 0x22                         # 103 g
    db  1, 0x23                         # 104 h
    db  1, 0x17                         # 105 i
    db  1, 0x24                         # 106 j
    db  1, 0x25                         # 107 k
    db  1, 0x26                         # 108 l
    db  1, 0x32                         # 109 m
    db  1, 0x31                         # 110 n
    db  1, 0x18                         # 111 o
    db  1, 0x19                         # 112 p
    db  1, 0x10                         # 113 q
    db  1, 0x13                         # 114 r
    db  1, 0x1f                         # 115 s
    db  1, 0x14                         # 116 t
    db  1, 0x16                         # 117 u
    db  1, 0x2f                         # 118 v
    db  1, 0x11                         # 119 w
    db  1, 0x2d                         # 120 x
    db  1, 0x15                         # 121 y
    db  1, 0x2c                         # 122 z
    db  2, 0x1a                         # 123 {
    db  2, 0x2b                         # 124 |
    db  2, 0x1b                         # 125 }
    db  2, 0x29                         # 126 ~
    db  1, 0x0e                         # 127 backspace

    ds  128, 0                          # ASCII 127-255
    ds  128, 0

.EOF
