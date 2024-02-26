import { OPCODES } from './opcodes.mjs';

const seq = (b, e) => Array(e - b).fill().map((_, i) => b + i);
const f8 = n => n.toString(16).padStart(2, '0');

const main = () => {       // eslint-disable-line no-unused-vars
    const data = seq(0, 256)
        .map(op => OPCODES[op] ?? (op === 2 ? { name: 'HLT', code: 0x02, length: 1 } : undefined))
        .map((d, i) => d ? [
            `# ${d.code} = 0x${f8(d.code)}, ${d.name}${d.mode ? ' (' + d.mode + ')' : ''}`,
            `db  "${d.name}"${new Array(4 - d.name.length).fill(', 0')}`,
            `db  ${d.length}`
        ] : [
            `# ${i} = 0x${f8(i)}`,
            'ds  5, 0'
        ])
        .map(lines => lines.join('\n')).join('\n\n');

    console.log(data);
};

main();
