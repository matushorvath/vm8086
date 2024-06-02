VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)
BIOS_LOAD_ADDRESS ?= fc000

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

.PHONY: build
build: build-prep $(BINDIR)/vm.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters, the 8086 binary needs to be the last object.

VM_OBJS = main.o config.o header.o ports.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a \
	$(BINDIR)/libdev.a $(BINDIR)/libutil.a $(LIBXIB) bios.o

$(BINDIR)/vm.input: $(VM_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

$(OBJDIR)/bios.o: $(BIOS_BIN)
	$(run-intcode-bin2obj)

$(OBJDIR)/header.o: $(OBJDIR)/header.s
	$(run-intcode-as)

$(OBJDIR)/header.s: header.template
	sed -e 's/BIOS_LOAD_ADDRESS/$(BIOS_LOAD_ADDRESS)/g' < $< > $@

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
