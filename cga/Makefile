VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/cga

.PHONY: build
build: build-prep $(BINDIR)/libcga.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

CGA_OBJS = cga.o

$(BINDIR)/libcga.a: $(CGA_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
