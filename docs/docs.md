- AI disclaimer
  - I designed, wrote, tested the SW. Created before AI coding was really a thing. No AI used in creation of this software at all.
  - Docs, yes I used AI. I finished the SW a long time ago and could not make myself write the docs. In the end decided it's better to have AI assisted docs than no docs at all. All information in this document was carefully reviewed and edited by a human and is correct. I took significant time to do the reviews to make sure it is not another piece of AI slop.
  - I sign off on this document and the information inside, it is as good as I could have written or better.

- history
  - How SW was written with just the computer, no tools, no compiler. Reflections on Trusting Trust.
  - Always wanted to try that, and IntCode was an opportunity.
  - What are the rules - Write as much as possible in intcode, even dev tools. Even generate code with IC. Makefile is OK. Don't be too dogmatic though.
  - Tools outside the build pipeline are fine in whatever - e.g. test infra in js.

- dev tools
  - xzintbit, written first
  - have some details here, rest link to xzintbit repo

- vm8086 architecture
  - diagram, link to individual library directories/directories within a library
  - in general, CPU is complete, but some devices only support what was required to run software
    - PC hardware has features that are not used in practice
    - if PC clones made similar tradeoffs, I get why compatibility in PC world was sometimes problematic

- CPU
  - CPU is the big thing, obviously
  - 8086/8088
  - Testing infra
    - bochs + nasm
    - test data, give credit, it's so good bios actually detects that CPU
  - give details on more interesting parts
    - general instruction loop, how does it work, what does it do, how does it integrate with devices
      - because of single thread, we need to process devices and instructions at the same time
    - instructions that use generated tables, that do stuff not supported by IC
    - memory handling, segment calculation
      - very frequent, very performance relevant, needs to do bit manipulation which is hard for IC
    - CPU state, how it's stored
    - logging, tracing infra

- CGA

- Devices
  - list what we have
  - DMA for floppy
  - PIC
  - keyboard
    - terminal -> scancode translation
  - timer
    - limitations - see sources
    - DRAM refresh we ignore, no channel 1 - AT and later didn't do this anyway
    - speaker displays an icon on terminal when sound - channel 2
    - timer is a source of slowdowns if not done carefully
      - see comment in dev/pit_8253_common.si about lower frequency of PIT pulses
  - 8255A Programmable Peripheral Interface
    - keyboard IO, speaker + various device control bits
    - limited functionality, pretty much hardcoded for PC devices
  - 8042 PS/2 Controller
    - not actually part of a real PC
    - just used as an API, to cleanly shut down the VM (when 8042 resets the CPU)

- Floppy Controller
  - read/write floppy images stored in IC memory
    - give more detail on images here, how it works
    - build system, how do images get converted to IC objects that get linked into the VM
    - image "compression" written in IC
    - talk about software
      - talk about licenses with abandonware
  - state machine, complex but actually nice to emulate

- testing
  - assembler tests
  - bochs validation of assembler tests
  - 8088 test data

- code generation
  - util directory, explain how it works and why it exists
  - IC memory is cheap (actually infinite)
  - IC execution is expensive, especially when doing bit manipulation and similar things IC does not directly support
  - create tables at compile time - pay some memory to get back performance
  - bit access, parity, bit shifts
  - division by 80 for CGA
  - modulo 9 and modulo 17 for RCL/RCR instructions

- VM bootup code in vm directory

- Give credit to projects used
  - bochs, nasm
  - test data for 8088
  - bios
  - PC software
  - ... make sure I get all of it
