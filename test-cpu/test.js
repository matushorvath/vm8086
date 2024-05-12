// ICVM=~/intcode/xzintbit/vms/c/ic node test.js 

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

const testCode = (await fs.readFile(path.join('obj', 'test.input'), 'utf8')).trimEnd();
const tmpdir = await fs.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

const runTest = async (test) => {
    // Prepare input data for the test
    const regs = ['ax', 'bx', 'cx', 'dx', 'cs', 'ss', 'ds', 'es', 'sp', 'bp', 'si', 'di', 'ip', 'flags'];
    const input = regs.map(r => test.initial.regs[r]);

    input.push(test.initial.ram.length);
    input.push(...test.initial.ram.flatMap(loc => loc));

    // Append input data to the intcode program
    const testName = path.join(tmpdir, test.test_hash);
    const testData = `${testCode},${input.map(n => n.toString()).join(',')}\n`;
    await fs.appendFile(testName, testData, 'utf8');

    console.log(testName);

    // Execute the test
    const { stdout } = await execFileAsync(ICVM, [testName]);
    console.log(stdout);

    process.exit(0);    // TODO remove
};

const main = async () => {
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
