#!/usr/bin/env bash
# Verilator -Wall lint of the synthesizable top. Any warning fails.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
VERILATOR=$(command -v verilator_bin || command -v verilator)
"$VERILATOR" --lint-only -Wall -Irtl/common --top-module agrisense_ipms_top $(find rtl -name '*.v' | sort)
echo "VERILATOR LINT: PASS (0 warnings)"
