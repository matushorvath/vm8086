VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

ifeq ($(BIOS),pcxtbios)
	BIOS_BIN ?= $(abspath $(VMDIR)/../pcxtbios/eproms/2764/pcxtbios.rom)
	BIOS_ADDRESS ?= fe000
else ifeq ($(BIOS),phoenix)
	BIOS_BIN ?= $(abspath $(VMDIR)/../phoenix-2.51.rom)
	BIOS_ADDRESS ?= fe000
else
	BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)
	BIOS_ADDRESS ?= fc000
endif

BIOS_NAME = $(basename $(notdir $(BIOS_BIN)))

DISKS ?= freedos-simple

# this defines a string with a single space
SPACE = $(eval) $(eval)
VM_NAME = vm.$(BIOS_NAME).$(subst $(SPACE),.,$(DISKS)).input

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

SOFTWARE_OBJDIR ?= $(VMDIR)/obj/software

.PHONY: build
build: build-prep $(BINDIR)/$(VM_NAME)

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

.PHONY: run
run: build
	$(ICVM) $(BINDIR)/$(VM_NAME)

# The order of the object files matters, the BIOS and floppy binaries need to be the last objects.

VM_OBJS = main.o callback.o config.o vm_ports.o $(BIOS_NAME)_address.o $(BINDIR)/libcpu.a \
	$(BINDIR)/libcga.a $(BINDIR)/libdev.a $(BINDIR)/libfdc.a $(BINDIR)/libutil.a $(LIBXIB) \
	$(BIOS_NAME:=.o)

$(BINDIR)/$(VM_NAME): $(VM_OBJS:%.o=$(OBJDIR)/%.o) $(DISKS:%=$(SOFTWARE_OBJDIR)/%.o) \
	$(OBJDIR)/last_image.o
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

.PHONY: clean
clean:
	rm -rf $(BINDIR)/vm.*.input* $(OBJDIR)
