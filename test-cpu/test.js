// make -C .. && make build-intcode && time ICVM=~/intcode/xzintbit/vms/c/ic node test.js

import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import chalk from 'chalk';
import { MultiProgressBars } from 'multi-progress-bars';
import Piscina from 'piscina';

const piscina = new Piscina({ filename: path.resolve(import.meta.dirname, 'worker.js') });
const mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

const log = fs.createWriteStream('test.log', { flags: 'a', encoding: 'utf8' });

const TESTS_DIR = path.join('..', '..', '8088', 'v1');

const formatPassedFailed = (passed, failed) => {
    let output = '';

    const passedMessage = `passed ${String(passed).padStart(5)}`;
    output += chalk.green(passed > 0 ? passedMessage : ' '.repeat(passedMessage.length));

    output += passed > 0 && failed > 0 ? ', ' : '  ';

    const failedMessage = `failed ${String(failed).padStart(5)}`;
    output += chalk.red(failed > 0 ? failedMessage : ' '.repeat(failedMessage.length));

    return output;
};

const runTest = async (dir, file) => {
    const { passed, failed } = await piscina.run({ dir, file });

    const message = formatPassedFailed(passed, failed);
    mpb.done(file, { message });

    log.write(`file: "${file}", passed: ${passed}, failed: ${failed}\n`);
};

const onWorkerMessage = (data) => {
    if (!mpb.getIndex(data.file)) {
        mpb.addTask(data.file, { type: 'percentage' });
    }

    const percentage = data.index / data.total;
    const message = formatPassedFailed(data.passed, data.failed);
    mpb.updateTask(data.file, { percentage, message });
};

const main = async () => {
    if (process.env.ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    log.write('CPU tests started\n');

    piscina.on('message', onWorkerMessage);

    const files = (await fsp.readdir(TESTS_DIR)).filter(file => file.match(/.*\.gz/));
    const promises = files.map(file => runTest(TESTS_DIR, file));

    await Promise.allSettled(promises);

    mpb.close();
    log.end();
};

await main();
