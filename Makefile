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

TESTDIRS = $(sort $(dir $(wildcard test/*/Makefile)))
export TESTLOG = $(abspath test/test.log)

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
	wc -c $< | sed 's/$$/\/binary/' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@ || ( cat $@ ; false )
endef

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm8086.input build-test-header

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# Test
.PHONY: test
test: build build-test-header run-test-test

.PHONY: validate
validate: build build-test-header run-test-validate

.PHONY: test-all
test-all: build build-test-header run-test-all

.PHONY: test-build
test-build: build build-test-header run-test-build

.PHONY: build-test-header
build-test-header: $(OBJDIR)/test_header.o

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

BASE_OBJS = vm8086.o add.o arg_al_ax_near_ptr.o arg_mod_op_rm.o arg_mod_reg_rm.o arg_reg.o \
	arg_reg_immediate_b.o arg_reg_immediate_w.o bits.o bitwise.o call.o decode.o dump_state.o \
	error.o execute.o flags.o group1.o group2.o group_immed.o group_shift.o in_out.o inc_dec.o \
	instructions.o interrupt.o jump.o jump_flag.o load.o location.o loop.o memory.o nibbles.o \
	parity.o prefix.o shift.o shr.o split233.o stack.o state.o sub_cmp.o trace.o trace_data.o \
	transfer_address.o transfer_value.o util.o

$(BINDIR)/lib8086.a: $(BASE_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-ar)

VM8086_OBJS = $(BINDIR)/lib8086.a $(LIBXIB) binary.o

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
	for testdir in $(TESTDIRS) ; do $(MAKE) -C $$testdir clean ; done
	rm -rf $(BINDIR) $(OBJDIR)
	rm -rf $(TESTLOG)
