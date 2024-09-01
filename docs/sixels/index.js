const main = async () => {
    // TODO p2 = 1: keep 0 bits unchanged
    process.stdout.write("\x1bPq"); // enter sixel mode

    for (let i = 0; i < 500; i++) {
        const pos = 6 - Math.round((Math.sin(2 * Math.PI * i / 500) + 1) * 6 / 2);
        process.stdout.write(String.fromCharCode(63 + (1 << pos))); // enter sixel mode
    }

    process.stdout.write("--"); // next sixel line * 2

    process.stdout.write("\x1b\\"); // exit sixel mode
};

await main();
