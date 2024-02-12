import { Vm6502 } from './vm6502.mjs';
import fs from 'fs/promises';

const main = async () => {
    const mem = [...await fs.readFile(process.argv[2])];

    const vm = new Vm6502(mem);
    vm.run();
};

await main();
