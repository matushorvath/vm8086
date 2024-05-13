VMDIR = $(abspath ..)

ICDIR ?= $(abspath ../../xzintbit)
include $(VMDIR)/intcode.mk

RESDIR ?= res
OBJDIR ?= obj

LIBCPU = $(VMDIR)/bin/libcpu.a

# Build
.PHONY: build
build: build-prep build-js build-intcode

.PHONY: build-prep
build-prep:
	mkdir -p "$(RESDIR)" "$(OBJDIR)"

.PHONY: build-js
build-js:
	npm install
	npm test

.PHONY: build-intcode
build-intcode: $(OBJDIR)/test.input

# Test
.PHONY: test
test: build

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 8086 image header and data.

TEST_OBJS = $(OBJDIR)/main.o $(OBJDIR)/init_test.o $(OBJDIR)/print_output.o $(LIBCPU) $(LIBXIB) \
	$(OBJDIR)/test_header.o

$(OBJDIR)/test.input: $(TEST_OBJS)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

# Clean
.PHONY: clean
clean:
	rm -rf $(RESDIR) $(OBJDIR)
