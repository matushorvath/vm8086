// CFLAGS='-O3 -DINA' make test-in && time ./test-in < /dev/zero
// CFLAGS='-O3 -DIN' make test-in && time ./test-in < /dev/zero

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include <termios.h>
#include <unistd.h>
#include <poll.h>
#include <errno.h>

#define READ_EOF                        -1
#define READ_NO_DATA                    -2

#define TERM_SHOW_CURSOR    "\x1b[?25h"
#define TERM_RESET_ATTR     "\x1b[0m"

#define STRLEN(s) (sizeof(s) / sizeof(s[0]) - 1)

struct termios orig_attr;

void restore_terminal(void) {
    if (isatty(STDOUT_FILENO)) {
        (void)!write(STDOUT_FILENO, TERM_SHOW_CURSOR, STRLEN(TERM_SHOW_CURSOR));
        (void)!write(STDOUT_FILENO, TERM_RESET_ATTR, STRLEN(TERM_RESET_ATTR));
    }

    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_attr);
}

void init_terminal(bool extended) {
    if (extended) {
        tcgetattr(STDIN_FILENO, &orig_attr);
        atexit(&restore_terminal);

        struct termios attr = orig_attr;
        attr.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
        attr.c_oflag &= ~(OPOST);
        attr.c_cflag |= (CS8);
        attr.c_lflag &= ~(ECHO | ICANON | IEXTEN); // keep ISIG for Ctrl+C, Ctrl+Z

        tcsetattr(STDIN_FILENO, TCSAFLUSH, &attr);
    }
}

int read_sync(void) {
    int ch = getc(stdin);
    return ch == EOF ? READ_EOF : ch;
}

int read_async(void) {
#ifndef NO_POLL
    // is there data to read?
    struct pollfd fd = {};
    fd.fd = STDIN_FILENO;
    fd.events = POLLIN;

    int res = poll(&fd, 1, 0);
    if (res < 0) {
        fprintf(stderr, "error while waiting for input: %i", errno);
        exit(1);
    }

    if (res == 0 || (fd.revents & POLLIN) == 0 ) {
        if ((fd.revents & POLLHUP) != 0) {
            // end of input
            return READ_EOF;
        } else {
            // no data to read
            return READ_NO_DATA;
        }
    }
#endif // NO_POLL

    // read the data
    char ch = -1;
    ssize_t size = read(STDIN_FILENO, &ch, 1);
    if (size < 0) {
        fprintf(stderr, "error while reading input: %i", errno);
        exit(1);
    }

    if (size == 0) {
        return READ_EOF;
    }

    return ch;
}

int main() {
    init_terminal(true);

    int result = 0;
    int countRead = 0, countCalled = 0;
    const char *instruction;

    // INA:                     10000000 = 9.2s
    // INA w/o poll:            10000000 = 5.1s
    // IN:  1000000000 = 2.9s   10000000 = 0.03s
    while (result != READ_EOF && countRead < 10000000) {
#ifdef INA
        instruction = "ina";
        result = READ_NO_DATA;
        while (result == READ_NO_DATA) {
            result = read_async();
            countCalled++;
        }
#else // INA
        instruction = "in";
        result = read_sync();
        countCalled++;
#endif //INA
        countRead++;
    }

    printf("Count read %i, count waited %i, result %i, %s\n", countRead, countCalled - countRead, result, instruction);

    return 0;
}
