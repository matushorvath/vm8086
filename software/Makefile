# apt install 7zip mtools wget xdelta3 xz-utils

VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/software

DISKS ?= freedos-simple
COMMA = ,
TARGETS=$(patsubst %,$(OBJDIR)/%.o,$(subst $(COMMA), ,$(DISKS)))

FORMATS=180 360 720 1200 1440

.PHONY: build-all
build-all: build-prep checksum empty freedos msdos3 msdos5 msdos6 win104 win203 win211

.PHONY: build
build: build-prep $(TARGETS)

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

.PHONY: checksum
checksum: hash.md5 blobs/av.zip blobs/freedos.zip blobs/freedos-simple.img.xz blobs/msdos3.7z \
	blobs/msdos5.7z blobs/msdos6.7z blobs/nc.7z blobs/prince.zip blobs/t602-1.zip \
	blobs/t602-3.zip blobs/pcdos2.7z blobs/win104.7z blobs/win203.7z blobs/win211.7z
	md5sum -c < $<

.PHONY: empty
empty: $(addprefix $(OBJDIR)/,empty-360.o empty-720.o empty-1200.o empty-1440.o)

.PHONY: freedos
freedos: freedos-min $(addprefix $(OBJDIR)/,freedos-simple.o freedos.o freedos-poweroff.o \
	freedos-nc.o freedos-t602-1.o freedos-min-1440-t602-3.o freedos-av.o freedos-prince.o)

.PHONY: freedos-min
freedos-min: $(addprefix $(OBJDIR)/,freedos-min-360.o freedos-min-720.o freedos-min-1200.o \
	freedos-min-1440.o)

.PHONY: msdos3
msdos3: msdos3-min $(addprefix $(OBJDIR)/,msdos3.o msdos3-nc.o msdos3-t602-1.o msdos3-min-1440-t602-3.o \
	msdos3-av.o msdos3-prince.o)

.PHONY: msdos3-min
msdos3-min: $(addprefix $(OBJDIR)/,msdos3-min-360.o msdos3-min-720.o msdos3-min-1200.o msdos3-min-1440.o)

.PHONY: msdos5
msdos5: msdos5-min $(addprefix $(OBJDIR)/,msdos5.o msdos5-nc.o msdos5-t602-1.o msdos5-min-1440-t602-3.o \
	msdos5-av.o msdos5-prince.o)

.PHONY: msdos5-min
msdos5-min: $(addprefix $(OBJDIR)/,msdos5-min-360.o msdos5-min-720.o msdos5-min-1200.o msdos5-min-1440.o)

.PHONY: msdos6
msdos6: msdos6-min $(addprefix $(OBJDIR)/,msdos6.o msdos6-nc.o msdos6-t602-1.o msdos6-min-1440-t602-3.o \
	msdos6-av.o msdos6-prince.o)

.PHONY: msdos6-min
msdos6-min: $(addprefix $(OBJDIR)/,msdos6-min-360.o msdos6-min-720.o msdos6-min-1200.o msdos6-min-1440.o)

.PHONY: win104
win104: $(patsubst %,$(OBJDIR)/win104-disk%.o,1 2 3 4 5 6 7)

.PHONY: win203
win203: $(patsubst %,$(OBJDIR)/win203-disk%.o,1 2 3 4 5)

.PHONY: win211
win211: $(patsubst %,$(OBJDIR)/win211-disk%.o,1 2 3 4)

# a boot disk we can boot in CI/CD, without mtools
$(OBJDIR)/freedos-simple.img: blobs/freedos-simple.img.xz
	xz -dkfc $< > $@
	# ignore errors, since this is just cosmetic and CI/CD has no mtools
	mdeltree -i $@ FSEVEN~1 || true

$(OBJDIR)/freedos.img: blobs/freedos.zip
	7zz -y e $< -r 144m/x86BOOT.img -so > $@
	mdel -i $@ FDAUTO.BAT FDCONFIG.SYS SETUP.BAT
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT
	mcopy -D o -i $@ config-freedos.sys ::CONFIG.SYS

$(OBJDIR)/pcdos2.img: blobs/pcdos2.7z
	7zz -y e $< -r Disk01.img -so > $@

$(OBJDIR)/msdos3.img: blobs/msdos3.7z
	7zz -y e $< -r Disk1.img -so > $@

$(OBJDIR)/msdos5.img: blobs/msdos5.7z
	7zz -y e $< -r disk01.img -so > $@
	mdel -i $@ DOS50.ZIP AUTOEXEC.BAT CONFIG.SYS SETUP.* PKUNZIP.EXE
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT

$(OBJDIR)/msdos6.img: blobs/msdos6.7z
	7zz -y e $< -r Disk1.img -so > $@
	mdel -i $@ *.??_ AUTOEXEC.BAT CONFIG.SYS COUNTRY.* DEFRAG.* DOSSETUP.INI DRVSPACE.BIN \
		EXPAND.EXE MSCDEX.EXE NETWORKS.TXT PACKING.LST SCANDISK.* SETUP.*
	mcopy -D o -i $@ /dev/null ::AUTOEXEC.BAT

$(OBJDIR)/win104-disk%.img: blobs/win104.7z
	7zz -y e $< -r D$(*F)_*.img -so > $@

$(OBJDIR)/win203-disk%.img: blobs/win203.7z
	7zz -y e $< -r disk$(*F).img -so > $@

