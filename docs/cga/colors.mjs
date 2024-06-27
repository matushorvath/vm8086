// ▀ ▄ █ ▌ ▐ ▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟

//const setColor = (f, b) => process.stdout.write(`\x1b[5;${fg16[f]};${bgl16[b]}m`);
//const setColorBlink = (f, b) => process.stdout.write(`\x1b[5;${fg16[f]};${bgl16[b]}m`);
//const setColor = (f, b) => process.stdout.write(`\x1b[38;5;${f}m\x1b[48;5;${b}m`);
const setColor = (f, b) => process.stdout.write(`\x1b[38;2;${c24[f].map(x => x.toString()).join(';')};48;2;${c24[b].map(x => x.toString()).join(';')}m`);
const setColorBlink = (f, b) => process.stdout.write(`\x1b[5;38;2;${c24[f].map(x => x.toString()).join(';')};48;2;${c24[b].map(x => x.toString()).join(';')}m`);
const resetColor = () => process.stdout.write('\x1b[0m');

const fg16 = [
    30,                              // Black
    34,                              // Blue
    32,                              // Green
    36,                              // Cyan
    31,                              // Red
    35,                              // Magenta
    33,                              // Brown
    37,                              // Light Gray
    90,                              // Dark Gray
    94,                              // Light Blue
    92,                              // Light Green
    96,                              // Light Cyan
    91,                              // Light Red
    95,                              // Light Magenta
    93,                              // Yellow
    97                               // White
];

const bgl16 = [
    49,                              // Black (49 for default color or 40 for explicitly black)
    44,                              // Blue
    42,                              // Green
    46,                              // Cyan
    41,                              // Red
    45,                              // Magenta
    43,                              // Brown
    47,                              // Light Gray
    100,                             // Dark Gray
    104,                             // Light Blue
    102,                             // Light Green
    106,                             // Light Cyan
    101,                             // Light Red
    105,                             // Light Magenta
    103,                             // Yellow
    107                              // White
];

const bgb16 = [
    49,                              // Black (49 for default color or 40 for explicitly black)
    44,                              // Blue
    42,                              // Green
    46,                              // Cyan
    41,                              // Red
    45,                              // Magenta
    43,                              // Brown
    47,                              // Light Gray
    49,                              // Black
    44,                              // Blue
    42,                              // Green
    46,                              // Cyan
    41,                              // Red
    45,                              // Magenta
    43,                              // Brown
    47                               // Light Gray
];

const c24 = [
    [  0,   0,   0],                 // Black
    [  0,   0, 170],                 // Blue
    [  0, 170,   0],                 // Green
    [  0, 170, 170],                 // Cyan
    [170,   0,   0],                 // Red
    [170,   0, 170],                 // Magenta
    [170,  85,   0],                 // Brown
    [170, 170, 170],                 // Light Gray
    [ 85,  85,  85],                 // Dark Gray
    [ 85,  85, 255],                 // Light Blue
    [ 85, 255,  85],                 // Light Green
    [ 85, 255, 255],                 // Light Cyan
    [255,  85,  85],                 // Light Red
    [255,  85, 255],                 // Light Magenta
    [255, 255,  85],                 // Yellow
    [255, 255, 255]                  // White
];

for (let f = 0; f < 16; f++) {
    setColor(f, 0);
    process.stdout.write('██');
}

resetColor();
process.stdout.write('\n');
process.stdout.write('\n');

for (let f = 0; f < 16; f++) {
    setColorBlink(f, 0);
    process.stdout.write('██');
}

resetColor();
process.stdout.write('\n');
process.stdout.write('\n');

for (let b = 0; b < 16; b++) {
    setColor(7, b);
    process.stdout.write('  ');
}

resetColor();
process.stdout.write('\n');
process.stdout.write('\n');
