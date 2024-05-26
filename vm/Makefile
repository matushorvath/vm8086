VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

.PHONY: build
build: build-prep $(BINDIR)/vm.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 8086 image header and data.

VM_OBJS = vm.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a $(BINDIR)/libutil.a $(LIBXIB)

$(BINDIR)/vm.input: $(VM_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
