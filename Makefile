ICDIR ?= $(abspath ../xzintbit)
include intcode.mk

BINDIR ?= bin
OBJDIR ?= obj

SRCDIRS = cga cpu dev fdc img util test-cga vm
TOOLSDIR = monitor
TESTDIRS = test-bochs test-cpu

FLOPPY ?= freedos
FLOPPY_TARGET="$(FLOPPY).img"

# Build VM
.PHONY: build
build: $(SRCDIRS)

.PHONY: $(SRCDIRS)
$(SRCDIRS):
	make -C $@ build
img:
	make -C $@ 

.PHONY: run
run: build
	make -C vm run

# Build tools
.PHONY: build-tools
build-tools: $(TOOLSDIR)

.PHONY: $(TOOLSDIR)
$(TOOLSDIR):
	make -C $@

# Build tests
BUILD_TESTS_TARGETS = $(addprefix build-,$(TESTDIRS))

.PHONY: build-tests
build-tests: $(BUILD_TESTS_TARGETS)

.PHONY: $(BUILD_TESTS_TARGETS)
$(BUILD_TESTS_TARGETS):
	make -C $(patsubst build-%,%,$@) build

.PHONY: build-all
build-all: build build-tools build-tests

# Run tests
.PHONY: test
test: test-bochs

.PHONY: test-all
test-all: test test-cpu

.PHONY: validate
validate: validate-bochs

.PHONY: validate-bochs
validate-bochs: build
	make -C test-bochs validate

.PHONY: $(TESTDIRS)
$(TESTDIRS): build
	make -C $@ test

# Clean
CLEAN_TARGETS = $(addprefix clean-,$(SRCDIRS) $(TOOLSDIR) $(TESTDIRS))

.PHONY: clean
clean: $(CLEAN_TARGETS)
	rm -rf $(BINDIR) $(OBJDIR)

.PHONY: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	make -C $(patsubst clean-%,%,$@) clean

VERY_CLEAN_TARGETS = very-clean-img very-clean-monitor

.PHONY: very-clean
very-clean: clean $(VERY_CLEAN_TARGETS)

.PHONY: $(VERY_CLEAN_TARGETS)
$(VERY_CLEAN_TARGETS):
	make -C $(patsubst very-clean-%,%,$@) very-clean
