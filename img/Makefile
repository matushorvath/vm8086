# apt install 7zip mtools wget

.PHONY: build
build: freedos msdos

.PHONY: freedos
freedos: freedos.img freedos-nc.img #freedos-av.img

.PHONY: msdos
msdos: msdos.img msdos-nc.img #msdos-av.img

# https://github.com/codercowboy/freedosbootdisks
freedos.img.xz:
	wget 'https://github.com/codercowboy/freedosbootdisks/raw/master/bootdisks/freedos.boot.disk.1.4MB.img' -O - | xz > $@

freedos.img: freedos.img.xz
	xz -dkf $<

# https://winworldpc.com/product/ms-dos/331
msdos.7z:
	wget 'https://winworldpc.com/download/40c2b855-0818-c39a-11c3-a4e284a2c3a5/from/c3ae6ee2-8099-713d-3411-c3a6e280947e' -O $@

msdos.img: msdos.7z
	7zz -y e $< -r Disk1.img -so > $@

# https://vetusware.com/download/Norton%20Commander%203.0%203.0
nc.7z:
	wget 'https://vetusware.com/output/obxyytfl/Norton%20Commander%203.0%20(1989).7z' -O $@

%-nc.img: %.img nc.7z autoexec-nc.bat nc.ini
	rm -rf NC
	mkdir -p NC
	7zz -y x nc.7z -oNC
	cp $< $@
	mcopy -D o -i $@ NC ::NC
	rm -rf NC
	mcopy -D o -i $@ autoexec-nc.bat ::AUTOEXEC.BAT
	mcopy -D o -i $@ nc.ini ::NC/NC.INI

.PHONY: clean
clean:
	rm -rf *.img NC

.PHONY: very-clean
very-clean: clean
	rm -rf *.7z *.xz