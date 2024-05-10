# ICDIR=~/xzintbit make

ICDIR ?= $(abspath ../xzintbit)
include intcode.mk

SRCDIR = src
BINDIR ?= bin
OBJDIR ?= obj

TESTDIRS = $(sort $(dir $(wildcard test/*/Makefile)))
export TESTLOG = $(abspath test/test.log)

# Build
.PHONY: build
build: build-prep $(BINDIR)/libcpu.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# Test
.PHONY: test
test: build run-test-test

.PHONY: validate
validate: build run-test-validate

.PHONY: test-all
test-all: build run-test-all

.PHONY: test-build
test-build: build run-test-build

define run-each-test
	rm -rf $(TESTLOG)
	failed=0 ; \
	for testdir in $(TESTDIRS) ; do \
		$(MAKE) -C $$testdir $(subst run-test-,,$@) || failed=1 ; \
	done ; \
	cat test/test.log ; \
	[ $$failed = 0 ] || exit 1
endef

.PHONY: run-test-test
run-test-test:
	$(run-each-test)

.PHONY: run-test-validate
run-test-validate:
	$(run-each-test)

.PHONY: run-test-all
run-test-all:
	$(run-each-test)

.PHONY: run-test-build
run-test-build:
	$(run-each-test)

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 8086 image header and data.

CPU_OBJS = add.o arithmetic.o arg_al_ax_near_ptr.o arg_mod_op_rm.o arg_mod_reg_rm.o \
	arg_reg.o arg_reg_immediate_b.o arg_reg_immediate_w.o bcd.o bits.o bitwise.o call.o decode.o \
	div.o error.o execute.o flags.o group1.o group2.o group_immed.o group_shift.o in_out.o \
	inc_dec.o instructions.o interrupt.o jump.o jump_flag.o load.o location.o loop.o memory.o \
	mod9.o mod17.o mul.o nibbles.o parity.o prefix.o rotate_b.o rotate_w.o shift_b.o shift_w.o \
	shl.o shr.o split233.o stack.o state.o string.o sub_cmp.o test_api.o trace.o trace_data.o \
	transfer_address.o transfer_value.o util.o

$(BINDIR)/libcpu.a: $(CPU_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	$(run-intcode-as)

# Intcode does not have a convenient way to manipulate individual bits of a number.
# For speed and convenience we will sacrifice some memory and memoize a few useful bit operations.

.PRECIOUS: $(OBJDIR)/%.o
$(OBJDIR)/%.o: $(OBJDIR)/%.s
	$(run-intcode-as)

.PRECIOUS: $(OBJDIR)/%.s
$(OBJDIR)/%.s: $(OBJDIR)/gen_%.input
	$(ICVM) $< > $@ || ( cat $@ ; false )

.PRECIOUS: $(OBJDIR)/gen_%.input
$(OBJDIR)/gen_%.input: $(OBJDIR)/gen_%.o $(LIBXIB)
	$(run-intcode-ld)

# Clean
.PHONY: clean
clean:
	for testdir in $(TESTDIRS) ; do $(MAKE) -C $$testdir clean ; done
	rm -rf $(BINDIR) $(OBJDIR)
	rm -rf $(TESTLOG)
