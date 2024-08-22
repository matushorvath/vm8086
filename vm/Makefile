VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

ifeq ($(BIOS),pcxtbios)
	BIOS_BIN ?= $(abspath $(VMDIR)/../pcxtbios/eproms/2764/pcxtbios.rom)
	BIOS_ADDRESS ?= fe000
else
	BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)
	BIOS_ADDRESS ?= fc000
endif

BIOS_NAME = $(basename $(notdir $(BIOS_BIN)))

FLOPPY ?= freedos-simple

FLOPPY_A_BIN ?= $(abspath $(VMDIR)/img/$(word 1,$(FLOPPY)).img)
FLOPPY_B_BIN ?= $(abspath $(VMDIR)/img/$(word 2,$(FLOPPY)).img)

FLOPPY_A_NAME = $(patsubst %,%.floppy-a,$(basename $(notdir $(FLOPPY_A_BIN))))
FLOPPY_B_NAME = $(patsubst %,%.floppy-b,$(basename $(notdir $(FLOPPY_B_BIN))))

# this defines a string with a single space
SPACE = $(eval) $(eval)
VM_NAME = vm.$(BIOS_NAME).$(subst $(SPACE),.,$(FLOPPY)).input

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

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
	$(BIOS_NAME:=.o) $(FLOPPY_A_NAME:=.o) $(FLOPPY_B_NAME:=.o) $(OBJDIR)/fake_floppy.a

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

$(OBJDIR)/$(FLOPPY_A_NAME).o: $(FLOPPY_A_BIN)
	$(eval BIN2OBJ_NAME = floppy_a)
	$(run-intcode-bin2obj)

$(OBJDIR)/$(FLOPPY_B_NAME).o: $(FLOPPY_B_BIN)
	$(eval BIN2OBJ_NAME = floppy_b)
	$(run-intcode-bin2obj)

$(OBJDIR)/fake_floppy.a: $(OBJDIR)/fake_floppy.o
	$(run-intcode-ar)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/vm.*.input* $(OBJDIR)
