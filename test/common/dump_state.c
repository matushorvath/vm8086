// this should generate the same output as dump_state.s in the vm

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

void error(const char *message) {
    fprintf(stderr, "%s\n", message);
    exit(1);
}

uint16_t read16(FILE *fin, bool allowEof) {
    int lo = fgetc(fin);
    if (lo == EOF) {
        if(!ferror(fin)) {
            if (allowEof) return 0x0000;
            else error("Unexpected end of file");
        }
        error("Error while reading file");
    }

    int hi = fgetc(fin);
    if (hi == EOF) {
        if(!ferror(fin)) error("Unexpected end of file");
        error("Error while reading file");
    }

    return (uint16_t)hi * 0x100 + (uint16_t)lo;
}

void print_b8(FILE *fout, uint8_t b) {
    fprintf(fout, "%c%c%c%c%c%c%c%c",
        (b & 0b10000000) ? '1' : '0',
        (b & 0b01000000) ? '1' : '0',
        (b & 0b00100000) ? '1' : '0',
        (b & 0b00010000) ? '1' : '0',
        (b & 0b00001000) ? '1' : '0',
        (b & 0b00000100) ? '1' : '0',
        (b & 0b00000010) ? '1' : '0',
        (b & 0b00000001) ? '1' : '0');
}

void dump_flags(FILE *fin, FILE *fout) {
    uint16_t flags = read16(fin, false);

    fprintf(fout, " flags: ----%c%c%c%c %c%c-%c-%c-%c ",
        (flags & 0b0000100000000000) ? 'O' : 'o',
        (flags & 0b0000010000000000) ? 'D' : 'd',
        (flags & 0b0000001000000000) ? 'I' : 'i',
        (flags & 0b0000000100000000) ? 'T' : 't',
        (flags & 0b0000000010000000) ? 'S' : 's',
        (flags & 0b0000000001000000) ? 'Z' : 'z',
        (flags & 0b0000000000010000) ? 'A' : 'a',
        (flags & 0b0000000000000100) ? 'P' : 'p',
        (flags & 0b0000000000000001) ? 'C' : 'c');

    print_b8(fout, flags >> 8);
    fprintf(fout, " ");
    print_b8(fout, flags & 0xff);

    fprintf(fout, " (%04x)", flags);
}

#define DUMP_STACK_BYTES                16

void dump_stack(FILE *fin, FILE *fout) {
    fprintf(fout, "stack:");

    for (int i = 0; i < DUMP_STACK_BYTES; i += 2) {
        uint16_t word = read16(fin, false);
        fprintf(fout, " %04x", word);
    }
}

void record0000(FILE *fin, FILE *fout) {
    fprintf(fout, "----------\n");

    fprintf(fout, "ip: %04x", read16(fin, false));
    dump_flags(fin, fout);
    fprintf(fout, "\n");

    fprintf(fout, "cs: %04x", read16(fin, false));
    fprintf(fout, " ds: %04x", read16(fin, false));
    fprintf(fout, " ss: %04x", read16(fin, false));
    fprintf(fout, " es: %04x", read16(fin, false));
    fprintf(fout, " bp: %04x", read16(fin, false));
    fprintf(fout, " sp: %04x", read16(fin, false));
    fprintf(fout, "\n");

    fprintf(fout, "ax: %04x", read16(fin, false));
    fprintf(fout, " bx: %04x", read16(fin, false));
    fprintf(fout, " cx: %04x", read16(fin, false));
    fprintf(fout, " dx: %04x", read16(fin, false));
    fprintf(fout, " si: %04x", read16(fin, false));
    fprintf(fout, " di: %04x", read16(fin, false));
    fprintf(fout, "\n");

    dump_stack(fin, fout);
    fprintf(fout, "\n");
}

int main(int argc, char *argv[]) {
    if (argc != 3) error("Usage: dump_state input.serial output.txt");

    printf("Serial log: %s\n", argv[1]);

    FILE *fin = fopen(argv[1], "rb");
    if (!fin) error("Error while opening input file");

    printf("Output    : %s\n", argv[2]);

    FILE *fout = fopen(argv[2], "wt");
    if (!fout) error("Error while opening output file");

    while (true) {
        uint16_t type = read16(fin, true);
        printf("  record type 0x%04x\n", type);

        if (type == 0x0000) break;
        else if (type == 0x0001) record0000(fin, fout);
        else error("Unknown record type");
    }

    printf("Serial log formatted\n");

    fclose(fin);
    fclose(fout);

    return 0;
}
