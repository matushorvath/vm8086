#!/bin/sh

# Take 6502 assembly from stdin, assemble and link it, write the binary to stdout

set -e

scriptdir="$(cd "$(dirname "$0")"; pwd)"

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT

cat > "$tmpdir/tmp.s"
ca65 "$tmpdir/tmp.s" -o "$tmpdir/tmp.o"
ld65 -C "$scriptdir/ld65.cfg" "$tmpdir/tmp.o" -o "$tmpdir/tmp.bin"
cat "$tmpdir/tmp.bin"
