#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT_REL="docs/power_characterization/execution_20261026_015400"
OUT="$ROOT/$OUT_REL"

inputs=(
  docs/power_characterization/full_design/gatelevel_workload.vcd
  docs/power_characterization/full_design/tb_gatelevel_vcd.v
  docs/power_characterization/full_design/gatelevel_functional_simulation.log
  docs/power_characterization/full_design/gatelevel_functional_hashes.sha256
  docs/power_characterization/csa_isolation/evidence_archive_20261025/SHA256SUMS.txt
  docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.odb
  docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.sdc
  docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.nom.spef
  docs/power_characterization/csa_isolation/source_provenance_note.md
  build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
)

mapfile -t outputs < <(
  cd "$ROOT"
  find "$OUT_REL" -type f ! -name artifact_manifest.sha256 -print | sort
)

{
  cd "$ROOT"
  sha256sum "${inputs[@]}" "${outputs[@]}"
} > "$OUT/artifact_manifest.sha256"
