// make -C .. && make build-intcode && ICVM=~/intcode/xzintbit/vms/c/ic node test.js

import child_process from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import zlib from 'node:zlib';

const execFileAsync = util.promisify(child_process.execFile);
const gunzipAsync = util.promisify(zlib.gunzip);

const ICVM = process.env.ICVM;
const PROCESSOR_TESTS_DIR = '../../ProcessorTests';

const testBinary = path.join('obj', 'test.input');
const testCode = (await fs.readFile(testBinary, 'utf8')).trimEnd();
const tmpdir = await fs.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

const runTest = async (test) => {
    // Prepare input data for the test
    const regs = ['ax', 'bx', 'cx', 'dx', 'cs', 'ss', 'ds', 'es', 'sp', 'bp', 'si', 'di', 'ip', 'flags'];
    const input = regs.map(r => test.initial.regs[r]);

    input.push(test.initial.ram.length);
    input.push(test.final.ram.length);
    input.push(...test.initial.ram.flatMap(rec => rec));
    input.push(...test.final.ram.map(([addr]) => addr));

    // Append input data to the intcode program
    const testName = path.join(tmpdir, test.test_hash);
    const testData = `${testCode},${input.map(n => n.toString()).join(',')}\n`;
    await fs.appendFile(testName, testData, 'utf8');
    await fs.copyFile(`${testBinary}.map.yaml`, `${testName}.map.yaml`);

    console.log(testName);

    // Execute the test
    const { stdout } = await execFileAsync(ICVM, [testName]);
    console.log(stdout);

    process.exit(0);    // TODO remove
};

const main = async () => {
    if (ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    const dir = path.join(PROCESSOR_TESTS_DIR, '8088', 'v1');
    for (const file of await fs.readdir(dir)) {
        if (!file.match(/.*\.gz/)) {
            continue;
        }

        const zbuffer = await fs.readFile(path.join(dir, file));
        const buffer = await gunzipAsync(zbuffer);

        const json = buffer.toString('utf8');
        const data = JSON.parse(json);

        for (const test of data) {
            await runTest(test);
        }
    }
};

await main();
