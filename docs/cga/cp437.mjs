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

const comment = (index, char) => `# ${index.toString(10).padStart(3)} (${index.toString(16).padStart(2, '0')})${char === undefined ? '' : ` ${char}`.trimEnd()}`;
const db = (bytes) => `    db  ${bytes.map(b => `0x${b.toString(16).padStart(2, '0')}`).join(', ')}${', 0x00'.repeat(3 - bytes.length)}`;
const line = (index, bytes, char) => `${db(bytes)}                ${comment(index, char)}`

console.log('.EXPORT cp437');
console.log('');
console.log('# Conversion table between CP437 and UTF-8; generated using cp437.js');
console.log('');
console.log('cp437:');

for (let index = 0; index < 256; index++) {
    const char = utf8[index]
    const bytes = [...Buffer.from(char, 'utf8').values()];
    if (bytes.length > 3) {
        throw new Error('char code too long');
    }
    console.log(line(index, bytes, char));
}

console.log('');
console.log('.EOF');
