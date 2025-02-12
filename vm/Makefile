VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(ICDIR)/intcode.mk

ROMS ?= bios-xt
DISKS ?= freedos-simple

COMMA = ,
VM_NAME = vm.$(subst $(COMMA),.,$(ROMS).$(DISKS)).input

SOFTWARE_OBJDIR ?= $(VMDIR)/obj/software
SOFTWARE_HEADERS=$(patsubst %,$(SOFTWARE_OBJDIR)/%_header.o,$(subst $(COMMA), ,$(ROMS)))
SOFTWARE_IMAGES=$(patsubst %,$(SOFTWARE_OBJDIR)/%.o,$(subst $(COMMA), ,$(ROMS) $(DISKS)))

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/vm

.PHONY: build
build: build-prep $(BINDIR)/$(VM_NAME)

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

.PHONY: run
run: build
	$(ICVM) $(BINDIR)/$(VM_NAME)

# The order of the object files matters: after all regular sources comes headers.o,
# followed by ROM headers, followed by images.o, followed by ROM images in the same
# order as ROM headers, followed by floppy disk images

VM_OBJS = main.o callback.o config.o menu.o vm_ports.o $(BINDIR)/libcga.a $(BINDIR)/libcpu.a \
	$(BINDIR)/libdev.a $(BINDIR)/libfdc.a $(BINDIR)/libimg.a $(BINDIR)/libutil.a $(LIBXIB)
SOFTWARE_OBJS = $(OBJDIR)/headers.o $(SOFTWARE_HEADERS) $(OBJDIR)/images.o $(SOFTWARE_IMAGES)

$(BINDIR)/$(VM_NAME): $(VM_OBJS:%.o=$(OBJDIR)/%.o) $(SOFTWARE_OBJS)
	$(run-intcode-ld)
	@echo VM name: $(VM_NAME)

$(SOFTWARE_HEADERS) $(SOFTWARE_IMAGES) &:
	$(MAKE) -C $(VMDIR)/software build-prep $(SOFTWARE_HEADERS) $(SOFTWARE_IMAGES)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/vm.*.input* $(OBJDIR)
