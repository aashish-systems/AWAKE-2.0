#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/power_characterization/execution_20261026_015400"
BASELINE="$ROOT/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline"
PDK="$ROOT/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
LIB="$PDK/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
VCD="$ROOT/docs/power_characterization/full_design/gatelevel_workload.vcd"

for input in "$LIB" \
  "$BASELINE/agrisense_ipms_top.odb" \
  "$BASELINE/agrisense_ipms_top.sdc" \
  "$BASELINE/agrisense_ipms_top.nom.spef" \
  "$VCD"; do
  if [[ ! -f "$input" ]]; then
    printf 'Required input is missing: %s\n' "$input" >&2
    exit 1
  fi
done

mkdir -p "$OUT/raw"

{
  printf 'Image: openroad/orfs:latest\n'
  docker image inspect openroad/orfs:latest \
    --format 'Image ID: {{.Id}}{{printf "\n"}}Repo digests: {{json .RepoDigests}}'
  docker run --rm --entrypoint /bin/bash openroad/orfs:latest -lc \
    'cd /OpenROAD-flow-scripts && source ./env.sh && openroad -version 2>&1 && sha256sum "$(command -v openroad)"'
} > "$OUT/runtime.txt"

windows=(
  "SLEEP_STABLE 125000 165000"
  "MONITOR_STABLE 225000 285000"
  "MONITOR_PRIMED 1405000 1545000"
  "CRITICAL 1945000 2105000"
  "WARNING 2185000 2445000"
  "MONITOR_RECOVERY 2565000 2705000"
)

for window in "${windows[@]}"; do
  read -r state begin end <<< "$window"
  tcl="$OUT/raw/${state}.tcl"
  log="$OUT/raw/${state}.log"

  cat > "$tcl" <<EOF
set pdk "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
set baseline "/workspace/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline"
set vcd "/workspace/docs/power_characterization/full_design/gatelevel_workload.vcd"

read_liberty "\$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "\$baseline/agrisense_ipms_top.odb"
read_sdc "\$baseline/agrisense_ipms_top.sdc"
read_spef "\$baseline/agrisense_ipms_top.nom.spef"

puts "=== WINDOW $state ${begin}-${end} ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time $begin -end_time $end "\$vcd"
report_activity_annotation -report_unannotated
report_power -digits 12
exit
EOF

  docker run --rm \
    -v "$ROOT:/workspace" \
    -w /workspace \
    --entrypoint /bin/bash \
    openroad/orfs:latest \
    -lc "cd /OpenROAD-flow-scripts && source ./env.sh && openroad -no_init -exit /workspace/docs/power_characterization/execution_20261026_015400/raw/${state}.tcl" \
    > "$log" 2>&1
done

python3 "$OUT/extract_results.py" --root "$ROOT" --out "$OUT"
