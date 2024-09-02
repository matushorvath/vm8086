import timers from 'node:timers/promises';

const main = async () => {
    for (let j = 0; j < 1000; j++) {
        process.stdout.write("\x1bPq"); // enter sixel mode

        for (let i = 0; i < 500; i++) {
            const pos = 6 - Math.round((Math.sin(2 * Math.PI * (i + j) / 500) + 1) * 6 / 2);
            process.stdout.write(String.fromCharCode(63 + (1 << pos))); // enter sixel mode
        }

        //process.stdout.write("$"); // next sixel line * 2
        process.stdout.write("\x1b\\"); // exit sixel mode

        await timers.setTimeout(100);
    }

    process.stdout.write("\x1b\\"); // exit sixel mode
};

await main();
