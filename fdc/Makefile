VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/fdc

.PHONY: build
build: build-prep $(BINDIR)/libfdc.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

DEV_OBJS = commands.o control.o drives.o images.o init.o state_machine.o

$(BINDIR)/libfdc.a: $(DEV_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/libfdc.a* $(OBJDIR)
