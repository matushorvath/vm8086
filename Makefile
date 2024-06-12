ICDIR ?= $(abspath ../xzintbit)
include intcode.mk

BINDIR ?= bin
OBJDIR ?= obj

SRCDIRS = cga cpu dev util test-cga vm
TESTDIRS = test-bochs test-cpu

# Build VM
.PHONY: build
build: $(SRCDIRS)

.PHONY: $(SRCDIRS)
$(SRCDIRS):
	make -C $@

.PHONY: run
run: build
	make -C vm run

# Build tests
BUILD_TESTS_TARGETS = $(addprefix build-,$(TESTDIRS))

.PHONY: build-tests
build-tests: $(BUILD_TESTS_TARGETS)

.PHONY: $(BUILD_TESTS_TARGETS)
$(BUILD_TESTS_TARGETS):
	make -C $(patsubst build-%,%,$@) build

.PHONY: build-all
build-all: build build-tests

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
$(TESTDIRS):
	make -C $@ test

# Clean
CLEAN_TARGETS = $(addprefix clean-,$(SRCDIRS) $(TESTDIRS))

.PHONY: clean
clean: $(CLEAN_TARGETS)
	rm -rf $(BINDIR) $(OBJDIR)

.PHONY: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	make -C $(patsubst clean-%,%,$@) clean
