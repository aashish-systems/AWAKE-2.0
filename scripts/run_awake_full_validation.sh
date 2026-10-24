#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Not inside a Git repository."
  exit 1
}
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/evidence_archive/full_validation_${STAMP}"
mkdir -p "$OUT"

REPORT="$OUT/master_workflow_report.md"
CLAIMS="$OUT/claim_evidence_matrix.csv"
FIGURES="$OUT/figure_inventory.csv"
POWER="$OUT/power_evidence_inventory.csv"
BASELINE="$OUT/baseline_evidence_inventory.csv"

printf '%s\n' \
  'claim,status,run_id,evidence_path,details' > "$CLAIMS"
printf '%s\n' \
  'path,extension,size_bytes,classification,status' > "$FIGURES"
printf '%s\n' \
  'run_id,metric,metric_value,evidence_path,status' > "$POWER"
printf '%s\n' \
  'path,classification,status,details' > "$BASELINE"

{
  echo "# AWAKE-2.0 Full Validation Report"
  echo
  echo "- Timestamp: $STAMP"
  echo "- Branch: $(git branch --show-current)"
  echo "- Starting HEAD: $(git rev-parse HEAD)"
  echo "- Remote: $(git remote get-url origin 2>/dev/null || echo unavailable)"
  echo "- Working tree was recorded before this script created its outputs."
  echo
  echo "## 1. Initial Git state"
  echo '```'
  git status --short
  echo '```'
  echo
  echo "## 2. Tool availability"
  for tool in python3 jq sha256sum git openlane openroad yosys iverilog verilator magic klayout netgen pdflatex latexmk; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf -- '- %s: %s\n' "$tool" "$(command -v "$tool")"
    else
      printf -- '- %s: unavailable\n' "$tool"
    fi
  done
  echo
  echo "## 3. Existing evidence documents"
  for f in \
    docs/evidence_archive/INVENTORY.md \
    docs/evidence_archive/artifact_manifest.csv \
    docs/evidence_archive/run_comparison.md \
    docs/evidence_archive/paper_claim_audit.md \
    docs/evidence_archive/signoff_claim_matrix.md \
    docs/evidence_archive/tool_versions.md \
    docs/reviews/awake_paper_815/remediation_tracker.md; do
    if [[ -f "$f" ]]; then
      echo "- FOUND: \`$f\`"
    else
      echo "- MISSING: \`$f\`"
    fi
  done
  echo
} > "$REPORT"

echo "[1/7] Auditing preserved OpenLane runs..."

for run in \
  RUN_2026-10-24_17-48-54 \
  RUN_2026-10-24_17-54-09 \
  RUN_2026-10-24_19-16-36; do

  dir="runs/$run"
  if [[ ! -d "$dir" ]]; then
    echo "$run missing" >> "$REPORT"
    continue
  fi

  {
    echo "### $run"
    echo
    echo "- Directory: \`$dir\`"
    echo "- Resolved configuration:"
    if [[ -f "$dir/resolved.json" ]]; then
      jq '{
        DESIGN_NAME,
        CLOCK_PERIOD,
        CLOCK_PORT,
        FP_CORE_UTIL,
        PL_TARGET_DENSITY_PCT
      }' "$dir/resolved.json" 2>/dev/null || true
    else
      echo "No resolved.json."
    fi

    echo
    echo "- Final metrics:"
    if [[ -f "$dir/final/metrics.json" ]]; then
      jq '{
        design__instance__count,
        design__instance__area,
        design__core__area,
        design__instance__utilization,
        timing__setup__ws,
        timing__setup__tns,
        timing__setup_vio__count,
        power__total,
        antenna__violating__nets,
        route__drc_errors,
        magic__drc_error__count,
        klayout__drc_error__count,
        design__lvs_error__count,
        design__lvs_device_difference__count,
        design__lvs_net_difference__count,
        design__lvs_property_fail__count
      }' "$dir/final/metrics.json" 2>/dev/null || true
    else
      echo "No final metrics.json; run may be incomplete."
    fi

    echo
    echo "- Final SDC clock constraints:"
    if [[ -d "$dir/final/sdc" ]]; then
      grep -RInE 'create_clock|set_clock_uncertainty|set_clock_latency' \
        "$dir/final/sdc" 2>/dev/null || true
    else
      echo "No final SDC directory."
    fi

    echo
    echo "- Signoff evidence files:"
    find "$dir" -type f \
      \( -iname '*antenna*' -o -iname '*drc*' -o -iname '*lvs*' \
         -o -iname '*sta*.rpt' -o -iname '*timing*.rpt' \
         -o -iname 'power.rpt' \) -print 2>/dev/null | sort

    echo
  } >> "$REPORT"

  if [[ -f "$dir/final/metrics.json" ]] && command -v jq >/dev/null 2>&1; then
    for metric in \
      timing__setup__ws \
      timing__setup__tns \
      timing__setup_vio__count \
      power__total \
      antenna__violating__nets \
      route__drc_errors \
      magic__drc_error__count \
      klayout__drc_error__count \
      design__lvs_error__count \
      design__instance__area \
      design__core__area \
      design__instance__utilization; do

      value="$(jq -r --arg k "$metric" \
        'if has($k) then .[$k] else "MISSING" end' \
        "$dir/final/metrics.json")"

      printf '"%s","%s","%s","%s","%s"\n' \
        "$metric" "reported" "$run" \
        "$dir/final/metrics.json" "$value" >> "$CLAIMS"

      case "$metric" in
        power__total)
          if [[ "$value" != MISSING && "$value" != null ]]; then
            printf '"%s","%s","%s","%s","%s"\n' \
              "$run" "$metric" "$value" \
              "$dir/final/metrics.json" \
              "Aggregate reported power in watts; not state-specific" \
              >> "$POWER"
          fi
          ;;
      esac
    done
  fi
