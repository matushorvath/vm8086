import timers from 'node:timers/promises';

const ROWS = 30;
const COLS = 500;

const setPixel = (x, y, c) => {
    process.stdout.write('\x1b[1;1H'); // move to 1,1
    //process.stdout.write('\x1b[?80l'); // disable sixel scrolling
    process.stdout.write('\x1bP0;1;0q'); // enter sixel mode

    const row = Math.floor(y / 6);
    const pxl = y % 6;

    for (let r = 0; r < row; r++) {
        process.stdout.write('-');
    }

    process.stdout.write(`!${x}?`); // skip x columns

    process.stdout.write(String.fromCharCode(63 + (1 << pxl)));
    process.stdout.write('$');

    process.stdout.write('\x1b\\'); // exit sixel mode
};

const main = async () => {
    process.stdout.write('\x1b[?25l'); // hide cursor

    try {
        for (let phase = 0; phase < 1000; phase++) {
            for (let x = 0; x < COLS; x++) {
                const value = Math.sin(2 * Math.PI * (x + phase) / COLS);
                const y = Math.round((value + 1) * (ROWS - 1) / 2);

                setPixel(x, y, 1);
            }

            await timers.setTimeout(100);
        }
    } finally {
        process.stdout.write('\x1b[?25h'); // show cursor
    }
};

await main();
