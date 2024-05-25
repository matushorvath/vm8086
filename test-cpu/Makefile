VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

export ICVM

OBJDIR ?= obj

.PHONY: build
build: build-prep build-js build-intcode

.PHONY: build-prep
build-prep:
	mkdir -p "$(OBJDIR)"

.PHONY: build-js
build-js:
	npm install
	npm test

.PHONY: build-intcode
build-intcode: $(OBJDIR)/test.input

.PHONY: test
test: build
	node test.js

# The order of the object files matters: First include all the code in any order, then binary.o,
# then the (optional) 8086 image header and data.

TEST_OBJS = $(OBJDIR)/main.o $(OBJDIR)/callback.o $(OBJDIR)/config.o $(OBJDIR)/init_test.o \
	$(OBJDIR)/print_output.o $(VMDIR)/bin/libcpu.a $(VMDIR)/bin/libutil.a $(LIBXIB) \
	$(OBJDIR)/test_header.o

$(OBJDIR)/test.input: $(TEST_OBJS)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(OBJDIR)
	rm -rf node_modules
	rm -rf test.log
