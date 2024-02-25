# ICDIR=~/xzintbit MSBASICDIR=~/vm6502/msbasic FUNCTESTDIR=~/vm6502/6502_65C02_functional_tests make

ICVM_TYPE ?= c

ICDIR ?= $(error ICDIR variable is not set; point it where https://github.com/matushorvath/xzintbit is built)
MSBASICDIR ?= $(error MSBASICDIR variable is not set; point it where https://github.com/matushorvath/msbasic is built)
FUNCTESTDIR ?= $(error FUNCTESTDIR variable is not set; point it where https://github.com/Klaus2m5/6502_65C02_functional_tests is cloned)

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
ICLD ?= $(abspath $(ICDIR)/bin/ld.input)
ICLDMAP ?= $(abspath $(ICDIR)/bin/ldmap.input)
LIBXIB ?= $(abspath $(ICDIR)/bin/libxib.a)

SRCDIR = .
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

# TODO write bin2obj in intcode
define run-bin2obj
echo ".C\n$$(wc -c $^ | cut -d' ' -f1)$$(hexdump -ve '/1 ",%u"' $^)\n.R\n.I\n.E\nbinary_length:0\nbinary_data:1" > $@
endef

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm6502.input $(BINDIR)/msbasic.input $(BINDIR)/func_tests.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

VM6502_OBJS = vm6502.o arithmetic.o bits.o bitwise.o branch.o error.o exec.o flags.o incdec.o \
	loadstore.o memory.o opcodes.o params.o pushpull.o shift.o state.o util.o binary.o

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

MSBASIC_OBJS = $(VM6502_OBJS) msbasic_header.o msbasic_binary.o

$(BINDIR)/msbasic.input: $(addprefix $(OBJDIR)/, $(MSBASIC_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/msbasic_binary.o: $(MSBASICDIR)/tmp/vm6502.bin
	$(run-bin2obj)

FUNC_TESTS_OBJS = $(VM6502_OBJS) func_tests_header.o func_tests_binary.o

$(BINDIR)/func_tests.input: $(addprefix $(OBJDIR)/, $(FUNC_TESTS_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/func_tests_binary.o: $(FUNCTESTDIR)/bin_files/6502_functional_test.bin
	$(run-bin2obj)

GEN_BITS_OBJS = gen_bits.o

$(BINDIR)/gen_bits.input: $(addprefix $(OBJDIR)/, $(GEN_BITS_OBJS)) $(LIBXIB)
	$(run-ld)

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
