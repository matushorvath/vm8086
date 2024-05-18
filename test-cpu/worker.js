import assert from 'node:assert/strict';
import child_process from 'node:child_process';
import fsp from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import wt from 'node:worker_threads';
import chalk from 'chalk';

const execFileAsync = util.promisify(child_process.execFile);

const ICVM = process.env.ICVM;

const testBinary = path.join('obj', 'test.input');
const testCode = (await fsp.readFile(testBinary, 'utf8')).trimEnd();
const tmpdir = await fsp.mkdtemp(path.join(os.tmpdir(), 'vm8086-'));

let options;

const consoleLog = (message) => {
    // Avoid accessing the console from multiple threads, if we're running as a worker thread
    if (wt.isMainThread) {
        console.log(message);
    } else {
        wt.parentPort.postMessage({ type: 'log', message });
    }
};

const executeTest = async (hash, input) => {
    const testData = `${testCode},${input.map(n => n.toString()).join(',')}\n`;
    const testName = path.join(tmpdir, hash);
    const mapName = `${testName}.map.yaml`;

    try {
        // Append input data to the intcode program
        await fsp.appendFile(testName, testData, 'utf8');
        await fsp.copyFile(`${testBinary}.map.yaml`, mapName);

        // Execute the test
        if (options.trace) {
            consoleLog(`starting: ${hash} ${testName}`);
        }

        const child = await execFileAsync(ICVM, [testName]);

        if (options.trace) {
            consoleLog(`finished: ${hash}`);
        }

        return { stdout: child.stdout, stderr: child.stderr };
    } finally {
        // Clean up
        if (!options.keep) {
            await fsp.unlink(testName);
            await fsp.unlink(mapName);
        }
    }
};

const processOutput = (test, stdout) => {
    let result;
    try {
        result = JSON.parse(stdout);
    } catch (error) {
        if (!(error instanceof SyntaxError)) {
            throw error;
        }
        return [error, {}];
    }

    // Adjust the flags
    result.regs.flags |= 0xF000;        // top half-byte of 8086 flags should be all 1s, but bochs has 0s

    const flagMask = test.flagMask ?? 0xffff;
    result.regs.flags &= flagMask;

    // Keep only result registers we are supposed to check
    for (const key in result.regs) {
        if (!Object.hasOwn(test.final.regs, key)) {
            delete result.regs[key];
        }
    }

    try {
        assert.deepStrictEqual(result.regs, test.final.regs);
        assert.deepStrictEqual(result.ram, test.final.ram);
    } catch (error) {
        if (!(error instanceof assert.AssertionError)) {
            throw error;
        }
        return [error, result];
    }

    return [];
};

export default async ({ test, options: parentOptions }) => {
    options = parentOptions;

    // Prepare input data for the test
    const regs = ['ax', 'bx', 'cx', 'dx', 'cs', 'ss', 'ds', 'es', 'sp', 'bp', 'si', 'di', 'ip', 'flags'];
    const input = regs.map(r => test.initial.regs[r]);

    input.push(test.initial.ram.length);
    input.push(test.final.ram.length);
    input.push(...test.initial.ram.flatMap(rec => rec));
    input.push(...test.final.ram.map(([addr]) => addr));

    const { stdout, stderr } = await executeTest(test.hash, input);

    if (options['dump-stdout']) {
        consoleLog(`${test.name}`);
        consoleLog(chalk.gray(`idx: ${test.idx} hash: ${test.hash}`));
        consoleLog('');
        consoleLog('stdout>');
        consoleLog(stdout);
        consoleLog('');
        consoleLog('stderr>');
        consoleLog(stderr);
        consoleLog('');
    }

    return processOutput(test, stdout);
};
