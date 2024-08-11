// Clean up the "# From" comments
// node import_cleanup.mjs ~/intcode/vm8086

import fsp from 'node:fs/promises';
import path from 'node:path';
import dotgit from 'dotgitignore';

const getCandidates = (exports, source, importSymbol) => {
    const candidates = Object.entries(exports)
        .filter(([_, v]) => v.includes(importSymbol))
        .map(([k]) => k)
        .map(c => path.dirname(c) === path.dirname(source) ? path.basename(c) : c);

    return candidates.length > 0 ? candidates : '(none)';
};

const main = async () => {
    const root = path.normalize(process.argv[2]);
    const stack = [''];

    const filter = dotgit(root);

    const sources = [];

    while (stack.length > 0) {
        const dir = stack.pop();

        const entries = await fsp.readdir(path.join(root, dir), { withFileTypes: true });

        for (const entry of entries) {
            const entryPath = path.join(dir, entry.name);

            if (filter.ignore(entryPath) || entryPath === '.git') {
                continue;
            }

            if (entry.isDirectory()) {
                stack.push(entryPath);
            } else if (entry.isFile() && entry.name.endsWith('.s')) {
                sources.push(entryPath);
            }
        }
    }

    const exports = {};

    for (const source of sources) {
        const text = await fsp.readFile(path.join(root, source), 'utf8');

        const matches = text.matchAll(/.EXPORT (.*)/g);
        exports[source] = [...matches].map(m => m[1]);
    }

    for (const source of sources) {
        const sourceDir = path.dirname(source);

        const text = await fsp.readFile(path.join(root, source), 'utf8');
        const matches = text.matchAll(/# From (.*\.s)\s+.IMPORT (.*)/g);

        for (const [_, importFile, importSymbol] of matches) {
            const exportFromRoot = exports[importFile];
            const exportFromDir = exports[path.join(sourceDir, importFile)];

            if (exportFromRoot === undefined && exportFromDir === undefined) {
                console.log(`${source}: "From ${importFile}": File does not exist; candidates: ${getCandidates(exports, source, importSymbol)}`);
                continue;
            }

            const exp = exportFromRoot ?? exportFromDir;
            if (!exp.includes(importSymbol)) {
                console.log(`${source}: "From ${importFile} .IMPORT ${importSymbol}": Symbol not in file; candidates: ${getCandidates(exports, source, importSymbol)}`);
                continue;
            }
        }
    }
};

await main();
