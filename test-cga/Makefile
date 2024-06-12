VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/test-cga

.PHONY: build
build: build-prep $(BINDIR)/test-cga.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

# The order of the object files matters, the 8086 binary needs to be the last object.

TEST_CGA_OBJS = main.o binary_header.o config.o shutdown.o $(BINDIR)/libcpu.a $(BINDIR)/libcga.a \
	$(BINDIR)/libutil.a $(LIBXIB) cga_test.o

$(BINDIR)/test-cga.input: $(TEST_CGA_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ld)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

$(OBJDIR)/%.o: $(OBJDIR)/%.bin
	$(eval BIN2OBJ_NAME = binary)
	$(run-intcode-bin2obj)

$(OBJDIR)/cga_test.bin: cga_test.asm
	nasm -f bin $< -o $@
	#hexdump -C $@ ; true

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
