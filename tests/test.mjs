import { Vm6502 } from '../vm6502.mjs';
import yaml from 'yaml';

import fs from 'node:fs/promises';
import path from 'node:path';
import url from 'node:url';
import child_process from 'node:child_process';

const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

const isString = value => typeof value === 'string' || value instanceof String;
const isBoolean = value => typeof value === 'boolean';
const isNumber8B = value => Number.isInteger(value) && value >= 0 && value < 256;
const isAddress = value => Number.isInteger(value) && value >= 0 && value < 65536;

// Promise.withResolvers is not yet available in node.js
if (Promise.withResolvers === undefined) {
    Promise.withResolvers = () => {
        let resolve, reject;
        const promise = new Promise((res, rej) => {
            resolve = res;
            reject = rej;
        });
        return { promise, resolve, reject };
    };
}

const assemble = async (code) => {
    const { promise, resolve, reject } = Promise.withResolvers();

    const as = child_process.spawn(path.join(__dirname, './assemble.sh'), [], { stdio: ['pipe', 'pipe', 'inherit'] });
    const buffers = [];

    as.stdout.on('data', data => buffers.push(data));

    as.on('close', (status) => {
        if (status !== 0) {
            reject(new Error(`assemble.sh process exited with code ${status}`));
        } else {
            resolve([...Buffer.concat(buffers)]);
        }
    });

    as.stdin.write(code);
    as.stdin.end();

    return promise;
};

const setupVm = async (vm, setup) => {
    for (const reg of ['pc', 'a', 'x', 'y', 'sp']) {
        if (setup?.[reg] !== undefined) {
            if (!isNumber8B(setup[reg])) {
                throw new Error(`register ${reg} is not an 8-bit number`);
            }
            vm[reg] = setup[reg];
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (setup?.[flag] !== undefined) {
            if (!isBoolean(setup[flag])) {
                throw new Error(`flag ${flag} is not boolean`);
            }
            vm[flag] = setup[flag];
        }
    }

    for (const addr in setup?.mem ?? []) {
        if (!isAddress(Number(addr))) {
            throw new Error(`address ${addr} is not a 16-bit number`);
        }

        const data = isString(setup.mem[addr]) ? await assemble(setup.mem[addr]) : setup.mem[addr];

        for (let idx = 0; idx < data.length; idx++) {
            vm.mem[Number(addr) + idx] = data[idx];
        }
    }
};

const run = async (test) => {
    const vm = new Vm6502();

    console.log(test.desc);
    await setupVm(vm, test.setup);

    console.log('setup', JSON.stringify(vm));

    vm.run();

    console.log('check', JSON.stringify(vm));
};

const main = async () => {
    const tests = yaml.parse(await fs.readFile(path.join(__dirname, 'tests.yaml'), 'utf8'));

    for (const test of tests) {
        await run(test);
    }
};

await main();
