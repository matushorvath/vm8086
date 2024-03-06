# ICDIR=~/xzintbit MSBASICDIR=~/vm6502/msbasic FUNCTESTDIR=~/vm6502/6502_65C02_functional_tests make

ICVM_TYPE ?= c

ICDIR ?= $(abspath ../xzintbit)
MSBASICDIR ?= $(abspath ../msbasic)
FUNCTESTDIR ?= $(abspath ../6502_65C02_functional_tests)

ifeq ($(shell test -d $(ICDIR) || echo error),error)
	$(error ICDIR variable is invalid; point it where https://github.com/matushorvath/xzintbit is built)
endif

ifeq ($(shell test -d $(MSBASICDIR) || echo error),error)
	$(error MSBASICDIR variable is invalid; point it where https://github.com/matushorvath/msbasic is built)
endif

ifeq ($(shell test -d $(FUNCTESTDIR) || echo error),error)
	$(error FUNCTESTDIR variable is invalid; point it where https://github.com/Klaus2m5/6502_65C02_functional_tests is cloned)
endif

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
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
	echo .L | cat - $^ > $@ || ( cat $@ ; false )
endef

define run-ld
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@ || ( cat $@ ; false )
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml || ( cat $@.map.yaml ; false )
endef

define run-bin2obj
	ls -n $< | awk '{ printf "%s ", $$5 }' | cat - $< | $(ICVM) $(BINDIR)/bin2obj.input > $@ || ( cat $@ ; false )
endef

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm6502.input $(BINDIR)/msbasic.input $(BINDIR)/func_test.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# Test
.PHONY: test
test: build msbasic_test func_test

.PHONY: msbasic_test
msbasic_test: $(BINDIR)/msbasic.input
	< $(SRCDIR)/msbasic_test.in $(ICVM) $(BINDIR)/msbasic.input 2> /dev/null | diff -r - $(SRCDIR)/msbasic_test.out

.PHONY: func_test
func_test: $(BINDIR)/func_test.input
	$(ICVM) $(BINDIR)/func_test.input < /dev/null

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 6502 image header and data.

BASE_OBJS = vm6502.o arithmetic.o bits.o bitwise.o branch.o error.o exec.o flags.o incdec.o \
	instructions.o loadstore.o memory.o params.o pushpull.o shift.o state.o trace.o util.o

VM6502_OBJS = $(BASE_OBJS) binary.o

$(BINDIR)/vm6502.input: $(addprefix $(OBJDIR)/, $(VM6502_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	$(run-as)

# Intcode does not have a convenient way to access individual bits of a byte.
# For speed and convenience we will sacrifice 256 * 8 = 2048 bytes and memoize the operation.
# The table for that is generated using gen_bits.s and can be found in file $(OBJDIR)/bits.s.

$(OBJDIR)/bits.o: $(OBJDIR)/bits.s
	$(run-as)

$(OBJDIR)/bits.s: $(BINDIR)/gen_bits.input
	$(ICVM) $(BINDIR)/gen_bits.input > $@ || ( cat $@ ; false )

MSBASIC_OBJS = $(BASE_OBJS) binary.o msbasic_header.o msbasic_binary.o

$(BINDIR)/msbasic.input: $(addprefix $(OBJDIR)/, $(MSBASIC_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/msbasic_binary.o: $(MSBASICDIR)/tmp/vm6502.bin $(BINDIR)/bin2obj.input
	$(run-bin2obj)

FUNC_TEST_OBJS = $(BASE_OBJS) func_test_callback.o binary.o func_test_header.o func_test_binary.o

$(BINDIR)/func_test.input: $(addprefix $(OBJDIR)/, $(FUNC_TEST_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/func_test_binary.o: $(FUNCTESTDIR)/bin_files/6502_functional_test.bin $(BINDIR)/bin2obj.input
	$(run-bin2obj)

GEN_BITS_OBJS = gen_bits.o

$(BINDIR)/gen_bits.input: $(addprefix $(OBJDIR)/, $(GEN_BITS_OBJS)) $(LIBXIB)
	$(run-ld)

BIN2OBJ_OBJS = bin2obj.o

$(BINDIR)/bin2obj.input: $(addprefix $(OBJDIR)/, $(BIN2OBJ_OBJS)) $(LIBXIB)
	$(run-ld)

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
