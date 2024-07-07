# apt install 7zip mtools wget
#
# download:
#  - https://vetusware.com/download/Norton%20Commander%203.0%203.0 -> nc.7z
#  - https://www.myabandonware.com/game/arcade-volleyball-1on -> av.zip
#  - https://www.myabandonware.com/game/prince-of-persia-pd -> prince.zip
#  - https://vetusware.com/download/Text602 _T602_ 1.00 %231090 CZ -> t602-1.zip
#  - https://vetusware.com/download/T602%203.0%20CZ -> t602-3.zip

FLOPPY ?= freedos-simple
BUILD_TARGET=$(FLOPPY).img

.PHONY: build-all
build-all: checksum freedos msdos

.PHONY: build
build: $(BUILD_TARGET)

.PHONY: checksum
checksum: hash.md5 av.zip freedos.zip freedos-simple.img.xz msdos.7z nc.7z prince.zip t602-1.zip t602-3.zip
	md5sum -c < $<

.PHONY: freedos
freedos: freedos-simple.img freedos.img freedos-poweroff.img freedos-nc.img freedos-t602-1.img \
	freedos-t602-3.img freedos-av.img freedos-prince.img

.PHONY: msdos
msdos: msdos.img msdos-nc.img msdos-t602-1.img msdos-av.img msdos-prince.img

# https://github.com/codercowboy/freedosbootdisks - a boot disk we can boot in CI/CD, without mtools
freedos-simple.img.xz:
	wget 'https://github.com/codercowboy/freedosbootdisks/raw/master/bootdisks/freedos.boot.disk.1.4MB.img' -O - | xz > $@

freedos-simple.img: freedos-simple.img.xz
	xz -dkf $<
	# ignore errors, since this is just cosmetic and CI/CD has no mtools
	mdeltree -i $@ FSEVEN~1 || true

# https://www.freedos.org/download
freedos.zip:
	wget 'https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-FloppyEdition.zip' -O $@

freedos.img: freedos.zip
	7zz -y e $< -r 144m/x86BOOT.img -so > $@
	mdel -i $@ FDAUTO.BAT FDCONFIG.SYS SETUP.BAT
	mcopy -D o -i $@ autoexec-freedos.bat ::AUTOEXEC.BAT
	mcopy -D o -i $@ config-freedos.sys ::CONFIG.SYS

# https://winworldpc.com/product/ms-dos/331
msdos.7z:
	wget 'https://winworldpc.com/download/40c2b855-0818-c39a-11c3-a4e284a2c3a5/from/c3ae6ee2-8099-713d-3411-c3a6e280947e' -O $@

msdos.img: msdos.7z
	7zz -y e $< -r Disk1.img -so > $@

%-poweroff.img: %.img autoexec-poweroff.bat
	cp $< $@
	mcopy -D o -i $@ autoexec-poweroff.bat ::AUTOEXEC.BAT

%-nc.img: %.img nc.7z autoexec-nc.bat nc.ini
	rm -rf NC
	mkdir -p NC
	7zz -y x nc.7z -oNC
	cp $< $@
	mcopy -D o -s -i $@ NC ::NC
	rm -rf NC
	mcopy -D o -i $@ autoexec-nc.bat ::AUTOEXEC.BAT
	mcopy -D o -i $@ nc.ini ::NC/NC.INI

%-t602-1.img: %-nc.img t602-1.zip autoexec-t602-1.bat
	rm -rf T602-1
	mkdir -p T602-1
	7zz -y x t602-1.zip -oT602-1
	cp $< $@
	mcopy -D o -s -i $@ T602-1/t602 ::T602
	rm -rf T602-1
	mcopy -D o -i $@ autoexec-t602-1.bat ::AUTOEXEC.BAT

# TODO Text602 3.0 is too large to fit on one disk with full MS-DOS
# TODO Text602 3.0 asks for information when it is started for the first time

%-t602-3.img: %.img t602-3.zip autoexec-t602-3.bat
	rm -rf T602-3
	mkdir -p T602-3
	7zz -y x t602-3.zip -oT602-3
	rm T602-3/T602/K602.EXE T602-3/T602/K602.HLP T602-3/T602/CESKY.SLO
	cp $< $@
	mcopy -D o -s -i $@ T602-3/T602 ::T602
	rm -rf T602-3
	mcopy -D o -i $@ autoexec-t602-3.bat ::AUTOEXEC.BAT

%-av.img: %.img av.zip autoexec-av.bat
	rm -rf AV
	mkdir -p AV
	7zz -y x av.zip -oAV
	cp $< $@
	mcopy -D o -s -i $@ AV ::AV
	rm -rf AV
	mcopy -D o -i $@ autoexec-av.bat ::AUTOEXEC.BAT

%-prince.img: %.img prince.zip autoexec-prince.bat
	rm -rf PRINCE
	mkdir -p PRINCE
	7zz -y x prince.zip -oPRINCE
	cp $< $@
	mcopy -D o -s -i $@ PRINCE/PoP1 ::PRINCE
	rm -rf PRINCE
	mcopy -D o -i $@ autoexec-prince.bat ::AUTOEXEC.BAT

.PHONY: clean
clean:
	rm -rf *.img AV NC PRINCE T602

.PHONY: very-clean
very-clean: clean
	rm -rf *.7z *.xz *.zip
