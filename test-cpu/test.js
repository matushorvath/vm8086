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
const mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

const log = fs.createWriteStream('test.log', { flags: 'a', encoding: 'utf8' });

const TESTS_DIR = path.join('..', '..', '8088', 'v1');

const parseCommandLine = () => {
    try {
        const { values } = util.parseArgs({
            options: {
                opcode: { type: 'string', short: 'o', multiple: true },
                index: { type: 'string', short: 'i', multiple: true },
                hash: { type: 'string', short: 'h', multiple: true },
                'dump-errors': { type: 'boolean', short: 'd' },
                trace: { type: 'boolean', short: 't' },
                'single-thread': { type: 'boolean', short: '1' }
            }
        });

        if (values.opcode !== undefined) {
            if (values.opcode.some(oc => !/^[0-9a-zA-Z]{1,2}$/.test(oc))) {
                throw new Error('Opcode must be an 8-bit hexadecimal value');
            }
            values.opcode = values.opcode.map(oc => oc.toLowerCase().padStart(2, '0'));
        }

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
        console.log('Usage: node test.js [--opcode|-o <opcode>] [--index|-i <index>] [--hash|-h <hash>]');
        console.log('          [--dump-errors|-d] [--trace|-t] [--single-thread|-1]');
        process.exit(1);
    }
};

const options = parseCommandLine();

const formatPassedFailed = (passed, failed) => {
    let output = '';

    const passedMessage = `passed ${String(passed).padStart(5)}`;
    output += chalk.green(passed > 0 ? passedMessage : ' '.repeat(passedMessage.length));

    output += passed > 0 && failed > 0 ? ', ' : '  ';

    const failedMessage = `failed ${String(failed).padStart(5)}`;
    output += chalk.red(failed > 0 ? failedMessage : ' '.repeat(failedMessage.length));

    return output;
};

const loadTests = async (dir, file, idx, hash) => {
    const zbuffer = await fsp.readFile(path.join(dir, file));
    const buffer = await gunzipAsync(zbuffer);

    const json = buffer.toString('utf8');
    const data = JSON.parse(json);

    return data.filter((test) => {
        return (idx === undefined || idx.some(i => test.idx === i))
            && (hash === undefined || hash.some(h => test.hash.startsWith(h)));
    });
};

const runTests = async (file, tests, trace) => {
    mpb.addTask(file, { type: 'percentage' });

    let passed = 0, failed = 0;
    const runOneTest = async (test, i) => {
        let error;
        if (options['single-thread']) {
            error = await worker({ test, trace });
        } else {
            error = await piscina.run({ test, trace });
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

        const message = formatPassedFailed(passed, failed);
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

    log.write(`file: "${file}", passed: ${passed}, failed: ${failed}\n`);

    const message = formatPassedFailed(passed, failed);
    mpb.done(file, { message });
};

const onWorkerMessage = (data) => {
    switch (data.type) {
    case 'log': console.log(data.message); return;
    }
};

const main = async () => {
    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write('CPU tests started\n');

    piscina.on('message', onWorkerMessage);

    const files = (await fsp.readdir(TESTS_DIR))
        .filter(file => file.match(/.*\.gz/))
        .filter(file => options.opcode === undefined || options.opcode.some(oc => file.toLowerCase().startsWith(oc)));

    for (const file of files) {
        const tests = await loadTests(TESTS_DIR, file, options.index, options.hash);
        await runTests(file, tests, options.trace);
    }

    mpb.close();
    log.end();
};

await main();
