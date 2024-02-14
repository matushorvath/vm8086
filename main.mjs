import { Vm6502 } from './vm6502.mjs';
import fs from 'node:fs/promises';
import path from 'node:path';

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
    //const mem = [...await fs.readFile(process.argv[2])];
    const img = [...await fs.readFile(process.argv[2])];
    const symbols = await loadSymbols(process.argv[2]);

    const mem = [];
    for (let idx = 0; idx < img.length; idx++) {
        mem[0xc000 + idx] = img[idx]; // TODO remove hardcoded msbasic address
    }

    const vm = new Vm6502(mem, symbols);
    //vm.trace = true;
    vm.pc = 0xc000; // TODO remove hardcoded msbasic address

    vm.run();
};

await main();