$(OBJDIR)/win211-disk%.img: blobs/win211.7z
	7zz -y e $< -r Disk$(*F).img -so > $@

$(FORMATS:%=$(OBJDIR)/empty-%.img): $(OBJDIR)/empty-%.img:
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

$(FORMATS:%=$(OBJDIR)/freedos-min-%.img): $(OBJDIR)/freedos-min-%.img: $(OBJDIR)/freedos.img
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

$(FORMATS:%=$(OBJDIR)/pcdos2-min-%.img): $(OBJDIR)/pcdos2-min-%.img: $(OBJDIR)/pcdos2.img
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

$(FORMATS:%=$(OBJDIR)/msdos3-min-%.img): $(OBJDIR)/msdos3-min-%.img: $(OBJDIR)/msdos3.img
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

$(FORMATS:%=$(OBJDIR)/msdos5-min-%.img): $(OBJDIR)/msdos5-min-%.img: $(OBJDIR)/msdos5.img
	$(make-msdos5-floppy)

$(FORMATS:%=$(OBJDIR)/msdos6-min-%.img): $(OBJDIR)/msdos6-min-%.img: $(OBJDIR)/msdos6.img
	$(make-msdos5-floppy)

# additional software
$(OBJDIR)/%-poweroff.img: $(OBJDIR)/%.img autoexec-poweroff.bat
	cp $< $@
	mcopy -D o -i $@ autoexec-poweroff.bat ::AUTOEXEC.BAT

$(OBJDIR)/%-nc.img: $(OBJDIR)/%.img blobs/nc.7z autoexec-nc.bat nc.ini
	rm -rf $(OBJDIR)/NC
	mkdir -p $(OBJDIR)/NC
	7zz -y x blobs/nc.7z -o$(OBJDIR)/NC
	cp $< $@
	mcopy -D o -s -i $@ $(OBJDIR)/NC ::NC
	rm -rf $(OBJDIR)/NC
	mcopy -D o -i $@ autoexec-nc.bat ::AUTOEXEC.BAT
	mcopy -D o -i $@ nc.ini ::NC/NC.INI

$(OBJDIR)/%-t602-1.img: $(OBJDIR)/%.img blobs/t602-1.zip autoexec-t602-1.bat
	rm -rf $(OBJDIR)/T602-1
	mkdir -p $(OBJDIR)/T602-1
	7zz -y x blobs/t602-1.zip -o$(OBJDIR)/T602-1
	cp $< $@
	mcopy -D o -s -i $@ $(OBJDIR)/T602-1/t602 ::T602
	rm -rf $(OBJDIR)/T602-1
	mcopy -D o -i $@ autoexec-t602-1.bat ::AUTOEXEC.BAT

$(OBJDIR)/%-t602-3.img: $(OBJDIR)/%.img blobs/t602-3.zip autoexec-t602-3.bat
	rm -rf $(OBJDIR)/T602-3
	mkdir -p $(OBJDIR)/T602-3
	7zz -y x blobs/t602-3.zip -o$(OBJDIR)/T602-3
	rm $(OBJDIR)/T602-3/T602/K602.EXE $(OBJDIR)/T602-3/T602/K602.HLP $(OBJDIR)/T602-3/T602/CESKY.SLO
	cp $(OBJDIR)/T602-3/T602/T602.EXE $(OBJDIR)/T602.EXE.tmp
	xdelta3 -d -f -s $(OBJDIR)/T602.EXE.tmp t602-3.xdelta3 $(OBJDIR)/T602-3/T602/T602.EXE
	rm -f $(OBJDIR)/T602.EXE.tmp
	cp $< $@
	mcopy -D o -s -i $@ $(OBJDIR)/T602-3/T602 ::T602
	rm -rf $(OBJDIR)/T602-3
	mcopy -D o -i $@ autoexec-t602-3.bat ::AUTOEXEC.BAT

$(OBJDIR)/%-av.img: $(OBJDIR)/%.img blobs/av.zip autoexec-av.bat
	rm -rf $(OBJDIR)/AV
	mkdir -p $(OBJDIR)/AV
	7zz -y x blobs/av.zip -o$(OBJDIR)/AV
	cp $< $@
	mcopy -D o -s -i $@ $(OBJDIR)/AV ::AV
	rm -rf $(OBJDIR)/AV
	mcopy -D o -i $@ autoexec-av.bat ::AUTOEXEC.BAT

$(OBJDIR)/%-prince.img: $(OBJDIR)/%.img blobs/prince.zip autoexec-prince.bat
	rm -rf $(OBJDIR)/PRINCE
	mkdir -p $(OBJDIR)/PRINCE
	7zz -y x blobs/prince.zip -o$(OBJDIR)/PRINCE
	cp $< $@
	mcopy -D o -s -i $@ $(OBJDIR)/PRINCE/PoP1 ::PRINCE
	rm -rf $(OBJDIR)/PRINCE
	mcopy -D o -i $@ autoexec-prince.bat ::AUTOEXEC.BAT

$(OBJDIR)/%.o: $(OBJDIR)/%.img
	$(eval BIN2OBJ_NAME = img_$(subst -,_,$(basename $(notdir $@))))
	$(run-intcode-bin2obj)

.PHONY: clean
clean:
	rm -rf $(OBJDIR)
