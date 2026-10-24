# Phase 1 workflow report — evidence audit and signoff reconciliation

Execution date: 2026-10-24

Repository: `/workspaces/AWAKE-2.0`

Branch: `main`

## Starting Git state

- Starting HEAD: `c830aed944b8e821e1f37321656bfac4ca4c9b53`
- `origin/main`: `c830aed944b8e821e1f37321656bfac4ca4c9b53` (same commit at
  preflight)
- Remote: `origin https://github.com/aashish-systems/AWAKE-2.0` (fetch/push)
- Recent commits at preflight:
  - `c830aed Record archive push status`
  - `d64759b Archive AWAKE paper evidence and reviewer remediation`
  - `0e9b806 Save AWAKE-2.0 physical design evidence checkpoint`
  - `e309cf8 Fix RTL and establish reproducible verification baseline`
- The existing local commits were preserved. No push was attempted in this
  phase.
- Disk at preflight: 32 GB filesystem, 22 GB used, 8.0 GB available.

Files reported dirty or untracked at preflight:

```text
 M docs/evidence_archive/INVENTORY.md
 M docs/evidence_archive/archive_log.md
 M docs/evidence_archive/paper_claim_audit.md
 M docs/evidence_archive/run_comparison.md
 M docs/evidence_archive/tool_versions.md
 M flow/config.json
 M rtl/csa/crop_stress_accelerator.v
?? docs/evidence_archive/full_validation_20261024_204134/
?? docs/evidence_archive/signoff_claim_matrix.md
?? flow/config.json.bak
?? scripts/run_awake_full_validation.sh
```

The flow config, RTL, backup config, validation script, and existing
full-validation artifacts were inspected as pre-existing work and left
unchanged by this Phase 1 audit. In this task, only the Phase 1 evidence
documentation files listed below were created.

## Tool availability at preflight

| Tool | Observed version / status |
|---|---|
| Git | 2.55.0 |
| Python | 3.14.2 |
| Yosys | 0.33 (`2584903a060`) |
| Verilator | 5.020 (2024-01-01) |
| Icarus Verilog | 12.0 (stable) |
| OpenLane | unavailable |
| OpenROAD | unavailable |
| Magic | unavailable |
| KLayout | unavailable |
| Netgen | unavailable |
| `pdflatex` / `latexmk` | unavailable |

The unavailable EDA tools were not invoked. This workflow reads preserved
reports only; no physical-design run was attempted. Tool versions currently
installed in the workspace must not be attributed to historical run
execution.

## Phase 1 work and result

Reviewed raw resolved configurations, final SDCs, final metric JSON, STA
reports, corner power reports, run-stage outputs, Magic/KLayout DRC reports,
Netgen LVS reports, antenna reports, source manifests, and available
repository manuscript/reviewer files.

Key reconciliations:

- The `17-48-54` run ends at synthesis and is not a physical signoff run.
- The `17-54-09` and `19-16-36` runs have complete physical-flow outputs and
  final signoff reports, but their source commit and historical paper-run
  identity are not recorded.
- Both completed-run final SDCs constrain 20 ns (50 MHz). The 8.615015 ns
  value in a `19-16-36` STA report is one input-to-register data-arrival
  value, not a clock period or demonstrated 8.61 ns timing target.
- The completed runs report different setup results; do not combine their
  timing or area/power values.
- Both report zero route, Magic, and KLayout DRC counts and uniquely matching
  Netgen circuits. Their later antenna checks retain 4 and 11 violating nets.
- Max-FF power values are aggregate report estimates (units are W in raw
  reports); no archived VCD/FST/SAIF or state workload supports per-state
  power or energy claims.
- No manuscript source was found to establish which run is the historical
  paper run. The 8.61 ns/116.15 MHz claim is unsupported by the preserved
  timing constraints and reports.

Deliverables:

- [evidence_audit.md](evidence_audit.md)
- [claim_evidence_matrix.csv](claim_evidence_matrix.csv)
- [signoff_reconciliation.md](signoff_reconciliation.md)

## Validation and phase gate

- All raw evidence paths cited in the new matrix were checked for existence.
- CSV structure/status values and Markdown references were checked.
- `git diff --check` passed.
- No RTL, flow configuration, raw run, or report was modified.
- Phase 1 reconciliation is complete with the provenance limitations above.
  The gate does not support state-specific or comparative power claims from
  these reports. Phase 2 experiments were not started in this phase.
