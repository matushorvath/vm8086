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

const TESTS_DIR = path.join('..', '..', '8088', 'v1');

let mpb, options;

const printUsage = () => {
// eslint-disable indent
// 100:   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    console.log(`\
Usage: node test.js [options]

Options:
    [--file|-f <file-prefix>]   Only run test cases starting with <file-prefix>
    [--index|-i <index>]        Only run tests with idx field equal to <index>
    [--hash|-h <hash-prefix>]   Only run tests with hash field starting with <hash-prefix>
    [--continue|-c]             Start at specified file, then continue running following files

    [--undefined-behavior|u]    Run all tests, including those that test undefined behavior

    [--keep|-k]                 Don't delete temporary files after the tests finish
    [--single-thread|-1]        Run all tests in the main thread, without using worker threads

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
                index: { type: 'string', short: 'i', multiple: true },
                hash: { type: 'string', short: 'h', multiple: true },
                'dump-errors': { type: 'boolean', short: 'e' },
                'dump-output': { type: 'boolean', short: 'o' },
                trace: { type: 'boolean', short: 't' },
                'single-thread': { type: 'boolean', short: '1' },
                keep: { type: 'boolean', short: 'k' },
                'undefined-behavior': { type: 'boolean', short: 'u' },
                continue: { type: 'boolean', short: 'c' }
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

const loadTests = async (file, idx, hash) => {
    const zbuffer = await fsp.readFile(path.join(TESTS_DIR, file));
    const buffer = await gunzipAsync(zbuffer);

    const json = buffer.toString('utf8');
    const data = JSON.parse(json);

    return data.filter((test) => {
        return (idx === undefined || idx.some(i => test.idx === i))
            && (hash === undefined || hash.some(h => test.hash.startsWith(h)));
    });
};

const formatFlags = (flags) => {
    const o = (flags & 0b0000100000000000) ? 'O' : 'o';
    const d = (flags & 0b0000010000000000) ? 'D' : 'd';
    const i = (flags & 0b0000001000000000) ? 'I' : 'i';
    const t = (flags & 0b0000000100000000) ? 'T' : 't';
    const s = (flags & 0b0000000010000000) ? 'S' : 's';
    const z = (flags & 0b0000000001000000) ? 'Z' : 'z';
    const a = (flags & 0b0000000000010000) ? 'A' : 'a';
    const p = (flags & 0b0000000000000100) ? 'P' : 'p';
    const c = (flags & 0b0000000000000001) ? 'C' : 'c';

    return `----${o}${d}${i}${t} ${s}${z}-${a}-${p}-${c}`;
};

const formatResult = (input) => {
    const output = {};

    if (input.regs) {
        output.regs = {};
        for (const key in input.regs) {
            output.regs[key] = `${input.regs[key].toString(16).padStart(4, '0')}`;
        }
        if (input.regs.flags) {
            output.regs.flags += ` ${formatFlags(input.regs.flags)}`;
        }
    }

    if (input.mem) {
        output.mem = [];
        for (const [addr, val] of input.mem) {
            output.mem.push([addr.toString(16).padStart(4, '0'), val.toString(16).padStart(2, '0')]);
        }
    }

    return output;
};

const dumpError = (test, result) => {
    console.log(`${test.name}`);
    console.log(chalk.gray(`idx: ${test.idx} hash: ${test.hash}`));
    console.log('');
    console.log('error:', result.error);
    console.log('');
    console.log('actual:  ', result.actual);
    console.log('         ', formatResult(result.actual));
    console.log('expected:', result.expected);
    console.log('         ', formatResult(result.expected));
    console.log('');

    log.write(JSON.stringify(result, undefined, 2) + '\n');
};

const logTestSummary = (file, passed, failed, filtered) => {
    const data = {
        file, filtered,
        passed: passed.length,
        failed: failed.length
    };

    // TODO print list of failed hashes once there's fewer of them

    log.write(JSON.stringify(data) + '\n');
};

const runTests = async (file, tests, filtered) => {
    mpb.addTask(file, { type: 'percentage' });

    let passed = [], failed = [];
    const runOneTest = async (test, i) => {
        let error, actual;
        if (options['single-thread']) {
            [error, actual] = await worker({ test, options });
        } else {
            [error, actual] = await piscina.run({ test, options });
        }

        const result = { file, hash: test.hash };
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
        mpb.updateTask(file, { percentage: i / tests.length, message });
    };

    if (options['single-thread']) {
        for (let i = 0; i < tests.length; i++) {
            await runOneTest(tests[i], i);
        }
    } else {
        const promises = tests.map(async (test, i) => runOneTest(test, i));
        const results = await Promise.allSettled(promises);

        const errors = results.filter(r => r.status === 'rejected').map(r => r.reason);
        if (errors.length > 0) {
            throw errors;
        }
    }

    logTestSummary(file, passed, failed, filtered);

    const message = formatPassedFailed(passed.length, failed.length, tests.length, filtered);
    mpb.done(file, { message });

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

    return JSON.parse(await fsp.readFile(path.join(TESTS_DIR, 'metadata.json'), 'utf8'));
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
    let haveStartingFile = false;

    return (await fsp.readdir(TESTS_DIR)).filter((file) => {
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
};

const main = async () => {
    options = parseCommandLine();

    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write(JSON.stringify({ started: true }) + '\n');

    piscina.on('message', onWorkerMessage);
    mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

    let fileCount = 0, totalPassed = 0, totalFailed = 0, totalFiltered = 0;

    const metadata = await loadMetadata();
    const files = await listFiles();

    for (const file of files) {
        const allTests = await loadTests(file, options.index, options.hash);
        const validTests = allTests.flatMap(test => applyMetadata(test, metadata));
        const filtered = allTests.length - validTests.length;

        if (validTests.length > 0) {
            const { passed, failed } = await runTests(file, validTests, filtered);

            fileCount++;
            totalPassed += passed;
            totalFailed += failed;
            totalFiltered += filtered;
        }
    }

    if (fileCount > 1) {
        const passedMessage = chalk.green(`passed ${totalPassed}`);
        const failedMessage = chalk.red(`failed ${totalFailed}`);
        const filteredMessage = chalk.gray(`filtered ${totalFiltered}`);

        console.log('');
        console.log(`Summary: ${passedMessage}  ${failedMessage}  ${filteredMessage}`);
    }

    mpb.close();
    log.end();
};

await main();
