# Build 6502 Assembly

```sh
ca65 test.s -o tmp.o
ld65 -C ld65.cfg tmp.o -o tmp.bin
hexdump -C tmp.bin

echo clc | ./assemble.sh | hd
```

# Convert a Binary to Comma-Separated Numbers

```sh
wc -c ../msbasic/tmp/vm6502.bin | cut -d' ' -f1

echo abc | hexdump -ve '/1 ",%02x"'
,61,62,63,0a
echo abc | hexdump -ve '/1 ",%02d"'
,97,98,99,10

echo $(wc -c ../msbasic/tmp/vm6502.bin | cut -d' ' -f1)$(hexdump -ve '/1 ",%u"' ../msbasic/tmp/vm6502.bin)

define run-bin2obj
echo ".C\n$$(wc -c $^ | cut -d' ' -f1)$$(hexdump -ve '/1 ",%u"' $^)\n.R\n.I\n.E\n__bin2obj_$$(basename $^ | tr -cd [a-z0-9])_length:0\n__bin2obj_$$(basename $^ | tr -cd [a-z0-9])_data:1" > $@
endef
```

# Intcode

```sh
cd ic
ICDIR=~/xzintbit make
~/xzintbit/vms/c/ic bin/vm6502.input
```

# Tests

./tests/assemble.sh > test.bin
adc #$42
nop
nop
.byte 02
^D

