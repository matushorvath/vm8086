ICDIR ?= $(abspath ../xzintbit)
include intcode.mk

BINDIR ?= bin
OBJDIR ?= obj

# Build
.PHONY: build
build: cpu

.PHONY: cpu
cpu:
	make -C cpu

.PHONY: build-test
build-test: build-test-bochs build-test-cpu

.PHONY: build-test-bochs
build-test-bochs:
	make -C test-bochs

.PHONY: build-test-cpu
build-test-cpu:
	make -C test-cpu

.PHONY: build-all
build-all: build build-test

# Test
.PHONY: test
test: test-bochs

.PHONY: test-long
test-long: test test-cpu

.PHONY: validate
validate: validate-bochs

.PHONY: test-bochs
test-bochs: build
	make -C test-bochs test

.PHONY: validate-bochs
validate-bochs: build
	make -C test-bochs validate

.PHONY: test-cpu
test-cpu: build
	make -C test-cpu test

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
	make -C cpu clean
	make -C test-bochs clean
	make -C test-cpu clean
