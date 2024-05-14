// make -C .. && make build-intcode && time ICVM=~/intcode/xzintbit/vms/c/ic FORCE_COLOR=3 node test.js | tee test.log

import assert from 'node:assert/strict';
import child_process from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import wt from 'node:worker_threads';
import zlib from 'node:zlib';

const gunzipAsync = util.promisify(zlib.gunzip);
const execFileAsync = util.promisify(child_process.execFile);

const ICVM = process.env.ICVM;

const testBinary = path.join('obj', 'test.input');
const testCode = (await fs.readFile(testBinary, 'utf8')).trimEnd();
const tmpdir = await fs.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

const compareResult = (test, result) => {
    try {
        assert.deepStrictEqual(test.final.regs, result.regs);
        assert.deepStrictEqual(test.final.ram, result.ram);

        // process.stdout.write(`${test.name}: ${chalk.green('PASSED')}\n`);

        return true;
    } catch (error) {
        if (!(error instanceof assert.AssertionError)) {
            throw error;
        }

        // process.stdout.write(`${test.name}: ${chalk.red('FAILED')}\n`);
        // process.stdout.write(`hash: ${chalk.gray(test.hash)}\n\n`);
        // process.stdout.write(error.toString());
        // process.stdout.write('\n\n');

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

    const testData = `${testCode},${input.map(n => n.toString()).join(',')}\n`;
    const testName = path.join(tmpdir, test.hash);
    const mapName = `${testName}.map.yaml`;

    let child;
    try {
        // Append input data to the intcode program
        await fs.appendFile(testName, testData, 'utf8');
        await fs.copyFile(`${testBinary}.map.yaml`, mapName);

        // Execute the test
        child = await execFileAsync(ICVM, [testName]);
    } finally {
        // Clean up
        await fs.unlink(testName);
        await fs.unlink(mapName);
    }

    let result;
    try {
        result = JSON.parse(child.stdout);
    } catch (error) {
        if (!(error instanceof SyntaxError)) {
            throw error;
        }
        return false;
    }

    // Adjust the result
    result.regs.flags |= 0xF000;        // top half-byte of 8086 flags should be all 1s, but bochs has 0s

    // Keep only result registers we are supposed to check
    for (const key in result.regs) {
        if (!Object.hasOwn(test.final.regs, key)) {
            delete result.regs[key];
        }
    }

    // Compare the result
    return compareResult(test, result);
};

export default async ({ dir, file }) => {
    const zbuffer = await fs.readFile(path.join(dir, file));
    const buffer = await gunzipAsync(zbuffer);

    const json = buffer.toString('utf8');
    const data = JSON.parse(json);

    data.length = 100;

    let passed = 0, failed = 0;

    for (let index = 0; index < data.length; index++) {
        const test = data[index];

        const res = await runTest(test);
        if (res) {
            passed++;
        } else {
            failed++;
        }

        wt.parentPort.postMessage({ file, index, total: data.length, passed, failed });
    }

    return { passed, failed };
};
