# apt install 7zip mtools wget xdelta3 xz-utils
#
# download:
#  - https://vetusware.com/download/Norton%20Commander%203.0%203.0 -> nc.7z
#  - https://www.myabandonware.com/game/arcade-volleyball-1on -> av.zip
#  - https://www.myabandonware.com/game/prince-of-persia-pd -> prince.zip
#  - https://vetusware.com/download/Text602 _T602_ 1.00 %231090 CZ -> t602-1.zip
#  - https://vetusware.com/download/T602%203.0%20CZ -> t602-3.zip

FLOPPY ?= freedos-simple
BUILD_TARGETS=$(patsubst %,%.img,$(FLOPPY))

FORMATS=180 360 720 1200 1440

.PHONY: build-all
build-all: checksum empty freedos msdos3 msdos5 msdos6

.PHONY: build
build: $(BUILD_TARGETS)

.PHONY: checksum
checksum: hash.md5 av.zip freedos.zip freedos-simple.img.xz msdos3.7z msdos5.7z msdos6.7z nc.7z prince.zip \
	t602-1.zip t602-3.zip
	md5sum -c < $<

.PHONY: empty
empty: empty-360.img empty-720.img empty-1200.img empty-1440.img

.PHONY: freedos
freedos: freedos-simple.img freedos.img freedos-min freedos-poweroff.img freedos-nc.img \
	freedos-t602-1.img freedos-t602-3.img freedos-av.img freedos-prince.img

.PHONY: freedos-min
freedos-min: freedos-min-360.img freedos-min-720.img freedos-min-1200.img freedos-min-1440.img

.PHONY: msdos3
msdos3: msdos3.img msdos3-min msdos3-nc.img msdos3-t602-1.img msdos3-t602-3.img \
	msdos3-av.img msdos3-prince.img

.PHONY: msdos3-min
msdos3-min: msdos3-min-360.img msdos3-min-720.img msdos3-min-1200.img msdos3-min-1440.img

.PHONY: msdos5
msdos5: msdos5.img msdos5-min msdos5-nc.img msdos5-t602-1.img msdos5-t602-3.img \
	msdos5-av.img msdos5-prince.img

.PHONY: msdos5-min
freedos-min: msdos5-min-360.img msdos5-min-720.img msdos5-min-1200.img msdos5-min-1440.img

.PHONY: msdos6
msdos6: msdos6.img msdos6-min msdos6-nc.img msdos6-t602-1.img msdos6-t602-3.img \
	msdos6-av.img msdos6-prince.img

.PHONY: msdos6-min
freedos-min: msdos6-min-360.img msdos6-min-720.img msdos6-min-1200.img msdos6-min-1440.img

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
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	mcopy -D o -i $@ config-freedos.sys ::CONFIG.SYS

# https://winworldpc.com/product/pc-dos/2x
pcdos2.7z:
	wget 'https://winworldpc.com/download/44c2ac7d-cb9c-c2b4-e280-a111c3a4c2ac' -O $@

pcdos2.img: pcdos2.7z
	7zz -y e $< -r Disk01.img -so > $@

# https://winworldpc.com/product/ms-dos/331
msdos3.7z:
	wget 'https://winworldpc.com/download/40c2b855-0818-c39a-11c3-a4e284a2c3a5' -O $@

msdos3.img: msdos3.7z
	7zz -y e $< -r Disk1.img -so > $@

# https://winworldpc.com/product/ms-dos/50
msdos5.7z:
	wget 'https://winworldpc.com/download/28c2b366-26e2-809c-c3ad-11c3a5c28f13' -O $@

msdos5.img: msdos5.7z
	7zz -y e $< -r disk01.img -so > $@
	mdel -i $@ DOS50.ZIP AUTOEXEC.BAT CONFIG.SYS SETUP.* PKUNZIP.EXE
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT

# https://winworldpc.com/product/ms-dos/622
msdos6.7z:
	wget 'https://winworldpc.com/download/c38fc38d-68c2-bbe2-80a6-4b11c3a4c2ac' -O $@

msdos6.img: msdos6.7z
	7zz -y e $< -r Disk1.img -so > $@
	mdel -i $@ *.??_ AUTOEXEC.BAT CONFIG.SYS COUNTRY.* DEFRAG.* DOSSETUP.INI DRVSPACE.BIN \
		EXPAND.EXE MSCDEX.EXE NETWORKS.TXT PACKING.LST SCANDISK.* SETUP.*
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT

$(FORMATS:%=empty-%.img): empty-%.img:
	mformat -i $@ -f $(*F) -C

# minimal freedos images
define make-freedos-floppy
	dd if=$< of=$(<:img=boot) bs=512 count=1
	mformat -i $@ -f $(*F) -C -B $(<:img=boot)
	mcopy -D o -i $< ::KERNEL.SYS KERNEL.SYS
	mcopy -D o -i $@ KERNEL.SYS ::KERNEL.SYS
	mcopy -D o -i $< ::FREEDOS/BIN/COMMAND.COM COMMAND.COM
	mcopy -D o -i $@ COMMAND.COM ::COMMAND.COM
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	rm -f $(<:img=boot) KERNEL.SYS COMMAND.COM
endef

