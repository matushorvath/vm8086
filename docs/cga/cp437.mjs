import fs from 'node:fs/promises';
import child_process from 'node:child_process';
import util from 'node:util';

const execFileAsync = util.promisify(child_process.execFile);

const cp437 = [];
for (let i = 32; i < 256; i++) {
    cp437.push(i);
    cp437.push(0);
}

const promise = execFileAsync('iconv', ['-f', 'CP437', '-t', 'UTF-8']);

promise.child.stdin.write(Buffer.from(cp437));
promise.child.stdin.end();

const child = await promise;

// Manually convert first 32 characters, iconv does not render them right
const ctrl = ' ☺☻♥♦♣♠•◘○◙♂♀♪♫☼►◄↕‼¶§▬↨↑↓→←∟↔▲▼'.split('');

const utf8 = ctrl.concat(child.stdout.split('\x00'));

// Fix the ⌂ character, iconv renders it as a space
utf8[0x7f] = '⌂';

// Fix character 0xff, which is NBSP, replace by a regular space
utf8[0xff] = ' ';

const tohex = (num) => num.toString(16).padStart(2, '0');
const comment = (byte, index, char) => `# ${tohex(index)}[${byte}]${(` ${char ?? ''}`).trimEnd()}`;
const line = (byte, index, value, char) => `    db  0x${tohex(value ?? 0)}       ${comment(byte, index, char)}`

console.log('.EXPORT cp437_b0');
console.log('.EXPORT cp437_b1');
console.log('.EXPORT cp437_b2');
console.log('');
console.log('# Conversion table between CP437 and UTF-8; generated using cp437.js');
console.log('');

for (let byte = 0; byte < 3; byte++) {
    console.log(`cp437_b${byte}:`);

    for (let index = 0; index < 256; index++) {
        const char = utf8[index]
        const buffer = Buffer.from(char, 'utf8');

        if (buffer.length > 3) {
            throw new Error('utf-8 character too long');
        }

        console.log(line(byte, index, buffer[byte], char));
    }

    console.log('');
}

console.log('.EOF');
