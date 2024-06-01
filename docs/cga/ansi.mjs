import sharp from 'sharp';
import 'promise.withresolvers/auto';

const keypress = async () => {
    const { resolve, _reject, promise } = Promise.withResolvers();

    process.stdin.setRawMode(true);
    process.stdin.once('data', key => {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        resolve();
    });

    return promise;
};

// ▀ ▄ █ ▌ ▐ ▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟

const saveCursor = () => process.stdout.write('\x1b7');
const restoreCursor = () => process.stdout.write('\x1b8');
const setCursor = (row, col) => process.stdout.write(`\x1b[${row};${col}H`);
const clearDisplay = () => process.stdout.write('\x1b[2J');

const alternateBuffer = () => process.stdout.write('\x1b[?47h');
const normalBuffer = () => process.stdout.write('\x1b[?47l');

const insertMode = () => process.stdout.write('\x1b[4h');
const replaceMode = () => process.stdout.write('\x1b[4l');

const autoNewline = () => process.stdout.write('\x1b[20h');
const normalNewline = () => process.stdout.write('\x1b[20l');

const hideCursor = () => process.stdout.write('\x1b[?25l');
const showCursor = () => process.stdout.write('\x1b[?25h');

const setForeground = (r, g, b) => process.stdout.write(`\x1b[38;2;${r};${g};${b}m`);
const setBackground = (r, g, b) => process.stdout.write(`\x1b[48;2;${r};${g};${b}m`);
const resetColor = () => process.stdout.write('\x1b[0m');

class Frame {
    constructor(cols, rows, data) {
        this.cols = cols;
        this.rows = rows;
        this.data = data;
    }

    static CBL = 1;
    static RBL = 2;

    display() {
        // TODO handle images with size not divisible by CBL, RBL
        const cblocks = Math.ceil(this.cols / Frame.CBL);
        const rblocks = Math.ceil(this.rows / Frame.RBL);

        for (let r = 0; r < rblocks; r++) {
            for (let c = 0; c < cblocks; c++) {
                const pixels = this.getBlockPixels(c, r);
                const { char, foreground, background } = this.getBlockChar(pixels);

                setCursor(r + 1, c + 1);

                setForeground(foreground.r, foreground.g, foreground.b);
                setBackground(background.r, background.g, background.b);

                process.stdout.write(char);

                resetColor();
            }
        }
    }

    calcIndex(bc, br, dc, dr) {
        return 3 * ((br * Frame.RBL + dr) * this.cols + (bc * Frame.CBL + dc));
    }

    getPixel(bc, br, dc, dr) {
        const index = this.calcIndex(bc, br, dc, dr);
        return { r: this.data[index + 0] ?? 0, g: this.data[index + 1] ?? 0, b: this.data[index + 2] ?? 0 };
    }

    getBlockPixels(c, r) {
        return [this.getPixel(c, r, 0, 0), this.getPixel(c, r, 0, 1)];
    }

    getBlockChar(pixels) {
        // TODO determine colors, use the correct character
        return {
            char: '▀',
            foreground: pixels[0],
            background: pixels[1]
        };
    }
}

const main = async () => {
    const cols = 120, rows = 80;

    const image = await sharp('sammy.png')
        .resize(cols, rows, { fit: 'inside' })
        .toColorspace('srgb');
    //await image.toFile('delme.png');
    const buffer = await image.raw().toBuffer({ resolveWithObject: true });

    const frame = new Frame(buffer.info.width, buffer.info.height, buffer.data);

    hideCursor();
    saveCursor();
    alternateBuffer();
    clearDisplay();

    frame.display();

    await keypress();

    normalBuffer();
    restoreCursor();
    showCursor();
};

await main();