$(FORMATS:%=freedos-min-%.img): freedos-min-%.img: freedos.img
	$(make-freedos-floppy)

# minimal pcdos 2.x images
define make-pcdos1-floppy
	dd if=$< of=$(<:img=boot) bs=512 count=1
	mformat -i $@ -f $(*F) -C -B $(<:img=boot)
	mcopy -D o -i $< ::IBMBIO.COM IBMBIO.COM
	mcopy -D o -i $@ IBMBIO.COM ::IBMBIO.COM
	mattrib -i $@ +h +s ::IBMBIO.COM
	mcopy -D o -i $< ::IBMDOS.COM IBMDOS.COM
	mcopy -D o -i $@ IBMDOS.COM ::IBMDOS.COM
	mattrib -i $@ +h +s ::IBMDOS.COM
	mcopy -D o -i $< ::COMMAND.COM COMMAND.COM
	mcopy -D o -i $@ COMMAND.COM ::COMMAND.COM
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	rm -f $(<:img=boot) IBMBIO.COM IBMDOS.COM COMMAND.COM
endef

$(FORMATS:%=pcdos2-min-%.img): pcdos2-min-%.img: pcdos2.img
	$(make-pcdos1-floppy)

# minimal msdos 3.x images
define make-msdos3-floppy
	dd if=$< of=$(<:img=boot) bs=512 count=1
	mformat -i $@ -f $(*F) -C -B $(<:img=boot)
	# msdos 3 does not boot with the boot sector updated by mformat (which has an EBPB block)
	# we need to copy a few bytes from the proper boot sector to make it boot
	dd if=$(<:img=boot) of=$@ bs=1 count=24 iseek=38 oseek=38 conv=notrunc
	mcopy -D o -i $< ::IO.SYS IO.SYS
	mcopy -D o -i $@ IO.SYS ::IO.SYS
	mattrib -i $@ +h +s ::IO.SYS
	mcopy -D o -i $< ::MSDOS.SYS MSDOS.SYS
	mcopy -D o -i $@ MSDOS.SYS ::MSDOS.SYS
	mattrib -i $@ +h +s ::MSDOS.SYS
	mcopy -D o -i $< ::COMMAND.COM COMMAND.COM
	mcopy -D o -i $@ COMMAND.COM ::COMMAND.COM
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	rm -f $(<:img=boot) IO.SYS MSDOS.SYS COMMAND.COM
endef

$(FORMATS:%=msdos3-min-%.img): msdos3-min-%.img: msdos3.img
	$(make-msdos3-floppy)

# minimal msdos 5.x and 6.x images
define make-msdos5-floppy
	dd if=$< of=$(<:img=boot) bs=512 count=1
	mformat -i $@ -f $(*F) -C -B $(<:img=boot)
	mcopy -D o -i $< ::IO.SYS IO.SYS
	mcopy -D o -i $@ IO.SYS ::IO.SYS
	mattrib -i $@ +h +s ::IO.SYS
	mcopy -D o -i $< ::MSDOS.SYS MSDOS.SYS
	mcopy -D o -i $@ MSDOS.SYS ::MSDOS.SYS
	mattrib -i $@ +h +s ::MSDOS.SYS
	mcopy -D o -i $< ::COMMAND.COM COMMAND.COM
	mcopy -D o -i $@ COMMAND.COM ::COMMAND.COM
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	rm -f $(<:img=boot) IO.SYS MSDOS.SYS COMMAND.COM
endef

$(FORMATS:%=msdos5-min-%.img): msdos5-min-%.img: msdos5.img
	$(make-msdos5-floppy)

$(FORMATS:%=msdos6-min-%.img): msdos6-min-%.img: msdos6.img
	$(make-msdos5-floppy)

# additional software
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

%-t602-1.img: %.img t602-1.zip autoexec-t602-1.bat
	rm -rf T602-1
	mkdir -p T602-1
	7zz -y x t602-1.zip -oT602-1
	cp $< $@
	mcopy -D o -s -i $@ T602-1/t602 ::T602
	rm -rf T602-1
	mcopy -D o -i $@ autoexec-t602-1.bat ::AUTOEXEC.BAT

%-t602-3.img: %-min-1440.img t602-3.zip autoexec-t602-3.bat
	rm -rf T602-3
	mkdir -p T602-3
	7zz -y x t602-3.zip -oT602-3
	rm T602-3/T602/K602.EXE T602-3/T602/K602.HLP T602-3/T602/CESKY.SLO
	cp T602-3/T602/T602.EXE T602.EXE.tmp
	xdelta3 -d -f -s T602.EXE.tmp t602-3.xdelta3 T602-3/T602/T602.EXE
	rm -f T602.EXE.tmp
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
	rm -rf *.img AV NC PRINCE T602-1 T602-3

.PHONY: very-clean
very-clean: clean
	rm -rf *.7z *.xz *.zip
