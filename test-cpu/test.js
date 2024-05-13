// make -C .. && make build-intcode && time ICVM=~/intcode/xzintbit/vms/c/ic FORCE_COLOR=3 node test.js | tee test.log

import assert from 'node:assert/strict';
import child_process from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import zlib from 'node:zlib';
import chalk from 'chalk';

const execFileAsync = util.promisify(child_process.execFile);
const gunzipAsync = util.promisify(zlib.gunzip);

const ICVM = process.env.ICVM;
const PROCESSOR_TESTS_DIR = '../../ProcessorTests';

const testBinary = path.join('obj', 'test.input');
const testCode = (await fs.readFile(testBinary, 'utf8')).trimEnd();
const tmpdir = await fs.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

const compareResult = (test, result) => {
    try {
        assert.deepStrictEqual(test.final.regs, result.regs);
        assert.deepStrictEqual(test.final.ram, result.ram);

        //process.stdout.write(`${test.name}: ${chalk.green('PASSED')}\n`);

        return true;
    } catch (error) {
        if (!(error instanceof assert.AssertionError)) {
            throw error;
        }

        process.stdout.write(`${test.name}: ${chalk.red('FAILED')}\n`);
        process.stdout.write(`test_hash: ${chalk.gray(test.test_hash)}\n\n`);
        process.stdout.write(error.toString());
        process.stdout.write('\n\n');

        return false;
    }
};

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

    // Execute the test
    const { stdout } = await execFileAsync(ICVM, [testName]);
    const result = JSON.parse(stdout);

    // Adjust the result and compare it
    result.regs.flags |= 0xF000;        // top half-byte of 8086 flags should be all 1s, but bochs has 0s
    return compareResult(test, result);
};

const main = async () => {
    if (ICVM === undefined) {
        console.error('Missing path to intcode VM; make sure the ICVM environment variable is correct');
        return 1;
    }

    let totalPassed = 0, totalFailed = 0;

    const dir = path.join(PROCESSOR_TESTS_DIR, '8088', 'v1');
    for (const file of await fs.readdir(dir)) {
        if (!file.match(/.*\.gz/)) {
            continue;
        }

        let passed = 0, failed = 0;

        const zbuffer = await fs.readFile(path.join(dir, file));
        const buffer = await gunzipAsync(zbuffer);

        const json = buffer.toString('utf8');
        const data = JSON.parse(json);

        for (const test of data) {
            const res = await runTest(test);
            if (res) {
                passed++;
                totalPassed++;
            } else {
                failed++;
                totalFailed++
            }
        }

        console.log(`File ${file}: ${chalk.green(`${passed} PASSED`)}, ${chalk.red(`${failed} FAILED`)}`);
        console.log(`Total: ${chalk.green(`${totalPassed} PASSED`)}, ${chalk.red(`${totalFailed} FAILED`)}`);
    }
};

await main();
