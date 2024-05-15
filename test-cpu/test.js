// make -C .. && make build-intcode && ICVM=~/intcode/xzintbit/vms/c/ic node test.js

import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import util from 'node:util';
import chalk from 'chalk';
import { MultiProgressBars } from 'multi-progress-bars';
import Piscina from 'piscina';

const piscina = new Piscina({ filename: path.resolve(import.meta.dirname, 'worker.js') });
const mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

const log = fs.createWriteStream('test.log', { flags: 'a', encoding: 'utf8' });

const TESTS_DIR = path.join('..', '..', '8088', 'v1');

const parseCommandLine = () => {
    try {
        const { values } = util.parseArgs({
            options: {
                opcode: { type: 'string', short: 'o' },
                index: { type: 'string', short: 'i' },
                hash: { type: 'string', short: 'h' },
                details: { type: 'boolean', short: 'd' }
            }
        });

        if (values.opcode !== undefined) {
            if (!/^[0-9a-zA-Z]{1,2}$/.test(values.opcode)) {
                throw new Error('Opcode must be an 8-bit hexadecimal value');
            }
            values.opcode = values.opcode.toLowerCase().padStart(2, '0');
        }

        if (values.index !== undefined && values.hash !== undefined) {
            throw new Error('Both index and hash must not be specified at the same time');
        }

        if (values.index !== undefined) {
            if (!/^\d+$/.test(values.index)) {
                throw new Error('Index must be a positive integer');
            }
            values.index = Number.parseInt(values.index);
        }

        return values;
    } catch (error) {
        console.error(error.message);
        console.log('Usage: node test.js [--opcode|-o <opcode>] [--index|-i <index>] [--hash|-h <hash>] [--details|-d]');
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

const runTest = async (dir, file, idx, hash) => {
    const { passed, failed } = await piscina.run({ dir, file, idx, hash });

    if (mpb.getIndex(file) !== undefined) {
        const message = formatPassedFailed(passed, failed);
        mpb.done(file, { message });
    }

    log.write(`file: "${file}", passed: ${passed}, failed: ${failed}\n`);
};

const onWorkerMessage = ({ file, test, passed, failed, error, percentage }) => {
    if (mpb.getIndex(file) === undefined) {
        mpb.addTask(file, { type: 'percentage' });
    }

    if (options.details && error !== undefined) {
        console.log(`${test.name}: ${chalk.red('FAILED')}`);
        console.log(chalk.gray(`idx: ${test.idx} hash: ${test.hash}`));
        console.log('');
        console.log(error.toString());
        console.log('');

        log.write(`file: "${file}", name: ${test.name}, idx: ${test.idx}, hash: ${test.hash}`);
        log.write(error.toString());
    }

    const message = formatPassedFailed(passed, failed);
    mpb.updateTask(file, { percentage, message });
};

const main = async () => {
    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write('CPU tests started\n');

    piscina.on('message', onWorkerMessage);

    const promises = (await fsp.readdir(TESTS_DIR))
        .filter(file => file.match(/.*\.gz/))
        .filter(file => options.opcode === undefined || file.toLowerCase().startsWith(options.opcode))
        .map(file => runTest(TESTS_DIR, file, options.index, options.hash));

    await Promise.allSettled(promises);

    mpb.close();
    log.end();
};

await main();
