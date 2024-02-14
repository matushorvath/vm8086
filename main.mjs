import { Vm6502 } from './vm6502.mjs';
import fs from 'node:fs/promises';
import path from 'node:path';

const parseCommandLine = () => {
    try {
        if (process.argv.length < 4 || process.argv.length > 5) {
            throw new Error('invalid command line');
        }

        if (!/[0-9a-fA-F]{4}/.test(process.argv[2])) {
            throw new Error('invalid command line');
        }

        const address = Number.parseInt(process.argv[2], 16);
        const imagePath = process.argv[3];

        if (process.argv[5] !== undefined || process.argv[5] !== 'dbg') {
            throw new Error('invalid command line');
        }

        const debug = process.argv[4] === 'dbg';

        return [address, imagePath, debug];
    } catch (error) {
        console.error(error.message);
        console.log('Usage: node main.mjs c000 msbasic/tmp/vm6502.bin [dbg]');
        process.exit(1);
    }
};

const loadSymbols = async (imgPath) => {
    const parsedPath = path.parse(imgPath);
    const symbolPath = path.format({ ...parsedPath, base: undefined, ext: 'lbl' });

    let symbolData;
    try {
        symbolData = await fs.readFile(symbolPath, 'utf8');
    } catch {
        // No symbols found
        return;
    }

    return Object.fromEntries(symbolData.trim().split(/\r?\n/).map((line) => {
        const m = line.match(/al ([\dA-F]+) \.(.*)/);
        return [Number.parseInt(m[1], 16), m[2]];
    }));
};

const main = async () => {
    const [address, imagePath, debug] = parseCommandLine();

    const image = [...await fs.readFile(imagePath)];
    const symbols = await loadSymbols(imagePath);

    const mem = [];
    for (let idx = 0; idx < image.length; idx++) {
        mem[address + idx] = image[idx];
    }

    const vm = new Vm6502(mem, symbols);
    vm.trace = debug;

    vm.run();
};

await main();
