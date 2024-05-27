VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BIOS_BIN ?= $(abspath $(VMDIR)/../8088_bios/binaries/bios-xt.bin)

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

.PHONY: build
build: build-prep $(BINDIR)/vm.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters, the 8086 binary needs to be the last object.

VM_OBJS = main.o binary_header.o config.o ports.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a \
	$(BINDIR)/libutil.a $(LIBXIB) bios.o

$(BINDIR)/vm.input: $(VM_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

$(OBJDIR)/bios.o: $(BIOS_BIN)
	$(run-intcode-bin2obj)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
