// make -C .. && make build-intcode && ICVM=~/intcode/xzintbit/vms/c/ic node test.js

import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import util from 'node:util';
import zlib from 'node:zlib';
import chalk from 'chalk';
import { MultiProgressBars } from 'multi-progress-bars';
import Piscina from 'piscina';
import worker from './worker.js';

const gunzipAsync = util.promisify(zlib.gunzip);

const piscina = new Piscina({ filename: path.resolve(import.meta.dirname, 'worker.js') });
const log = fs.createWriteStream('test.log', { flags: 'a', encoding: 'utf8' });

const TESTS_DIR = path.join('..', '..', '8088');

let mpb, options;

const printUsage = () => {
// eslint-disable indent
// 100:   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    console.log(`\
Usage: node test.js [options]

Options:
    [--file|-f <file-prefix>]   Only run test cases starting with <file-prefix>
    [--variant|-v <variant>]    Only run test cases from the <variant> subdirectory
    [--index|-i <index>]        Only run tests with idx field equal to <index>
    [--hash|-h <hash-prefix>]   Only run tests with hash field starting with <hash-prefix>
    [--continue|-c]             Start at specified file, then continue running following files
    [--break|-b]                Break after first failed test (implies --single-thread)

    [--undefined-behavior|u]    Run all tests, including those that test undefined behavior

    [--keep|-k]                 Don't delete temporary files after the tests finish
    [--single-thread|-1]        Run all tests in the main thread, without using worker threads

    [--plain|-p]                Plain output, no progress bars
    [--dump-errors|-e]          Print differences between expected and actual values
    [--dump-output|-o]          Print stdout and stderr of the intcode binary
    [--trace|-t]                Trace execution of individual test cases

Environment:
    ICVM                        Path to the intcode virtual machine
`);
// eslint-enable indent
};

const parseCommandLine = () => {
    try {
        const { values } = util.parseArgs({
            options: {
                file: { type: 'string', short: 'f', multiple: true },
                variant: { type: 'string', short: 'v', multiple: true, default: ['v1', 'v2'] },
                index: { type: 'string', short: 'i', multiple: true },
                hash: { type: 'string', short: 'h', multiple: true },
                'dump-errors': { type: 'boolean', short: 'e' },
                'dump-output': { type: 'boolean', short: 'o' },
                trace: { type: 'boolean', short: 't' },
                'single-thread': { type: 'boolean', short: '1' },
                keep: { type: 'boolean', short: 'k' },
                'undefined-behavior': { type: 'boolean', short: 'u' },
                continue: { type: 'boolean', short: 'c' },
                plain: { type: 'boolean', short: 'p' },
                break: { type: 'boolean', short: 'b' }
            }
        });

        if (values.index !== undefined && values.hash !== undefined) {
            throw new Error('Both index and hash must not be specified at the same time');
        }

        if (values.index !== undefined) {
            if (values.index.some(i => !/^\d+$/.test(i))) {
                throw new Error('Index must be a positive integer');
            }
            values.index = values.index.map(i => Number.parseInt(i));
        }

        if (values.break) {
            values['single-thread'] = true;
        }

        return values;
    } catch (error) {
        console.error(error.message);
        printUsage();
        process.exit(1);
    }
};

const formatPassedFailed = (passed, failed, total, filtered) => {
    let output = '';

    const passedMessage = `passed ${String(passed).padStart(5)}`;
    output += chalk.green(passed > 0 ? passedMessage : ' '.repeat(passedMessage.length));

    output += '  ';

    const failedMessage = `failed ${String(failed).padStart(5)}`;
    output += chalk.red(failed > 0 ? failedMessage : ' '.repeat(failedMessage.length));

    output += '  ';

    const filteredMessage = `filtered ${String(filtered).padStart(5)}`;
    output += chalk.gray(filtered > 0 ? filteredMessage : ' '.repeat(filteredMessage.length));

    output += '  ';

    const pending = total - passed - failed;
    const pendingMessage = `pending ${String(pending).padStart(5)}`;
    output += chalk.blue(pending > 0 ? pendingMessage : ' '.repeat(pendingMessage.length));

    return output;
};

const loadTests = async (variant, file, idx, hash) => {
    const zbuffer = await fsp.readFile(path.join(TESTS_DIR, variant, file));
    const buffer = await gunzipAsync(zbuffer);

    const json = buffer.toString('utf8');
    const data = JSON.parse(json);

    return data.filter((test) => {
        return (idx === undefined || idx.some(i => test.idx === i))
            && (hash === undefined || hash.some(h => test.hash.startsWith(h)));
    });
};

const calcPhysicalAddress = (seg, off) => {
    while (off < 0x0000) off += 0x10000;
    while (off > 0xffff) off -= 0x10000;
    return (seg * 0x10 + off) % 0x100000;
};

const adjustTests = (variant, file, tests) => {
    if (variant === 'v1' && ['F6.6.json.gz', 'F6.7.json.gz', 'F7.6.json.gz', 'F7.7.json.gz'].includes(file)) {
        for (const test of tests) {
            // For DIV and IDIV tests that cause a #DE, the flags are pushed to stack and checked.
            // However some of the flags are undefined and should not cause the tests to fail.
            // Fix this by removing the final ram records for the flags pushed to stack.

            if (test.final.regs.cs === 0x0000 && test.final.regs.ip === 0x0400 && test.final.ram.length === 6) {
                // The test expects to end in the #DE interrupt handler. The six memory records are the flags,
                // CS and IP pushed to stack. There are some test cases where stack goes through a segment boundary,
                // so flags are not the last two records. We will calculate the initial stack position and delete
                // specifically the two records that got pushed at that position.
                const fal = calcPhysicalAddress(test.initial.regs.ss, test.initial.regs.sp - 2);
                const fah = calcPhysicalAddress(test.initial.regs.ss, test.initial.regs.sp - 1);
                test.final.ram = test.final.ram.filter(([addr]) => addr !== fal && addr !== fah);
            }

            // There are also some negative IP values in these tests, that should actually be their two's complement.
            if (test.final.regs.ip < 0) {
                test.final.regs.ip += 0x100000;
            }
        }
    }
};

const formatFlag = (flags, flagsMask, bit, char) => {
    if ((flagsMask & bit) === 0) {
        return '░';
    } else if (flags & bit) {
        return char.toUpperCase();
    } else {
        return char.toLowerCase();
    }
};

const formatFlags = (flags, flagsMask) => {
    const o = formatFlag(flags, flagsMask, 0b0000100000000000, 'o');
    const d = formatFlag(flags, flagsMask, 0b0000010000000000, 'd');
    const i = formatFlag(flags, flagsMask, 0b0000001000000000, 'i');
    const t = formatFlag(flags, flagsMask, 0b0000000100000000, 't');
    const s = formatFlag(flags, flagsMask, 0b0000000010000000, 's');
    const z = formatFlag(flags, flagsMask, 0b0000000001000000, 'z');
    const a = formatFlag(flags, flagsMask, 0b0000000000010000, 'a');
    const p = formatFlag(flags, flagsMask, 0b0000000000000100, 'p');
    const c = formatFlag(flags, flagsMask, 0b0000000000000001, 'c');

    return `----${o}${d}${i}${t} ${s}${z}-${a}-${p}-${c}`;
};

const formatResult = (input, flagsMask) => {
    flagsMask = flagsMask ?? 0xffff;
    const output = {};

    if (input.regs) {
        output.regs = {};
        for (const key in input.regs) {
            if (key !== 'flags') {
                const hexValue = input.regs[key].toString(16).padStart(4, '0');
                output.regs[key] = `${hexValue} (${input.regs[key]})`;
            }
        }
        if (input.regs.flags) {
            const maskedFlags = input.regs.flags & flagsMask;
            const hexFlags = `${maskedFlags.toString(16).padStart(4, '0')}`;
            const binFlags = formatFlags(maskedFlags, flagsMask);

            output.regs.flags = `${hexFlags} ${binFlags} (${maskedFlags})`;
        }
    }

    if (input.ram) {
        output.ram = [];
        for (const [addr, val] of input.ram) {
            const hexAddr = addr.toString(16).padStart(4, '0');
            const hexVal = val.toString(16).padStart(2, '0');
            output.ram.push([`${hexAddr} (${addr})`, `${hexVal} (${val})`]);
        }
    }

    return output;
};

const dumpError = (test, result) => {
    console.log(`${test.name}`);
    console.log(chalk.gray(`idx: ${test.idx} hash: ${test.hash}`));
    console.log('');
    console.log(chalk.blue('error:'), result.error);
    console.log('');
    console.log(chalk.blue('input:   '), formatResult(test.initial));
    console.log(chalk.blue('actual:  '), formatResult(result.actual, test.flagsMask));
    console.log(chalk.blue('expected:'), formatResult(result.expected, test.flagsMask));
    console.log('');

    log.write(JSON.stringify(result, undefined, 2) + '\n');
};

const logTestSummary = (variant, file, passed, failed, filtered) => {
    const data = {
        variant, file, filtered,
        passed: passed.length,
        failed: failed.length
    };

    log.write(JSON.stringify(data) + '\n');
};

const runTests = async (variant, file, tests, filtered) => {
    mpb?.addTask(`${variant}/${file}`, { type: 'percentage' });

    let passed = [], failed = [];
    const runOneTest = async (test, i) => {
        let error, actual;
        if (options['single-thread']) {
            [error, actual] = await worker({ test, options });
        } else {
            [error, actual] = await piscina.run({ test, options });
        }

        const result = { variant, file, hash: test.hash };
        if (error === undefined) {
            passed.push(result);
        } else {
            result.hash = test.hash;
            result.error = error.toString();
            result.actual = actual;
            result.expected = { regs: test.final.regs, ram: test.final.ram };

            failed.push(result);

            if (options['dump-errors']) {
                dumpError(test, result);
            }
        }

        const message = formatPassedFailed(passed.length, failed.length, tests.length, filtered);
        mpb?.updateTask(`${variant}/${file}`, { percentage: i / tests.length, message });

        return error === undefined;
    };

    if (options['single-thread']) {
        for (let i = 0; i < tests.length; i++) {
            const success = await runOneTest(tests[i], i);
            if (options.break && !success) {
                break;
            }
        }
    } else {
        const promises = tests.map(async (test, i) => runOneTest(test, i));
        const results = await Promise.allSettled(promises);

        const errors = results.filter(r => r.status === 'rejected').map(r => r.reason);
        if (errors.length > 0) {
            throw errors;
        }
    }

    logTestSummary(variant, file, passed, failed, filtered);

    const message = formatPassedFailed(passed.length, failed.length, tests.length, filtered);
    mpb?.done(`${variant}/${file}`, { message });

    return { passed: passed.length, failed: failed.length };
};

const onWorkerMessage = (data) => {
    switch (data.type) {
    case 'log':
        console.log(data.message);
        log.write(JSON.stringify({ message: data.message }) + '\n');
        return;
    }
};

const loadMetadata = async () => {
    if (options['undefined-behavior']) {
        return undefined;
    }

    return options.variant.map(async variant =>
        [variant, JSON.parse(await fsp.readFile(path.join(TESTS_DIR, variant, 'metadata.json'), 'utf8'))]);
};

const byteToOpcodesKey = (byte) => byte.toString(16).toUpperCase().padStart(2, '0');

const applyMetadata = (test, metadata) => {
    if (metadata === undefined) {
        // No filtering, no masking, just use the test data directly
        return test;
    }

    // Skip all prefixes and find the opcode
    const ocIndex = test.bytes.findIndex(b => metadata.opcodes[byteToOpcodesKey(b)].status !== 'prefix');
    if (ocIndex === -1) {
        return [];
    }

    const opcodeKey = byteToOpcodesKey(test.bytes[ocIndex]);
    let info = metadata.opcodes[opcodeKey];

    // If there is a reg field, the actual information is one level deeper
    if (info.reg) {
        const reg = (test.bytes[ocIndex + 1] & 0b00111000) >> 3;
        info = info.reg[reg.toString()];
    }

    // Only test opcodes with 'normal' status
    if (info.status !== 'normal') {
        return [];
    }

    // Add flags mask, if any, to the test
    if (info['flags-mask'] !== undefined) {
        test.flagsMask = info['flags-mask'];
    }

    return test;
};

const listFiles = async () => {
    const files = [];

    let haveStartingFile = false;

    for (const variant of options.variant) {
        const allVariantFiles = await fsp.readdir(path.join(TESTS_DIR, variant));

        const filteredVariantFiles = allVariantFiles.filter((file) => {
            if (!file.match(/.*\.gz/)) {
                return false;
            }

            if (options.file === undefined) {
                return true;
            }

            if (options.file.some(f => file.startsWith(f))) {
                haveStartingFile = true;
                return true;
            }

            if (options.continue && haveStartingFile) {
                return true;
            }

            return false;
        });

        files.push(...filteredVariantFiles.map(file => ({ variant, file })));
    }

    return files;
};

const main = async () => {
    options = parseCommandLine();

    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write(JSON.stringify({ started: true }) + '\n');

    piscina.on('message', onWorkerMessage);

    if (!options.plain) {
        mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });
    }

    let totalPassed = 0, totalFailed = 0, totalFiltered = 0;

    const metadata = await loadMetadata();
    const files = await listFiles();

    for (const { variant, file } of files) {
        const allTests = await loadTests(variant, file, options.index, options.hash);
        const validTests = allTests.flatMap(test => applyMetadata(test, metadata[variant]));
        adjustTests(variant, file, validTests);
        const filtered = allTests.length - validTests.length;

        if (validTests.length > 0) {
            const { passed, failed } = await runTests(variant, file, validTests, filtered);

            if (failed !== 0 && options.break) {
                break;
            }

            totalPassed += passed;
            totalFailed += failed;
            totalFiltered += filtered;
        }
    }

    mpb?.close();

    const passedMessage = chalk.green(`passed ${totalPassed}`);
    const failedMessage = (totalFailed > 0 ? chalk.red : chalk.gray)(`failed ${totalFailed}`);
    const filteredMessage = chalk.gray(`filtered ${totalFiltered}`);

    console.log('');
    console.log(`Summary: ${passedMessage}  ${failedMessage}  ${filteredMessage}`);

    log.end();

    if (totalFailed > 0) {
        process.exit(1);
    }
};

await main();
