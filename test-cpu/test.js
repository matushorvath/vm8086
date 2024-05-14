// make -C .. && make build-intcode && time ICVM=~/intcode/xzintbit/vms/c/ic FORCE_COLOR=3 node test.js | tee test.log

import fs from 'node:fs/promises';
import path from 'node:path';
import chalk from 'chalk';
import { MultiProgressBars } from 'multi-progress-bars';
import Piscina from 'piscina';

const piscina = new Piscina({ filename: path.resolve(import.meta.dirname, 'worker.js') });
const mpb = new MultiProgressBars({ initMessage: 'CPU Test', anchor: 'top', persist: true });

const TESTS_DIR = path.join('..', '..', '8088', 'v1');

const formatPassedFailed = (passed, failed) => {
    return `${chalk.green(`passed ${String(passed).padStart(5)}`)}, ${chalk.red(`failed ${String(failed).padStart(5)}`)}`;
};

const runTest = async (fileCount, dir, file) => {
    const { passed, failed } = await piscina.run({ dir, file });

    const message = formatPassedFailed(passed, failed);
    mpb.done(file, { message });
    //console.log(`${file} > ${message}`);

    mpb.incrementTask('all tests', { percentage: 1 / fileCount });
};

const onWorkerMessage = (data) => {
    if (!mpb.getIndex(data.file)) {
        const match = data.file.match(/([0-9a-fA-F]{2})\.json.gz/);
        const index = match ? Number.parseInt(match[1] , 16) + 1 : undefined;
        mpb.addTask(data.file, { type: 'percentage', index });
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

    mpb.addTask('all tests', { type: 'percentage' });
    piscina.on('message', onWorkerMessage);

    const files = (await fs.readdir(TESTS_DIR)).filter(file => file.match(/.*\.gz/));
    const promises = files.map(file => runTest(files.length, TESTS_DIR, file));

    await Promise.allSettled(promises);

    mpb.done('all tests');
    mpb.close();
};

await main();
