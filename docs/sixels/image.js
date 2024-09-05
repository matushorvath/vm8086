import sharp from 'sharp';
import rgbquant from 'rgbquant';
import 'promise.withresolvers/auto';
import fs from 'node:fs/promises';
import path from 'node:path';

const keypress = async () => {
    const { resolve, _reject, promise } = Promise.withResolvers();

    process.stdin.setRawMode(true);
    process.stdin.once('data', () => {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        resolve();
    });

    return promise;
};

const saveCursor = () => process.stdout.write('\x1b7');
const restoreCursor = () => process.stdout.write('\x1b8');
const clearDisplay = () => process.stdout.write('\x1b[2J');

const alternateBuffer = () => process.stdout.write('\x1b[?47h');
const normalBuffer = () => process.stdout.write('\x1b[?47l');

const hideCursor = () => process.stdout.write('\x1b[?25l');
const showCursor = () => process.stdout.write('\x1b[?25h');

class Frame {
    constructor(cols, rows, data) {
        this.cols = cols;
        this.rows = rows;
        this.data = data;
    }

    display() {
        const palette = this.preparePalette();
        console.log(palette);

        // TODO handle images with height not divisible by 6
        // const rowsDiv6 = Math.ceil(this.rows / 6);

        // TODO POC for setPixel based image display - iterate over the real image pixel, setpixel each of them

        // for (let r6 = 0; r6 < rowsDiv6; r6++) {
        //     for (let c = 0; c < this.cols; c++) {
        //         const pixels = this.getSixPixels(c, r6);
        //         const { char, foreground, background } = this.getBlockChar(pixels);

        //         setCursor(r + 1, c + 1);

        //         setForeground(foreground.r, foreground.g, foreground.b);
        //         setBackground(background.r, background.g, background.b);

        //         process.stdout.write(char);

        //         resetColor();
        //     }
        // }
    }

    preparePalette() {
        const palette = {};

        for (let r = 0; r < this.rows; r++) {
            for (let c = 0; c < this.cols; c++) {
                const p = this.getPixel(c, r);
                const key = `${p.r},${p.g},${p.b}`;

                palette[key] = p;
            }
        }

        return Object.values(palette);
    }

    getPixel(c, r) {
        const index = 3 * (r * this.cols + c);
        return { r: this.data[index + 0] ?? 0, g: this.data[index + 1] ?? 0, b: this.data[index + 2] ?? 0 };
    }

    getSixPixels(c, r6) {
        return [...Array(10).keys()].map(i => this.getPixel(c, r6 * 6 + i));
    }

    // setPixel = (c, r, color) => {
    //     process.stdout.write('\x1bP0;1;0q'); // enter sixel mode

    //     // TODO prepare the palette before, to cover all colors used by the image

    //     process.stdout.write('#0;2;0;0;0'); // set palette
    //     process.stdout.write('#1;2;100;0;0'); // set palette
    //     process.stdout.write('#2;2;0;100;0'); // set palette
    //     process.stdout.write('#3;2;0;0;100'); // set palette

    //     const row = Math.floor(r / 6);
    //     const pxl = r % 6;

    //     for (let i = 0; i < row; i++) {
    //         process.stdout.write('-');
    //     }

    //     for (let i = 0; i < 4; i++) {
    //         process.stdout.write(`#${i}!${c}?`); // color i, skip x columns

    //         if (i === color) {
    //             process.stdout.write(String.fromCharCode(63 + (1 << pxl)));
    //         } else {
    //             process.stdout.write(String.fromCharCode(63 + ~(1 << pxl)));
    //         }

    //         process.stdout.write('$');
    //     }

    //     process.stdout.write('-');

    //     process.stdout.write('\x1b\\'); // exit sixel mode
    // }
}

const main = async () => {
    const cols = 150, rows = 90;

    const filename = path.join(process.env.HOME, 'intcode/sammy.png');

    const image = await sharp(filename)
         .resize(cols, rows, { fit: 'inside' })
         .toColorspace('rgba');

    const { data, info } = await image.raw().toBuffer({ resolveWithObject: true });

    const q = new rgbquant();
    q.sample(data, cols);
    const data256 = q.reduce(data);

    //const image256 = await sharp({ input: data256, raw: info });
    //image256.toFile('delme.png');

    const frame = new Frame(info.width, info.height, data256);

    try {
        hideCursor();
        saveCursor();
        alternateBuffer();
        clearDisplay();

        process.stdout.write('\x1b[?80h'); // disable sixel scrolling

        frame.display();

        await keypress();
    } finally {
        normalBuffer();
        restoreCursor();
        showCursor();
    }
};

await main();
