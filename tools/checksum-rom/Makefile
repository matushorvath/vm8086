ifeq ($(OS),Windows_NT)
	EXE := .exe
else
	EXE :=
endif

TARGET := checksum-rom$(EXE)
CFLAGS ?= -O2 -Wall -Wextra -Werror

.PHONY: all
all: $(TARGET)

$(TARGET): checksum-rom.c
	$(CC) $(CFLAGS) -o $@ $<

.PHONY: clean
clean:
	rm -f $(TARGET)

.PHONY: very-clean
very-clean: clean
