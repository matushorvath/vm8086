// If you want to run this against stdin:
// echo A | npm run ut -- -stdio
// yq 'map(select(.input)) | map(.input) | .[]' < tests/tests.yaml | npm run ut -- -stdio

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

const f8 = n => n.toString(16).padStart(2, '0');

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

const checkConfig = (test) => {
    for (const reg of ['pc', 'a', 'x', 'y', 'sp']) {
        if (test.setup?.[reg] !== undefined && !isNumber8B(test.setup[reg])) {
            throw new Error(`setup register '${reg}' is not an 8-bit number`);
        }

        if (test.check?.[reg] !== undefined && !isNumber8B(test.check[reg])) {
            throw new Error(`check register '${reg}' is not an 8-bit number`);
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (test.check?.[flag] !== undefined && !isBoolean(test.check[flag])) {
            throw new Error(`check flag '${flag}' is not boolean`);
        }
        if (test.setup?.[flag] !== undefined && !isBoolean(test.setup[flag])) {
            throw new Error(`setup flag '${flag}' is not boolean`);
        }
    }

    for (const key in test.setup?.mem ?? []) {
        if (!isAddress(Number(key))) {
            throw new Error(`setup address '${key}' is not a 16-bit number`);
        }
    }

    for (const key in test.check?.mem ?? []) {
        if (!isAddress(Number(key))) {
            throw new Error(`check address '${key}' is not a 16-bit number`);
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

const setupVm = async (vm, test) => {
    // For simplicity, the VM by default starts at 0x0000 when running tests
    vm.pc = 0;

    for (const reg of ['pc', 'a', 'x', 'y', 'sp']) {
        if (test.setup?.[reg] !== undefined) {
            vm[reg] = test.setup[reg];
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        if (test.setup?.[flag] !== undefined) {
            vm[flag] = test.setup[flag];
        }
    }

    const mem = [];

    for (const key in test.setup?.mem ?? []) {
        const data = isString(test.setup.mem[key]) ? await assemble(test.setup.mem[key]) : test.setup.mem[key];
        mem.push(data);

        for (let idx = 0; idx < data.length; idx++) {
            const addr = Number(key) + idx;
            vm.mem[addr] = data[idx];
        }
    }

    return mem;
};

const setupIO = (vm, instr, useStdio) => {
    if (useStdio) {
        return undefined;
    }

    const iodata = {
        more: 0,
        inchars: instr?.split('') ?? [],
        outchars: []
    };

    const input = () => {
        const ch = iodata.inchars.shift();
        if (ch === undefined) {
            iodata.more++;
            return 0;
        } else {
            return ch.charCodeAt(0);
        }
    };

    const output = (val) => iodata.outchars.push(String.fromCharCode(val));

    vm.io = { input, output };

    return iodata;
};

const checkVm = (vm, test) => {
    const errors = [];

    for (const reg of ['pc']) {
        if (test.check?.[reg] !== undefined) {
            if (vm[reg] !== test.check[reg]) {
                errors.push(`register '${reg}' does not match; expected '${f8(test.check[reg])}', actual '${f8(vm[reg])}'`);
            }
        }
    }

    for (const reg of ['a', 'x', 'y', 'sp']) {
        const value = test.check?.[reg] ?? test.setup?.[reg] ?? (reg === 'sp' ? 0xff : 0x00);
        const source = test.check?.[reg] ? '' : test.setup?.[reg] ? ' (setup)' : ' (default)';

        if (vm[reg] !== value) {
            errors.push(`register '${reg}' does not match; expected '${f8(value)}'${source}, actual '${f8(vm[reg])}'`);
        }
    }

    for (const flag of ['negative', 'overflow', 'decimal', 'interrupt', 'zero', 'carry']) {
        const value = test.check?.[flag] ?? test.setup?.[flag] ?? false;
        const source = test.check?.[flag] ? '' : test.setup?.[flag] ? ' (setup)' : ' (default)';

        if (vm[flag] !== value) {
            errors.push(`flag '${flag}' does not match; expected '${value}'${source}, actual '${vm[flag]}'`);
        }
    }

    for (const key in test.check?.mem ?? []) {
        const data = test.check.mem[key];

        for (let idx = 0; idx < data.length; idx++) {
            const addr = Number(key) + idx;

            if (vm.mem[addr] !== data[idx]) {
                errors.push(`address '${addr}=${key}+${idx}' does not match; expected '${f8(data[idx])}', actual '${f8(vm.mem[addr])}'`);
            }
        }
    }

    return errors;
};

const checkIO = (iodata, test, useStdio) => {
    if (useStdio) {
        return [];
    }

    const errors = [];

    if (iodata.more > 0) {
        errors.push(`more input characters needed; ${iodata.more} more consumed`);
    }

    if (iodata.inchars.length > 0) {
        const consumed = test.input.slice(0, -iodata.inchars.length);
        errors.push(`some input characters not consumed; expected '${test.input}', actual '${consumed}'`);
    }

    const outstr = iodata.outchars.join('');
    if (test.output !== undefined && outstr !== test.output) {
        errors.push(`output characters do not match; expected '${test.output}', actual '${outstr}'`);
    }

    return errors;
};

const run = async (test, useStdio) => {
    process.stdout.write(`${test.desc}`);

    checkConfig(test);

    const vm = new Vm6502();
    const mem = await setupVm(vm, test);
    const iodata = setupIO(vm, test.input, useStdio);

    vm.run();

    const errors = [...checkVm(vm, test), ...checkIO(iodata, test, useStdio)];
    const memStr = mem.map(r => `[${r.map(b => b.toString(16).padStart(2, '0')).join(' ')}]`);

    if (errors.length > 0) {
        process.stdout.write(`    ${chalk.red('FAILED')}\n`);
        process.stdout.write(`    ${chalk.yellow(memStr)}\n`);
        process.stdout.write(`    ${chalk.gray(errors.join('\n    '))}\n`);
        return false;
    } else {
        process.stdout.write(`    ${chalk.green('PASSED')}\n`);
        process.stdout.write(`    ${chalk.yellow(memStr)}\n`);
        return true;
    }
};

const parseCommandLine = () => {
    let useStdio;
    let filter;

    const args = process.argv.slice(2);

    while (args.length > 0) {
        const arg = args.shift();
        if (useStdio === undefined && arg === '-stdio') {
            useStdio = true;
        } else if (filter === undefined) {
            filter = new RegExp(arg);
        } else {
            console.error('Usage: node test.mjs [-stdio] [desc-filter-regex]');
            process.exit(1);
        }
    }

    return { useStdio: useStdio ?? false, filter };
};

const main = async () => {
    const list = yaml.parse(await fs.readFile(path.join(__dirname, 'tests.yaml'), 'utf8'));

    const { useStdio, filter } = parseCommandLine();

    if (useStdio) {
        console.log(`Running against ${chalk.blueBright('real STDIO')}; input and output checks ${chalk.blueBright('disabled')}\n`);
    }

    const statuses = [];

    for (const file of list.filter(f => filter === undefined || filter.test(f))) {
        const collection = yaml.parse(await fs.readFile(path.join(__dirname, file), 'utf8'));
        console.log(`${chalk.blueBright(`${collection.desc} (${file})\n`)}`);

        let passed = 0;

        for (const test of collection.tests) {
            if (await run(test, useStdio)) {
                passed++;
            }
        }

        statuses.push({ file, desc: collection.desc, total: collection.tests.length, passed });
        console.log('');
    }

    for (const status of statuses) {
        const success = status.passed === status.total;
        const colorer = success ? chalk.green : chalk.red;
        const nums = `(${status.passed}/${status.total})`;
        console.log(`${status.desc} (${status.file})    ${colorer(success ? 'PASSED' : 'FAILED')} ${nums}`);
    }

    if (statuses.some(s => s.total !== s.passed)) {
        console.log(`\n${chalk.red('Some tests FAILED')}`);
        process.exit(1);
    }

    console.log(`\n${chalk.green('All tests PASSED')}`);
};

await main();
