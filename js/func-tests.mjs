import { Vm6502 } from './vm6502.mjs';
import chalk from 'chalk';

const binUrl = 'https://github.com/Klaus2m5/6502_65C02_functional_tests/raw/master/bin_files/6502_functional_test.bin';
const lstUrl = 'https://github.com/Klaus2m5/6502_65C02_functional_tests/blob/master/bin_files/6502_functional_test.lst';

// How to detect success:
// Tests are successful when they get to the line
// 3469 : 4c6934          >        jmp *           ;test passed, no errors
// The address can change, so we will depend on the comment being more stable.
//
// Algorithm:
// - download 6502_functional_test.lst
// - search for 'jmp *    ;test passed, no errors'
// - get the address of the instruction
// - replace the instruction with 0x02 to trigger a halt of VM6502
// - assume that tests failed if they never finish

const getFunctionalTestBin = async () => {
    const response = await fetch(binUrl);
    const bin = await response.blob();
    const arr = await bin.arrayBuffer();
    return [...new Uint8Array(arr)];
};

const getAddresses = async () => {
    const response = await fetch(lstUrl);
    const lst = await response.text();

    const startMatch = lst.match(/Program start address is at \$([\da-f]{4})/);
    if (!startMatch) {
        throw new Error('could not determine start address');
    }

    const successMatch = lst.match(/([\da-f]{4}) : 4c[\da-f]{4}\s+>\s+jmp \*\s+;test passed, no errors/);
    if (!successMatch) {
        throw new Error('could not determine success address');
    }

    return [
        Number.parseInt(startMatch[1], 16),
        Number.parseInt(successMatch[1], 16)
    ];
};

const f16 = n => '0x' + n.toString(16).padStart(4, '0');

const main = async () => {
    const image = await getFunctionalTestBin();
    console.log(`Functional test binary downloaded, length ${image.length}`);

    const [startAddress, successAddress] = await getAddresses();
    console.log(`Start address: ${f16(startAddress)}`);
    console.log(`Success address: ${f16(successAddress)}`);

    // Make the VM halt on success or on a tight endless loop
    let prevPc;
    const callback = (vm) => {
        if (vm.pc === successAddress || vm.pc === prevPc) {
            return false;
        }

        prevPc = vm.pc;
        return true;
    };

    const vm = new Vm6502(image);

    vm.pc = startAddress;
    vm.callback = callback;

    console.log('Running test; if this freezes, the test has failed');
    vm.run();

    const status = vm.pc === successAddress ? chalk.green('PASSED') : `${chalk.red('FAILED')} (${f16(vm.pc)})`;
    console.log(`Functional test ${status}`);
};

await main();
