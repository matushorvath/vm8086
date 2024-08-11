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
        const sourceImports = text.matchAll(/# From (.*\.s)\s+.IMPORT (.*)/g);

        for (const [_, importFile, importSymbol] of sourceImports) {
            const exportFromRoot = exports[importFile];
            const exportFromDir = exports[path.join(sourceDir, importFile)];

            if (exportFromRoot === undefined && exportFromDir === undefined) {
                const genFromRoot = path.join(path.dirname(importFile), `gen_${path.basename(importFile)}`);
                const genFromDir = path.join(sourceDir, `gen_${path.basename(importFile)}`);

                if (exports[genFromRoot] !== undefined || exports[genFromDir] !== undefined) {
                    // Ignore imports from generated files, as long as the generator exists
                    continue;
                }

                console.log(`${source}: "From ${importFile}": File does not exist; candidates: ${getCandidates(exports, source, importSymbol)}`);
                continue;
            }

            const exp = exportFromRoot ?? exportFromDir;
            if (!exp.includes(importSymbol)) {
                console.log(`${source}: "From ${importFile} .IMPORT ${importSymbol}": Symbol not in file; candidates: ${getCandidates(exports, source, importSymbol)}`);
                continue;
            }
        }

        const allImports = text.matchAll(/# From (.*)\s+.IMPORT (.*)/g);

        const importFiles = [...allImports].map(m => m[1]);
        const sortedImportFiles = importFiles.toSorted((a, b) => {
            const extOrder = { '': 0, '.s': 1, '.o': 1, '.a': 2 };

            const aext = extOrder[path.extname(a)] ?? 0;
            const bext = extOrder[path.extname(b)] ?? 0;

            if (aext !== bext) {
                return aext - bext;
            }

            const adir = path.dirname(a);
            const bdir = path.dirname(b);

            if (adir !== bdir) {
                return adir < bdir ? -1 : adir > bdir ? 1 : 0;
            }

            const afile = path.basename(a);
            const bfile = path.basename(b);

            return afile < bfile ? -1 : afile > bfile ? 1 : 0;
        });

        const diff = Object.keys(importFiles).filter(i => importFiles[i] !== sortedImportFiles[i]).map(Number);
        if (diff.length > 0) {
            const actual = importFiles.filter((_, i) => diff.includes(i)).join(',')
            const expected = sortedImportFiles.filter((_, i) => diff.includes(i)).join(',');

            console.log(`${source}: Incorrect order: "${actual}" should be "${expected}"`);
            continue;
        }
    }
};

await main();
