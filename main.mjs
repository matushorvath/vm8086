import { Vm6502 } from './vm6502.mjs';
import fs from 'fs/promises';

const main = async () => {
    //const mem = [...await fs.readFile(process.argv[2])];
    const img = [...await fs.readFile(process.argv[2])];

    const mem = [];
    for (let idx = 0; idx < img.length; idx++) {
        mem[0xc000 + idx] = img[idx]; // TODO remove hardcoded msbasic address
    }

    const vm = new Vm6502(mem);
    vm.pc = 0xc000; // TODO remove hardcoded msbasic address

    vm.run();
};

await main();
