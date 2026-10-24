#!/usr/bin/env bash
# Generic Yosys synthesis + structural checks. Fails on missing modules,
# multiple drivers, undriven nets, combinational loops or latches.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
mkdir -p build/synth
yosys -q -l build/synth/yosys.log -s scripts/synth.ys
grep -E "Number of cells|DFF" build/synth/stat.txt | sed -n 1,20p
echo "YOSYS: PASS (generic cells only; not SKY130 area or timing)"
