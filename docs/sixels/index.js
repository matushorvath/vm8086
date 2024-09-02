import timers from 'node:timers/promises';

const ROWS = 30;
const COLS = 500;

const main = async () => {
    for (let phase = 0; phase < 1000; phase++) {
        process.stdout.write('\x1bPq'); // enter sixel mode

        for (let r = 0; r < ROWS / 6; r++) {
            for (let x = 0; x < COLS; x++) {
                const value = Math.sin(2 * Math.PI * (x + phase) / COLS);
                const y = Math.round((value + 1) * (ROWS - 1) / 2);

                const row = Math.floor(y / 6);
                const pxl = y % 6;

                if (r === row) {
                    process.stdout.write(String.fromCharCode(63 + (1 << pxl)));
                } else {
                    process.stdout.write(String.fromCharCode(63));
                }
            }

            process.stdout.write('-');
        }

        process.stdout.write('\x1b\\'); // exit sixel mode

        await timers.setTimeout(100);
    }

    process.stdout.write('\x1b\\'); // exit sixel mode
};

await main();
