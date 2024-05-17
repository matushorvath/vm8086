// make -C .. && make build-intcode && ICVM=~/intcode/xzintbit/vms/c/ic node test.js

// TODO metadata.json

import assert from 'node:assert/strict';
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
    [--file|-o <file-prefix>]   Only run test cases starting with <file-prefix>
    [--index|-i <index>]        Only run tests with idx field equal to <index>
    [--hash|-h <hash-prefix>]   Only run tests with hash field starting with <hash-prefix>s

    [--undefined-behavior|u]    Run all tests, including those that test undefined behavior

    [--keep|-k]                 Don't delete temporary files after the tests finish
    [--single-thread|-1]        Run all tests in the main thread, without using worker threads

    [--dump-errors|-e]          Print differences between expected and actual values
    [--dump-stdout|-s]          Print standard output of the intcode binary
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
                'dump-stdout': { type: 'boolean', short: 's' },
                trace: { type: 'boolean', short: 't' },
                'single-thread': { type: 'boolean', short: '1' },
                keep: { type: 'boolean', short: 'k' },
                'undefined-behavior': { type: 'boolean', short: 'u' }
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

const adjustTests = (file, tests) => {
    // Test adjustments to fix issues I found, either in the test or in the VM

    // 3A test 3093506565e4803bf150e0e36d3e846edb6f1c3a
    // initial memory does not have a NOP immediately after the first instruction
    if (file.startsWith('3A.json')) {
        const test = tests.find(t => t.hash === '3093506565e4803bf150e0e36d3e846edb6f1c3a');
        assert.notEqual(test, undefined);
        assert.deepEqual(test.initial.ram[3], [278859, 10]);
        test.initial.ram[3][1] = 0x90;
    }
};

const runTests = async (file, tests, filtered) => {
    mpb.addTask(file, { type: 'percentage' });

    let passed = 0, failed = 0;
    const runOneTest = async (test, i) => {
        let error;
        if (options['single-thread']) {
            error = await worker({ test, options });
        } else {
            error = await piscina.run({ test, options });
        }

        if (error === undefined) {
            passed++;
        } else {
            failed++;
        }

        if (options['dump-errors'] && error !== undefined) {
            console.log(`${test.name}: ${chalk.red('FAILED')}`);
            console.log(chalk.gray(`idx: ${test.idx} hash: ${test.hash}`));
            console.log('');
            console.log(error.toString());
            console.log('');

            log.write(`file: "${file}", name: ${test.name}, idx: ${test.idx}, hash: ${test.hash}`);
            log.write(error.toString());
        }

        const message = formatPassedFailed(passed, failed, tests.length, filtered);
        mpb.updateTask(file, { percentage: i / tests.length, message });
    };

    if (options['single-thread']) {
        for (let i = 0; i < tests.length; i++) {
            await runOneTest(tests[i], i);
        }
    } else {
        const promises = tests.map(async (test, i) => runOneTest(test, i));
        await Promise.allSettled(promises);
    }

    log.write(`file: "${file}", passed: ${passed}, failed: ${failed}, filtered ${filtered}\n`);

    const message = formatPassedFailed(passed, failed, tests.length, filtered);
    mpb.done(file, { message });
};

const onWorkerMessage = (data) => {
    switch (data.type) {
    case 'log': console.log(data.message); log.write(`${data.message}\n`); return;
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

const main = async () => {
    options = parseCommandLine();

    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write('CPU tests started\n');

    piscina.on('message', onWorkerMessage);
    mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

    const metadata = await loadMetadata();

    const files = (await fsp.readdir(TESTS_DIR))
        .filter(file => file.match(/.*\.gz/))
        .filter(file => options.file === undefined || options.file.some(f => file.startsWith(f)));

    for (const file of files) {
        const allTests = await loadTests(file, options.index, options.hash);
        adjustTests(file, allTests);
        const validTests = allTests.flatMap(test => applyMetadata(test, metadata));
        const filtered = allTests.length - validTests.length;

        if (validTests.length > 0) {
            await runTests(file, validTests, filtered);
        }
    }

    mpb.close();
    log.end();
};

await main();
