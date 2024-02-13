import { Vm6502 } from '../vm6502.mjs';
import yaml from 'yaml';
import chalk from 'chalk';

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
                throw new Error(`setup register '${reg}' is not an 8-bit number`);
            }
            vm[reg] = setup[reg];
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (setup?.[flag] !== undefined) {
            if (!isBoolean(setup[flag])) {
                throw new Error(`setup flag '${flag}' is not boolean`);
            }
            vm[flag] = setup[flag];
        }
    }

    for (const key in setup?.mem ?? []) {
        if (!isAddress(Number(key))) {
            throw new Error(`setup address '${key}' is not a 16-bit number`);
        }

        const data = isString(setup.mem[key]) ? await assemble(setup.mem[key]) : setup.mem[key];

        for (let idx = 0; idx < data.length; idx++) {
            const addr = Number(key) + idx;
            vm.mem[addr] = data[idx];
        }
    }
};

const checkVm = (vm, check) => {
    const errors = [];

    for (const reg of ['pc', 'a', 'x', 'y', 'sp']) {
        if (check?.[reg] !== undefined) {
            if (!isNumber8B(check[reg])) {
                throw new Error(`check register '${reg}' is not an 8-bit number`);
            }
            if (vm[reg] !== check[reg]) {
                errors.push(`register '${reg}' does not match; expected '${check[reg]}', actual '${vm[reg]}'`);
            }
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (check?.[flag] !== undefined) {
            if (!isBoolean(check[flag])) {
                throw new Error(`check flag '${flag}' is not boolean`);
            }
            if (vm[flag] !== check[flag]) {
                errors.push(`flag '${flag}' does not match; expected '${check[flag]}', actual '${vm[flag]}'`);
            }
        }
    }

    for (const key in check?.mem ?? []) {
        if (!isAddress(Number(key))) {
            throw new Error(`check address '${key}' is not a 16-bit number`);
        }

        const data = check.mem[key];

        for (let idx = 0; idx < data.length; idx++) {
            const addr = Number(key) + idx;

            if (vm.mem[addr] !== data[idx]) {
                errors.push(`address '${addr}=${key}+${idx}' does not match; expected '${data[idx]}', actual '${vm.mem[addr]}'`);
            }
        }
    }

    return errors;
};

const run = async (test) => {
    process.stdout.write(`${test.desc}`);

    const vm = new Vm6502();
    await setupVm(vm, test.setup);

    vm.run();
    const errors = checkVm(vm, test.check);

    if (errors.length > 0) {
        process.stdout.write(`    ${chalk.red('FAILED')}\n`);
        process.stdout.write(`    ${chalk.gray(errors.join('\n    '))}\n`);
        return false;
    } else {
        process.stdout.write(`    ${chalk.green('PASSED')}\n`);
        return true;
    }
};

const main = async () => {
    const tests = yaml.parse(await fs.readFile(path.join(__dirname, 'tests.yaml'), 'utf8'));

    let passed = true;
    for (const test of tests) {
        if (!await run(test)) {
            passed = false;
        }
    }

    if (!passed) {
        console.log(`\n${chalk.red('Some tests FAILED')}`);
        process.exit(1);
    }

    console.log(`\n${chalk.green('All tests PASSED')}`);
};

await main();
