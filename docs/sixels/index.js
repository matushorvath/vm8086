import timers from 'node:timers/promises';

const ROWS = 30;
const COLS = 500;

const setPixel = (x, y, c) => {
    process.stdout.write('\x1bP0;1;0q'); // enter sixel mode

    const row = Math.floor(y / 6);
    const pxl = y % 6;

    for (let r = 0; r < row; r++) {
        process.stdout.write('-');
    }

    process.stdout.write(`!${x}?`); // skip x columns

    if (c === 1) {
        process.stdout.write(String.fromCharCode(63 + (1 << pxl)));
    } else {
        // TODO set the pixel to background
        process.stdout.write('?');
    }

    process.stdout.write('$');

    process.stdout.write('\x1b\\'); // exit sixel mode
};

const main = async () => {
    process.stdout.write('\x1b[?25l'); // hide cursor
    process.stdout.write('\x1b[?80h'); // disable sixel scrolling

    const prev = [];

    try {
        for (let phase = 0; phase < 1000; phase++) {
            for (let x = 0; x < COLS; x++) {
                const value = Math.sin(2 * Math.PI * (x + phase) / COLS);
                const y = Math.round((value + 1) * (ROWS - 1) / 2);

                if (prev[x] !== undefined) {
                    setPixel(x, prev[x], 0);
                }
                prev[x] = y;

                setPixel(x, y, 1);
            }

            await timers.setTimeout(100);
        }
    } finally {
        process.stdout.write('\x1b[?25h'); // show cursor
    }
};

await main();
