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

CGA_OBJS = cga.o cp437.o log.o memory.o palette.o registers.o screen.o status.o text_mode.o

$(BINDIR)/libcga.a: $(CGA_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

# Some data tables are generated at compile time for performance reasons

GENERATOR_OBJS = unicode.o $(BINDIR)/libutil.a

.PRECIOUS: $(OBJDIR)/%.o
$(OBJDIR)/%.o: $(OBJDIR)/%.s
	$(run-intcode-as)

.PRECIOUS: $(OBJDIR)/%.s
$(OBJDIR)/%.s: $(OBJDIR)/gen_%.input
	$(ICVM) $< > $@ || ( cat $@ ; false )

.PRECIOUS: $(OBJDIR)/gen_%.input
$(OBJDIR)/gen_%.input: $(OBJDIR)/gen_%.o $(GENERATOR_OBJS:%.o=$(OBJDIR)/%.o) $(LIBXIB)
	$(run-intcode-ld)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/libcga.a* $(OBJDIR)
