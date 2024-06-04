VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)
BIOS_LOAD_ADDRESS ?= fc000

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

BIOS_NAME = $(basename $(notdir $(BIOS_BIN)))
VM_NAME = vm.$(BIOS_NAME).input

.PHONY: build
build: build-prep $(BINDIR)/$(VM_NAME)

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters, the 8086 binary needs to be the last object.

VM_OBJS = main.o config.o header.o ports.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a \
	$(BINDIR)/libdev.a $(BINDIR)/libutil.a $(LIBXIB) $(BIOS_NAME).o

$(BINDIR)/$(VM_NAME): $(VM_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)
	@echo VM name: $(VM_NAME)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

$(OBJDIR)/$(BIOS_NAME).o: $(BIOS_BIN)
	$(run-intcode-bin2obj)

$(OBJDIR)/header.o: $(OBJDIR)/header.s
	$(run-intcode-as)

$(OBJDIR)/header.s: header.template
	sed -e 's/BIOS_LOAD_ADDRESS/$(BIOS_LOAD_ADDRESS)/g' < $< > $@

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
