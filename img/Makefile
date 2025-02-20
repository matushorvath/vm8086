VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/img

.PHONY: build
build: build-prep $(BINDIR)/libimg.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

DEV_OBJS = images.o inflate.o init.o floppy.o

$(BINDIR)/libimg.a: $(DEV_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/libimg.a* $(OBJDIR)
