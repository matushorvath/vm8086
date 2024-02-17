// node ./gentests/gen.mjs > code.s
// ./tests/assemble.sh < code.s > code.bin
// stderr is adc.json
// < code.bin hexdump -ve '/1 "%02x "'

// https://www.masswerk.at/6502/
// clear memory
// load memory starting at 0000
// reset CPU, continuous run
// inspect memory starting at 1000 for results
// memory dump starting 1000 (in hexdump format) is adc.res
// node ./gentests/parse.mjs adc.json adc.res

const ops = [0x00, 0x42, 0x7f, 0x80, 0xB6, 0xFF];

const cases = {
    0x00: [
        [0x00, 0x00],
        [0x40, 0xC0],
        [0xB0, 0x50],
        [0x80, 0x80],
        [0x7F, 0x81]
    ],

    0x42: [
        [0x00, 0x42],
        [0x12, 0x30],
        [0xF0, 0x52],
        [0x60, 0xE2],
        [0xA0, 0xA2]
    ],

    0x7f: [
        [0x7f, 0x00],
        [0x50, 0x2f],
        [0xFF, 0x80]
    ],

    0x80: [
        [0x80, 0x00],
        [0x20, 0x60],
        [0x81, 0xFF]
    ],

    0xB6: [
        [0x00, 0xB6],
        [0xB6, 0x00],
        [0x70, 0x46],
        [0x90, 0x26],
        [0xB7, 0xFF]
    ],

    0xFF: [
        [0xFF, 0x00],
        [0x00, 0xFF],
        [0xFE, 0x01],
        [0x7f, 0x80]
    ]
};

const f8 = n => n.toString(16).padStart(2, '0');

let idx = 0;

const genadc = (op1, op2, res) => {
    console.log(`
        LDA #$${f8(op1)}
        ADC #$${f8(op2)}
        STA $${f8(0x1000 + 2 * idx)}
        PHP
        PLA
        STA $${f8(0x1000 + 2 * idx + 1)}
`);

    if (idx !== 0) process.stderr.write(',\n');
    process.stderr.write(`["ADC", ${op1}, ${op2}, ${res}]`);

    idx++;
};

process.stderr.write('[\n');

for (const op1 of ops) {
    for (const op2 of ops) {
        genadc(op1, op2, (op1 + op2 + 0x100) % 0x100);
    }
}

for (const key of Object.keys(cases)) {
    const res = Number(key);
    for (const [op1, op2] of cases[key]) {
        const caseRes = (op1 + op2 + 0x100) % 0x100;
        if (caseRes !== res) throw new Error(`mismatch ${f8(op1)} ${f8(op2)} is ${f8(res)} should be ${f8(caseRes)}`);
        genadc(op1, op2, res);
    }
}

process.stderr.write('\n]\n');
