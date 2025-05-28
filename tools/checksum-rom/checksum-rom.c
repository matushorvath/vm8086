#include <stdio.h>
#include <stdint.h>

// TODO Rewrite this in intcode

int read_rom(FILE *f, uint8_t *checksum, long *rom_size) {
    *checksum = 0;
    *rom_size = 0;

    int ch;

    if ((ch = fgetc(f)) == EOF) {
        fprintf(stderr, "Missing ROM signature, byte 0\n", ch);
        return -1;
    }
    if (ch != 0x55) {
        fprintf(stderr, "Invalid ROM signature: expected 0x55, got 0x%02x\n", ch);
        return -1;
    }
    *checksum -= (uint8_t)ch;

    if ((ch = fgetc(f)) == EOF) {
        fprintf(stderr, "Missing ROM signature, byte 1\n", ch);
        return -1;
    }
    if (ch != 0xaa) {
        fprintf(stderr, "Invalid ROM signature: expected 0xaa, got 0x%02x\n", ch);
        return -1;
    }
    *checksum -= (uint8_t)ch;

    if ((ch = fgetc(f)) == EOF) {
        fprintf(stderr, "Missing ROM size\n", ch);
        return -1;
    }
    *checksum -= (uint8_t)ch;
    *rom_size = (long)ch * 0x200;

    while ((ch = fgetc(f)) != EOF) {
        *checksum -= (uint8_t)ch;
    }

    if (ferror(f)) {
        fprintf(stderr, "Error while reading file\n");
        fclose(f);
        return 1;
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: checksum image.bin\n");
        return 1;
    }

    printf("File name: %s\n", argv[1]);

    FILE *f = fopen(argv[1], "rb+");
    if (!f) {
        fprintf(stderr, "Error while opening file\n");
        return 1;
    }

    uint8_t checksum = 0;
    long rom_size = 0;

    if (read_rom(f, &checksum, &rom_size) != 0) {
        fclose(f);
        return 1;
    }

    printf("Checksum:  0x%02x\n", checksum);

    if (fseek(f, 0, SEEK_END)) {
        fprintf(stderr, "Error while determining file size\n");
        fclose(f);
        return 1;
    }

    int file_size = ftell(f);
    if (file_size >= rom_size) {
        fprintf(stderr, "File size must be smaller than ROM size in header: file size %d bytes, ROM size %d bytes\n", file_size, rom_size);
        fclose(f);
        return 1;
    }

    if (fseek(f, rom_size - 1, SEEK_SET)) {
        fprintf(stderr, "Error while setting file position\n");
        fclose(f);
        return 1;
    }

    if (fputc((char)checksum, f) == EOF && ferror(f)) {
        fprintf(stderr, "Error while writing checksum\n");
        fclose(f);
        return 1;
    }

    printf("File updated\n");

    fclose(f);
    return 0;
}
