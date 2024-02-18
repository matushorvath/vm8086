/* eslint-disable indent */

import yaml from 'yaml';
import fs from 'node:fs/promises';

const f8 = n => n.toString(16).padStart(2, '0');

const mkdesc = (p, r) => {
    switch (p[0]) {
    case 'ADC': return p[4] ? `ADC with carry; ${f8(p[1])} + ${f8(p[2])} -> ${f8(r.res)}`
                            : `ADC no carry; ${f8(p[1])} + ${f8(p[2])} -> ${f8(r.res)}`;
    case 'SBC': return p[4] ? `SBC with carry; ${f8(p[3])} - ${f8(p[1])} -> ${f8(r.res)}`
                            : `SBC no carry; ${f8(p[3])} - ${f8(p[1])} -> ${f8(r.res)}`;
    case 'CMP': return p[4] ? `CMP with carry; ${f8(p[3])} - ${f8(p[1])}`
                            : `CMP no carry; ${f8(p[3])} - ${f8(p[1])}`;
    }
};

const mkcode = (p) => {
    switch (p[0]) {
    case 'ADC': return p[4] ? `SEC\nLDA #$${f8(p[1])}\nADC #$${f8(p[2])}\n.byte $02\n`
                            : `LDA #$${f8(p[1])}\nADC #$${f8(p[2])}\n.byte $02\n`;
    case 'SBC': return p[4] ? `SEC\nLDA #$${f8(p[3])}\nSBC #$${f8(p[1])}\n.byte $02\n`
                            : `LDA #$${f8(p[3])}\nSBC #$${f8(p[1])}\n.byte $02\n`;
    case 'CMP': return p[4] ? `SEC\nLDA #$${f8(p[3])}\nCMP #$${f8(p[1])}\n.byte $02\n`
                            : `LDA #$${f8(p[3])}\nCMP #$${f8(p[1])}\n.byte $02\n`;
    }
};

const main = async () => {
    const params = JSON.parse(await fs.readFile(process.argv[2], 'utf8'));
    const resf = await fs.readFile(process.argv[3], 'utf8');

    const results = resf.trim().split(/\n\r?/).flatMap(line => {
        const m = line.match(/.{4}: ((.. .. ){4}) .*/);
        return [...m[1].matchAll(/(..) (..) /g)].map(([_, ress, flagss]) => {
            const res = Number.parseInt(ress, 16);
            const flags = Number.parseInt(flagss, 16); // NV....ZC
            return {
                res,
                negative: (flags & 0b1000_0000) !== 0,
                overflow: (flags & 0b0100_0000) !== 0,
                zero: (flags & 0b0000_0010) !== 0,
                carry: (flags & 0b0000_0001) !== 0
            };
        });
    });

    if (params.length > results.length) throw new Error(`lengths ${params.length} ${results.length}`);

    const tests = params.map((p, i) => {
        const test = {
            desc: mkdesc(p, results[i]),
            setup: {
                mem: {
                    '>0x0000<': mkcode(p)
                }
            },
            check: {}
        };

        if (p[0] !== 'CMP') test.check.a = `>0x${f8(results[i].res)}<`;

        if (results[i].negative) test.check.negative = true;
        if (results[i].overflow) test.check.overflow = true;
        if (results[i].zero) test.check.zero = true;
        if (results[i].carry) test.check.carry = true;

        return test;
    });

    const wholeFile = {
        desc: `${params[0][0]}, ${params[0][4] ? 'with carry' : 'no carry'}`,
        tests
    };

    const output = yaml.stringify(wholeFile)
        .replace(/">([^"]+)<"/g, '$1')
        .replace(/ {2}- desc:/g, '\n  - desc:')
        .replace(/tests:\n\n/g, 'tests:\n')
        .trim();
    console.log(output);
};

await main();
