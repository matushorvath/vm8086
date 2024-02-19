# Build 6502 Assembly

```sh
ca65 test.s -o tmp.o
ld65 -C ld65.cfg tmp.o -o tmp.bin
hexdump -C tmp.bin

echo clc | ./assemble.sh | hd
```

# Convert a Binary to Comma-Separated Numbers

```sh
echo abc | hexdump -ve '/1 ",%02x"'
,61,62,63,0a
echo abc | hexdump -ve '/1 ",%02d"'
,97,98,99,10
```

# Intcode

```sh
cd ic
ICDIR=~/xzintbit make
~/xzintbit/vms/c/ic bin/vm6502.input
```
