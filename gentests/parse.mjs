import yaml from 'yaml';
import fs from 'node:fs/promises';

const f8 = n => n.toString(16).padStart(2, '0');

const main = async () => {
    const params = JSON.parse(await fs.readFile(process.argv[2], 'utf8'));
    const resf = await fs.readFile(process.argv[3], 'utf8');

    const res = resf.trim().split(/\n\r?/).flatMap(line => {
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

    if (params.length > res.length) throw new Error(`lengths ${params.length} ${res.length}`);

    const tests = params.map((p, i) => {
        const test = {
            desc: `${p[0]} ${f8(p[1])}, ${f8(p[2])} -> ${f8(p[3])}`,
            setup: {
                mem: {
                    ">0x0000<": `LDA #$${f8(p[1])}
ADC #$${f8(p[2])}
.byte $02
`}
            },
            check: {
                a: `>0x${f8(p[3])}<`
            }
        };
        if (res[i].negative) test.check.negative = true;
        if (res[i].overflow) test.check.overflow = true;
        if (res[i].zero) test.check.zero = true;
        if (res[i].carry) test.check.carry = true;
        return test;
    });

    console.log(yaml.stringify(tests));
};

await main();
