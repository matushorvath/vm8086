%.bin %.lst %.map: %.asm
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	hd $@ ; true

.PHONY: all
all: test.bin

.PHONY: clean
clean:
	rm -f *.bin *.lst *.map