done

echo "[2/7] Checking preserved archive hashes..."

if [[ -f docs/evidence_archive/artifact_manifest.csv ]]; then
  python3 - <<'PY' >> "$REPORT" 2>&1 || true
import csv
import hashlib
from pathlib import Path

manifest = Path("docs/evidence_archive/artifact_manifest.csv")
print("### Archive manifest integrity")
print(f"Manifest: {manifest}")
checked = missing = mismatch = skipped = 0

try:
    with manifest.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        print("Manifest columns:", reader.fieldnames)
        for row in reader:
            path_value = next(
                (row[k] for k in row if k and k.lower() in
                 ("path", "relative_path", "artifact_path", "file_path")
                 and row[k]), None
            )
            expected = next(
                (row[k] for k in row if k and "sha256" in k.lower()
                 and row[k]), None
            )
            if not path_value or not expected:
                skipped += 1
                continue
            p = Path(path_value)
            if not p.is_file():
                missing += 1
                continue
            digest = hashlib.sha256()
            with p.open("rb") as src:
                for chunk in iter(lambda: src.read(1024 * 1024), b""):
                    digest.update(chunk)
            checked += 1
            if digest.hexdigest().lower() != expected.strip().lower():
                mismatch += 1
except Exception as exc:
    print("Manifest format/read error:", repr(exc))
    raise

print(f"Hash checked: {checked}")
print(f"Missing files: {missing}")
print(f"Hash mismatches: {mismatch}")
print(f"Rows without recognized path/hash fields: {skipped}")
PY
else
  echo "No artifact manifest found; hash verification not performed." >> "$REPORT"
fi

echo "[3/7] Recording power-state evidence and limitations..."

cat >> "$REPORT" <<'EOF'

## 4. Per-state power and energy characterization

This script does not invent state-specific power. It inventories available aggregate power reports and relevant simulation/activity artifacts.

A state-specific result requires verified MONITOR, WARNING, and CRITICAL state occupancy, reproducible stimulus, and suitable activity-annotated power analysis. Aggregate `power__total` is not a substitute for state-specific power.

Required future outputs:
- `docs/power_characterization/methodology.md`
- `docs/power_characterization/state_power_results.csv`
- `docs/power_characterization/state_energy_results.csv`
- `docs/power_characterization/activity_provenance.md`

Until these measurements exist, state-specific power and energy remain UNVERIFIED.
EOF

find sim tb rtl runs results -type f 2>/dev/null \
  | grep -Ei '\.(vcd|fst|saif|v|sv|vhdl|vh|svh|rpt|json|csv)$' \
  | sort > "$OUT/power_related_file_list.txt" || true

echo "[4/7] Checking always-on baseline evidence..."

find . \
  -path './.git' -prune -o \
  -path './runs' -prune -o \
  -path './node_modules' -prune -o \
  -type f \( -iname '*baseline*' -o -iname '*always_on*' \
    -o -iname '*always-on*' -o -iname '*power*comparison*' \) \
  -print 2>/dev/null | sort > "$OUT/baseline_candidates.txt"

while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  printf '"%s","candidate","unverified","Requires same-flow and same-activity validation"\n' \
    "$path" >> "$BASELINE"
done < "$OUT/baseline_candidates.txt"

cat >> "$REPORT" <<'EOF'

## 5. Always-on baseline

Baseline candidate paths are listed in `baseline_candidates.txt`. The presence of a baseline file is not proof of a fair comparison.

A valid comparison requires the same technology/library corner, voltage, temperature, timing constraints, activity assumptions, measurement interval, and comparable functional workload.

No power savings should be claimed until the baseline and event-driven design have comparable, reproducible measurements.
EOF

echo "[5/7] Inventoring figure and manuscript evidence..."

find . \
  -path './.git' -prune -o \
  -path './runs' -prune -o \
  -path './node_modules' -prune -o \
  -type f \( \
    -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
    -o -iname '*.svg' -o -iname '*.pdf' -o -iname '*.eps' \
    -o -iname '*.tex' -o -iname '*.docx' -o -iname '*.pptx' \
    -o -iname '*.bib' -o -iname '*.drawio' -o -iname '*.mmd' \
  \) -print 2>/dev/null | sort > "$OUT/figure_source_candidates.txt"

