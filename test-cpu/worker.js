import assert from 'node:assert/strict';
import child_process from 'node:child_process';
import fsp from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import wt from 'node:worker_threads';

const execFileAsync = util.promisify(child_process.execFile);

const ICVM = process.env.ICVM;

const testBinary = path.join('obj', 'test.input');
const testCode = (await fsp.readFile(testBinary, 'utf8')).trimEnd();
const tmpdir = await fsp.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

const runIntcode = async (hash, input, trace) => {
    const testData = `${testCode},${input.map(n => n.toString()).join(',')}\n`;
    const testName = path.join(tmpdir, hash);
    const mapName = `${testName}.map.yaml`;

    let child;
    try {
        // Append input data to the intcode program
        await fsp.appendFile(testName, testData, 'utf8');
        await fsp.copyFile(`${testBinary}.map.yaml`, mapName);

        // Execute the test
        if (trace) {
            wt.parentPort.postMessage({ type: 'log', message: `starting: ${hash}` });
        }

        child = await execFileAsync(ICVM, [testName]);

        if (trace) {
            wt.parentPort.postMessage({ type: 'log', message: `finished: ${hash}` });
        }
    } finally {
        // Clean up
        await fsp.unlink(testName);
        await fsp.unlink(mapName);
    }

    return child.stdout;
};

const processOutput = (test, stdout) => {
    let result;
    try {
        result = JSON.parse(stdout);
    } catch (error) {
        if (!(error instanceof SyntaxError)) {
            throw error;
        }
        return error;
    }

    // Adjust the result
    result.regs.flags |= 0xF000;        // top half-byte of 8086 flags should be all 1s, but bochs has 0s

    // Keep only result registers we are supposed to check
    for (const key in result.regs) {
        if (!Object.hasOwn(test.final.regs, key)) {
            delete result.regs[key];
        }
    }

    try {
        assert.deepStrictEqual(test.final.regs, result.regs);
        assert.deepStrictEqual(test.final.ram, result.ram);
    } catch (error) {
        if (!(error instanceof assert.AssertionError)) {
            throw error;
        }
        return error;
    }
};

export default async ({ test, trace }) => {
    // Prepare input data for the test
    const regs = ['ax', 'bx', 'cx', 'dx', 'cs', 'ss', 'ds', 'es', 'sp', 'bp', 'si', 'di', 'ip', 'flags'];
    const input = regs.map(r => test.initial.regs[r]);

    input.push(test.initial.ram.length);
    input.push(test.final.ram.length);
    input.push(...test.initial.ram.flatMap(rec => rec));
    input.push(...test.final.ram.map(([addr]) => addr));

    const output = await runIntcode(test.hash, input, trace);
    return processOutput(test, output);
};
