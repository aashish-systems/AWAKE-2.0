#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Run this script from inside the repository."
  exit 1
}
cd "$ROOT"

if ! command -v iverilog >/dev/null 2>&1 || ! command -v vvp >/dev/null 2>&1; then
  echo "ERROR: Icarus Verilog (iverilog and vvp) is required."
  exit 1
fi

mkdir -p build/power_characterization sim/power_characterization
iverilog -g2012 -I rtl/common \
  -s tb_ipm_state_workload \
  -o build/power_characterization/tb_ipm_state_workload.vvp \
  rtl/ipm/ipm_fsm.v tb/tb_ipm_state_workload.sv

vvp -n build/power_characterization/tb_ipm_state_workload.vvp \
  | tee build/power_characterization/simulation.log

python3 sim/scripts/analyze_ipm_state_trace.py
