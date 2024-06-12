VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

BINDIR ?= $(VMDIR)/bin
OBJDIR ?= $(VMDIR)/obj/cpu

.PHONY: build
build: build-prep $(BINDIR)/libcpu.a

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

CPU_OBJS = add.o arithmetic.o arg_al_ax_near_ptr.o arg_mod_op_rm.o arg_mod_reg_rm.o arg_reg.o \
	arg_reg_immediate_b.o arg_reg_immediate_w.o bcd.o bitwise.o call.o decode.o devices.o div.o \
	execute.o flags.o group1.o group2.o group_immed.o group_shift.o in_out.o inc_dec.o \
	init_binary.o instructions.o interrupt.o jump.o jump_flag.o location.o loop.o memory.o mul.o \
	prefix.o rotate_b.o rotate_w.o shift_b.o shift_w.o stack.o state.o string.o sub_cmp.o \
	trace.o trace_data.o transfer_address.o transfer_value.o

$(BINDIR)/libcpu.a: $(CPU_OBJS:%.o=$(OBJDIR)/%.o)
	$(run-intcode-ar)

$(OBJDIR)/%.o: %.s
	$(run-intcode-as)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/libcpu.a* $(OBJDIR)
