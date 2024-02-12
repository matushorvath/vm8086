import { Vm6502 } from '../vm6502.mjs';
import yaml from 'yaml';

import fs from 'node:fs/promises';
import path from 'node:path';
import url from 'node:url';
import child_process from 'node:child_process';

const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

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

const setupVm = (vm, setup) => {
    for (const reg of ['pc', 'a', 'x', 'y', 'sp']) {
        if (setup?.[reg] !== undefined) {
            vm[reg] = setup[reg];
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (setup?.[flag] !== undefined) {
            vm[flag] = setup[flag];
        }
    }

    for (const addr in setup?.mem ?? []) {
        for (let idx = 0; idx < setup.mem[addr].length; idx++) {
            vm.mem[addr + idx] = setup.mem[addr][idx];
        }
    }
};

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

const run = async (test) => {
    const vm = new Vm6502();

    setupVm(vm, test.setup);
    const binary = await assemble(test.code);

    console.log(JSON.stringify(binary));
};

const main = async () => {
    const tests = yaml.parse(await fs.readFile(path.join(__dirname, 'tests.yaml'), 'utf8'));

    for (const test of tests) {
        await run(test);
    }
};

await main();
