AS ?= as
LD ?= ld

%.bin %.lst %.map: %.asm
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	hd $@

.PHONY: all
all: test.bin

.PHONY: clean
clean:
	rm -f *.bin *.lst *.map
