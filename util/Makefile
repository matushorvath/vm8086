VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/util

.PHONY: build
build: build-prep $(BINDIR)/libutil.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

UTIL_OBJS = bits.o bits_ng.o brk.o crumbs.o div5.o error.o log.o mod9.o mod17.o nibbles.o \
	parity.o printb.o shl.o shr.o split233.o util.o

$(BINDIR)/libutil.a: $(UTIL_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

# Intcode does not have a convenient way to manipulate individual bits of a number.
# For speed and convenience we will sacrifice some memory and memoize a few useful bit operations.

GENERATOR_OBJS = generator.o

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
	rm -rf $(BINDIR)/libutil.a* $(OBJDIR)
