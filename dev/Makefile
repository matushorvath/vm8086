VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/dev

.PHONY: build
build: build-prep $(BINDIR)/libdev.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

DEV_OBJS = dma_8237a.o fdc_commands.o fdc_config.o fdc_control.o fdc_drives.o fdc_fsm.o \
	fdc_init.o pit_8253.o pit_8253_ch0.o pit_8253_ch2.o ppi_8255a.o

$(BINDIR)/libdev.a: $(DEV_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/pit_8253_ch0.o: pit_8253_ch0.s pit_8253_common.si
$(OBJDIR)/pit_8253_ch2.o: pit_8253_ch2.s pit_8253_common.si

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/libdev.a* $(OBJDIR)