while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  ext="${path##*.}"
  size="$(wc -c < "$path" | tr -d ' ')"
  case "${ext,,}" in
    png|jpg|jpeg|svg|eps) classification="figure_or_image" ;;
    pdf) classification="pdf_or_paper_needs_inspection" ;;
    tex|bib|docx) classification="manuscript_or_bibliography_candidate" ;;
    *) classification="diagram_or_presentation_source" ;;
  esac
  printf '"%s","%s","%s","%s","needs provenance review"\n' \
    "$path" "$ext" "$size" "$classification" >> "$FIGURES"
done < "$OUT/figure_source_candidates.txt"

cat >> "$REPORT" <<'EOF'

## 6. Figure and manuscript provenance

Candidate files are listed in `figure_source_candidates.txt` and `figure_inventory.csv`.

The inventory is not an assertion that every PDF is a manuscript or every image is a paper figure. Inspect the actual manuscript and determine figure-to-run provenance before changing captions.

Figures must not claim 116.15 MHz, zero antenna violations, measured state power, or baseline savings unless the relevant evidence proves those claims.
EOF

echo "[6/7] Creating a claim gate checklist..."

cat > "$OUT/next_actions.md" <<'EOF'
# AWAKE-2.0 Validation Gates

## Gate 1 — Evidence and signoff
- [ ] Reconcile each paper claim with raw reports.
- [ ] Confirm SDC and actual timing target for each run.
- [ ] Resolve 20 ns vs 8.61 ns / 116.15 MHz claim.
- [ ] Verify antenna, route DRC, Magic DRC, KLayout DRC, and LVS separately.
- [ ] Verify run provenance and source revision.

## Gate 2 — State power and energy
- [ ] Verify actual FSM state encodings and transitions.
- [ ] Produce reproducible MONITOR/WARNING/CRITICAL workloads.
- [ ] Generate activity traces.
- [ ] Run supported power analysis with documented corner and assumptions.
- [ ] Calculate energy and occupancy-weighted power only from validated inputs.

## Gate 3 — Always-on baseline
- [ ] Define a functionally comparable always-on design.
- [ ] Use the same library, corner, voltage, temperature, constraints, flow, and activity.
- [ ] Validate functional comparability.
- [ ] Report absolute power/energy and percentage changes.

## Gate 4 — Figures
- [ ] Map each figure to source data, run ID, and flow stage.
- [ ] Regenerate figures only from verified data.
- [ ] Replace placeholder and unsupported captions.
- [ ] Record missing provenance.

## Gate 5 — Paper
- [ ] Find the actual manuscript source and available reviewer feedback.
- [ ] Correct claims using the evidence matrix.
- [ ] Separate implemented hardware, models, abstractions, and future work.
- [ ] Address reviewer comments with evidence.
- [ ] Build and validate the final manuscript.

## Gate 6 — Git
- [ ] Review all changes and pre-existing edits.
- [ ] Stage only reviewed deliverables.
- [ ] Never force-push.
- [ ] Verify remote commit SHA after push.
- [ ] Treat ignored OpenLane artifacts as local until separately backed up.
EOF

echo "[7/7] Finalizing validation report..."

{
  echo
  echo "## 7. Generated audit outputs"
  echo "- Claim and metric inventory: \`$CLAIMS\`"
  echo "- Figure inventory: \`$FIGURES\`"
  echo "- Power evidence inventory: \`$POWER\`"
  echo "- Baseline evidence inventory: \`$BASELINE\`"
  echo "- Power-related files: \`$OUT/power_related_file_list.txt\`"
  echo "- Baseline candidates: \`$OUT/baseline_candidates.txt\`"
  echo "- Figure/manuscript candidates: \`$OUT/figure_source_candidates.txt\`"
  echo "- Gate checklist: \`$OUT/next_actions.md\`"
  echo
  echo "## 8. Validation status"
  echo
  echo "This script inventories and validates available evidence. It does not claim that state-specific power characterization, a fair always-on baseline, figure remediation, or manuscript revision has been experimentally completed."
  echo
  echo "## 9. Git state after audit"
  echo '```'
  git status --short
  echo '```'
  echo
  echo "- Ending HEAD: $(git rev-parse HEAD)"
  echo "- Remote push: not attempted by this script."
  echo
  echo "## 10. Required manual review"
  echo "Inspect every generated file and complete the phase gates in \`next_actions.md\` before claiming the project is camera-ready."
} >> "$REPORT"

git diff --check

echo
echo "============================================================"
echo "AWAKE FULL VALIDATION INVENTORY COMPLETE"
echo "============================================================"
echo "Report: $REPORT"
echo "Claim matrix: $CLAIMS"
echo "Figure inventory: $FIGURES"
echo "Power evidence inventory: $POWER"
echo "Baseline evidence inventory: $BASELINE"
echo "Next actions: $OUT/next_actions.md"
echo
echo "No RTL was intentionally modified."
echo "No OpenLane run directory was intentionally modified."
echo "No commit or push was attempted."
echo
echo "Review before staging:"
git status --short
