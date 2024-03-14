# ICDIR=~/xzintbit make

ICVM_TYPE ?= c

ICDIR ?= $(abspath ../xzintbit)

ifeq ($(shell test -d $(ICDIR) || echo error),error)
	$(error ICDIR variable is invalid; point it where https://github.com/matushorvath/xzintbit is built)
endif

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
ICBIN2OBJ ?= $(abspath $(ICDIR)/bin/bin2obj.input)
ICLD ?= $(abspath $(ICDIR)/bin/ld.input)
ICLDMAP ?= $(abspath $(ICDIR)/bin/ldmap.input)
LIBXIB ?= $(abspath $(ICDIR)/bin/libxib.a)

SRCDIR = src
BINDIR ?= bin
OBJDIR ?= obj

define run-as
	cat $^ | $(ICVM) $(ICAS) > $@ || ( cat $@ ; false )
endef

define run-ar
	cat $^ | sed 's/^.C$$/.L/g' > $@ || ( cat $@ ; false )
endef

define run-ld
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@ || ( cat $@ ; false )
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml || ( cat $@.map.yaml ; false )
endef

define run-bin2obj
	ls -n $< | awk '{ printf "%s ", $$5 }' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@ || ( cat $@ ; false )
endef

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm8086.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 8086 image header and data.

BASE_OBJS = vm8086.o arg_reg.o bits.o decode.o error.o exec.o flags.o inc_dec.o instructions.o \
	location.o memory.o nibbles.o parity.o split233.o state.o util.o

VM8086_OBJS = $(BASE_OBJS) $(LIBXIB) binary.o

$(BINDIR)/vm8086.input: $(VM8086_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-ld)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	$(run-as)

# Intcode does not have a convenient way to manipulate individual bits of a number.
# For speed and convenience we will sacrifice some memory and memoize a few useful bit operations.

.PRECIOUS: $(OBJDIR)/%.o
$(OBJDIR)/%.o: $(OBJDIR)/%.s
	$(run-as)

.PRECIOUS: $(OBJDIR)/%.s
$(OBJDIR)/%.s: $(OBJDIR)/gen_%.input
	$(ICVM) $< > $@ || ( cat $@ ; false )

.PRECIOUS: $(OBJDIR)/gen_%.input
$(OBJDIR)/gen_%.input: $(OBJDIR)/gen_%.o $(LIBXIB)
	$(run-ld)

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
