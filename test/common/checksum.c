#include <stdio.h>
#include <stdint.h>

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

    int ch;
    int lastCh;
    while ((ch = fgetc(f)) != EOF) {
        lastCh = ch;
        checksum -= (uint8_t)ch;
    }

    if (ferror(f)) {
        fprintf(stderr, "Error while reading file\n");
        fclose(f);
        return 1;
    }

    printf("Checksum:  0x%02x\n", checksum);

    if (lastCh != 0) {
        fprintf(stderr, "Refusing to overwrite a non-zero byte\n");
        fclose(f);
        return 1;
    }

    if (fseek(f, -1, SEEK_END)) {
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
