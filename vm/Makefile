VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

ifeq ($(BIOS),pcxtbios)
	BIOS_BIN ?= $(abspath $(VMDIR)/../pcxtbios/eproms/2764/pcxtbios.rom)
	BIOS_ADDRESS ?= fe000
else
	BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)
	BIOS_ADDRESS ?= fc000
endif

FLOPPY_BIN ?= $(abspath $(VMDIR)/../freedosbootdisks/bootdisks/freedos.boot.disk.1.4MB.img)

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

BIOS_NAME = $(basename $(notdir $(BIOS_BIN)))
FLOPPY_NAME = $(basename $(notdir $(FLOPPY_BIN)))
VM_NAME = vm.$(BIOS_NAME).$(FLOPPY_NAME).input

.PHONY: build
build: build-prep $(BINDIR)/$(VM_NAME)

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

.PHONY: run
run: build
	$(ICVM) $(BINDIR)/$(VM_NAME)

# The order of the object files matters, the BIOS binary needs to be the last object.

VM_OBJS = main.o config.o ports.o $(BIOS_NAME)_address.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a \
	$(BINDIR)/libdev.a $(BINDIR)/libutil.a $(LIBXIB) $(BIOS_NAME).o $(FLOPPY_NAME).o

$(BINDIR)/$(VM_NAME): $(VM_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)
	@echo VM name: $(VM_NAME)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

$(OBJDIR)/$(BIOS_NAME).o: $(BIOS_BIN)
	$(eval BIN2OBJ_NAME = bios)
	$(run-intcode-bin2obj)

$(OBJDIR)/$(BIOS_NAME)_address.o: $(OBJDIR)/$(BIOS_NAME)_address.s
	$(run-intcode-as)

$(OBJDIR)/$(BIOS_NAME)_address.s: bios_address.template
	sed -e 's/BIOS_ADDRESS/$(BIOS_ADDRESS)/g' < $< > $@

$(OBJDIR)/$(FLOPPY_NAME).o: $(FLOPPY_BIN)
	$(eval BIN2OBJ_NAME = floppy)
	$(run-intcode-bin2obj)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/vm.*.input* $(OBJDIR)
