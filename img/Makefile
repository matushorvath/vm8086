# apt install 7zip mtools wget
#
# download:
#  - https://vetusware.com/download/Norton%20Commander%203.0%203.0 -> nc.7z
#  = https://www.myabandonware.com/game/arcade-volleyball-1on -> av.zip
#  - https://www.myabandonware.com/game/prince-of-persia-pd -> prince.zip

.PHONY: build-all
build-all: freedos msdos

.PHONY: build
build: freedos.img

.PHONY: freedos
freedos: freedos.img freedos-nc.img freedos-av.img freedos-prince.img

.PHONY: msdos
msdos: msdos.img msdos-nc.img msdos-av.img msdos-prince.img

# https://github.com/codercowboy/freedosbootdisks
freedos.img.xz:
	wget 'https://github.com/codercowboy/freedosbootdisks/raw/master/bootdisks/freedos.boot.disk.1.4MB.img' -O - | xz > $@

freedos.img: freedos.img.xz
	xz -dkf $<
	mdeltree -i $@ FSEVEN~1

# https://winworldpc.com/product/ms-dos/331
msdos.7z:
	wget 'https://winworldpc.com/download/40c2b855-0818-c39a-11c3-a4e284a2c3a5/from/c3ae6ee2-8099-713d-3411-c3a6e280947e' -O $@

msdos.img: msdos.7z
	7zz -y e $< -r Disk1.img -so > $@

%-nc.img: %.img nc.7z autoexec-nc.bat nc.ini
	rm -rf NC
	mkdir -p NC
	7zz -y x nc.7z -oNC
	cp $< $@
	mcopy -D o -s -i $@ NC ::NC
	rm -rf NC
	mcopy -D o -i $@ autoexec-nc.bat ::AUTOEXEC.BAT
	mcopy -D o -i $@ nc.ini ::NC/NC.INI

%-av.img: %.img av.zip autoexec-av.bat
	rm -rf AV
	mkdir -p AV
	7zz -y x av.zip -oAV
	cp $< $@
	mcopy -D o -s -i $@ AV ::AV
	rm -rf AV
	mcopy -D o -i $@ autoexec-av.bat ::AUTOEXEC.BAT

%-prince.img: %.img prince.zip autoexec-prince.bat
	rm -rf PRINCE PRINCE.tmp
	mkdir -p PRINCE.tmp
	7zz -y x prince.zip -oPRINCE.tmp
	mv PRINCE.tmp/PoP1 PRINCE
	cp $< $@
	mcopy -D o -s -i $@ PRINCE ::PRINCE
	rm -rf PRINCE PRINCE.tmp
	mcopy -D o -i $@ autoexec-prince.bat ::AUTOEXEC.BAT

.PHONY: clean
clean:
	rm -rf *.img AV NC PRINCE PRINCE.tmp

.PHONY: very-clean
very-clean: clean
	rm -rf *.7z *.xz *.zip
