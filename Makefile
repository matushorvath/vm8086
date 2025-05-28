ICDIR ?= $(abspath ../xzintbit)
include $(ICDIR)/intcode.mk

BINDIR ?= bin
OBJDIR ?= obj

SRCDIRS = util cga cpu dev fdc img vm
TOOLSDIR = tools/checksum-rom tools/import-cleanup tools/monitor
TESTDIRS = test-bochs test-cpu

# Build VM
.PHONY: build
build: $(SRCDIRS)

.PHONY: $(SRCDIRS)
$(SRCDIRS):
	make -C $@ build

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

.PHONY: imports
imports: tools/import-cleanup
	node tools/import-cleanup/import-cleanup.js .

# Clean
CLEAN_TARGETS = $(addprefix clean-,$(SRCDIRS) $(TOOLSDIR) $(TESTDIRS))

.PHONY: clean
clean: $(CLEAN_TARGETS)
	rm -rf $(BINDIR) $(OBJDIR)

.PHONY: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	make -C $(patsubst clean-%,%,$@) clean

VERY_CLEAN_TARGETS = very-clean-tools/import-cleanup very-clean-tools/monitor

.PHONY: very-clean
very-clean: clean $(VERY_CLEAN_TARGETS)

.PHONY: $(VERY_CLEAN_TARGETS)
$(VERY_CLEAN_TARGETS):
	make -C $(patsubst very-clean-%,%,$@) very-clean
