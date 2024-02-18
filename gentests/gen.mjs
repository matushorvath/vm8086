// node ./gentests/gen.mjs ADCf > code.s
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
        [0x40, 0xC0],
        [0xB0, 0x50],
        [0x7F, 0x81]
    ],

    0x42: [
        [0x12, 0x30],
        [0xF0, 0x52],
        [0x60, 0xE2],
        [0xA0, 0xA2]
    ],

    0x7f: [
        [0x50, 0x2f]
    ],

    0x80: [
        [0x20, 0x60],
        [0x81, 0xFF]
    ],

    0xB6: [
        [0x70, 0x46],
        [0x90, 0x26],
        [0xB7, 0xFF]
    ],

    0xFF: [
        [0xFE, 0x01]
    ]
};

const f8 = n => n.toString(16).padStart(2, '0');

let idx = 0;

const genadc = (op1, op2, res, carry) => {
    console.log(`
        ${carry ? 'SEC' : 'CLC'}
        LDA #$${f8(op1)}
        ADC #$${f8(op2)}
        STA $${f8(0x1000 + 2 * idx)}
        PHP
        PLA
        STA $${f8(0x1000 + 2 * idx + 1)}
`);

    if (idx !== 0) process.stderr.write(',\n');
    process.stderr.write(`["ADC", ${op1}, ${op2}, ${res}, ${carry}]`);

    idx++;
};

const gensbc = (op1, op2, res, carry) => {
    console.log(`
        ${carry ? 'SEC' : 'CLC'}
        LDA #$${f8(res)}
        ADC #$${f8(op1)}
        STA $${f8(0x1000 + 2 * idx)}
        PHP
        PLA
        STA $${f8(0x1000 + 2 * idx + 1)}
`);

    if (idx !== 0) process.stderr.write(',\n');
    process.stderr.write(`["SBC", ${op1}, ${op2}, ${res}, ${carry}]`);

    idx++;
};

const gencmp = (op1, op2, res, carry) => {
    console.log(`
        ${carry ? 'SEC' : 'CLC'}
        LDA #$${f8(res)}
        CMP #$${f8(op1)}
        STA $${f8(0x1000 + 2 * idx)}
        PHP
        PLA
        STA $${f8(0x1000 + 2 * idx + 1)}
`);

    if (idx !== 0) process.stderr.write(',\n');
    process.stderr.write(`["CMP", ${op1}, ${op2}, ${res}, ${carry}]`);

    idx++;
};

const gen = (op1, op2, res) => {
    switch (process.argv[2]) {
    case 'ADCf': return genadc(op1, op2, res, false);
    case 'ADCt': return genadc(op1, op2, res, true);
    case 'SBCf': return gensbc(op1, op2, res, false);
    case 'SBCt': return gensbc(op1, op2, res, true);
    case 'CMPf': return gencmp(op1, op2, res, false);
    case 'CMPt': return gencmp(op1, op2, res, true);
    }
};

process.stderr.write('[\n');

for (const op1 of ops) {
    for (const op2 of ops) {
        gen(op1, op2, (op1 + op2 + 0x100) % 0x100);
    }
}

for (const key of Object.keys(cases)) {
    for (const [op1, op2] of cases[key]) {
        const res = (op1 + op2 + 0x100) % 0x100;
        gen(op1, op2, res);
    }
}

process.stderr.write('\n]\n');
