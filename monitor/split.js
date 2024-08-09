// Split one input stream into stdout and stderr
// Everything between a 0x1f 0x1f 0x1f marker and a 0x0a new line character goes to stderr, the rest goes to stdout

// Usage:
// - Open two terminals, one for stdout, one for stderr.
// - On the stderr terminal, run `ls /proc/self/fd/1` to determine which device is it connected to.
// - On the stdout terminal, run `npm run | ./monitor/split 2> /dev/pts/<stderr-device>

// Make some test input:
// - Write 'qqq' patterns into a text file, e.g. LICENSE.
// - cat modified-LICENSE | tr q '\037' > monitor/test.in

// Run the VM with logs in second window;
// - make run | ./monitor/split 2> /dev/pts/0

// Run the VM with logs redirected to less:
// - mkfifo log.pipe
// - less -f log.pipe
// - make run | ./monitor/split 2> ../log.pipe

import '@ungap/with-resolvers';

export const writeStreamAndWait = async (stream, chunk) => {
    const { resolve, reject, promise } = Promise.withResolvers();
    stream.write(chunk, (error) => {
        if (error) {
            reject(error);
        } else {
            resolve();
        }
    });
    return promise;
};

const STATE_OUT = Symbol();
const STATE_1F = Symbol();
const STATE_1F_1F = Symbol();
const STATE_ERR = Symbol();

let state = STATE_OUT;

for await (const chunk of process.stdin) {
    for (const byte of chunk) {
        switch (state) {
        case STATE_OUT:
            if (byte === 0x1F) state = STATE_1F;
            else await writeStreamAndWait(process.stdout, new Uint8Array([byte]));
            break;
        case STATE_1F:
            if (byte === 0x1F) state = STATE_1F_1F;
            else await writeStreamAndWait(process.stdout, new Uint8Array([0x1f, byte]));
            break;
        case STATE_1F_1F:
            if (byte === 0x1F) state = STATE_ERR;
            else await writeStreamAndWait(process.stdout, new Uint8Array([0x1f, 0x1f, byte]));
            break;
        case STATE_ERR:
            if (byte === 0x0a) state = STATE_OUT;
            await writeStreamAndWait(process.stderr, new Uint8Array([byte]));
            break;
        }
    }
}
