# AWAKE power evidence execution report

Execution date: 2026-10-26
Repository branch: `main`
Starting commit: `e954a3127a5becef1a82419c6844898f7c4035d8`

## Summary

The state-window measurement pipeline was repaired in a new, isolated
execution directory. Six gate-level activity windows were measured with
OpenROAD against the archived SKY130 physical design. The VCD clock and
state/control values were checked directly, the windows were shifted away
from clock-edge timestamps to address OpenROAD's clipped-window period
warning, and a SLEEP measurement was repeated exactly.

The results are **provisional activity-annotated power estimates**. They are
not silicon measurements, not a field-duty-cycle characterization, and not a
matched always-on comparison. No RTL, production flow configuration,
archived implementation file, or paper source was modified.

## Validated numerical findings

The current gate-level VCD has a 1 ps timescale, lasts 2.84 us, and contains
142 rising edges with all 141 periods equal to 20 ns. This matches the
archived 20 ns SDC clock. For each of the six new OpenROAD reports:

- VCD scope: `tb_gatelevel_vcd/uut`
- Annotated pin activities: 26,395
- Unannotated pins: 0
- OpenROAD warnings: 0
- State and enable values: stable and verified for the full selected interval
- Corner: SKY130A `sky130_fd_sc_hd`, TT, 25 C, 1.8 V

The power values below are **provisional OpenROAD estimates in mW**, not
measured power. Leakage is reported in mW for readability; the CSV stores
watts.

| State window | Interval (ps) | State | D2/D3/comm | Internal | Switching | Leakage | Clock | Total |
|---|---:|:---:|:---:|---:|---:|---:|---:|---:|
| SLEEP_STABLE | 125000-165000 | `00` | 0/0/0 | 2.080859 | 0.746549 | 0.00004965 | 1.403011 | 2.827457 |
| MONITOR_STABLE | 225000-285000 | `01` | 0/0/0 | 2.080587 | 0.746450 | 0.00004963 | 1.403011 | 2.827087 |
| MONITOR_PRIMED | 1405000-1545000 | `01` | 0/0/0 | 2.156220 | 0.883615 | 0.00004925 | 1.403011 | 3.039884 |
| CRITICAL | 1945000-2105000 | `11` | 1/1/1 | 2.082431 | 0.747063 | 0.00004912 | 1.403011 | 2.829543 |
| WARNING | 2185000-2445000 | `10` | 1/0/0 | 2.122444 | 0.820863 | 0.00004919 | 1.403011 | 2.943357 |
| MONITOR_RECOVERY | 2565000-2705000 | `01` | 0/0/0 | 2.081661 | 0.746682 | 0.00004923 | 1.403011 | 2.828392 |

These intervals have different durations and switching histories. They are
not suitable for occupancy weighting or general claims about an operating
state. No energy values were calculated because the power estimates remain
provisional and the selected testbench windows are not deployment dwell
times.

The SLEEP window was repeated with the same TCL and inputs. Internal,
switching, leakage, and total power were identical to all reported digits;
see `repeat/repeatability.txt`.

## VCD clock-period warning investigation

The VCD's explicit clock transitions establish a 20 ns period, and the SDC
also sets 20 ns. Existing clipped-window runs reported apparent periods of
16.000 ns and 17.143/17.778 ns. A new experiment shifted window bounds
5,000 ps off transition timestamps while preserving each window's full-cycle
duration. All six new runs then reported no clock-period warning. This
supports the conclusion that the previous warning was caused by VCD
window-boundary period inference, not by a 16 ns simulated clock. The exact
window TCL and raw output are preserved under `raw/`.

## State-window audit

Several previous windows did not correspond wholly to their labels:

- `MONITOR_STABLE` (200000-280000 ps) included SLEEP through 210000 ps.
- `MONITOR_PRIMED` (1400000-1600000 ps) entered WARNING at 1550000 ps.
- `CRITICAL` (2100000-2300000 ps) entered WARNING at 2150000 ps.
- `WARNING` (2380000-2540000 ps) crossed into MONITOR, back to WARNING, then
  into MONITOR.

The previous `MONITOR_RECOVERY` window was wholly MONITOR. The new ranges in
`state_power_results.csv` were selected from the actual VCD transitions and
checked for constant state, `domain2_pwr_en`, `domain3_pwr_en`, and
`comm_en_out` over each interval.

## Reviewer concern A — Per-state duty-cycled power

**Partially resolved.** The repository now has repeatable, state-verified,
fully annotated, gate-level OpenROAD window estimates for all six requested
windows. The rows remain `PROVISIONAL` because the VCD's hashed source
netlist is not retained for independent ODB-to-netlist identity checking,
and the workload is directed rather than representative. These estimates
do not establish deployment duty cycle, energy per state, or power savings.

The RTL shows that `domain2_pwr_en` gates CSA capture and the CSA sequential
enable; the power controller also isolates the CSA stress and leaf outputs
when Domain 2 is disabled. The enabled signal is not evidence of a physical
supply switch. Clock power remains reported in all states.

## Reviewer concern B — Matched always-on baseline

**Blocked; no valid always-on baseline was measured.** A constant-high
`domain2_pwr_en` would alter CSA capture/enable behavior and disable boundary
isolation, changing observable/latent behavior. An always-on variant needs
an explicitly agreed functional definition and same-workload equivalence
test before synthesis or power comparison.

The archived CSA baseline/candidate reports address operand isolation, not
the system's state-managed versus always-on behavior. Their archive hashes
verify, but the expected hash for the current isolated candidate RTL does
not match (`ec2ba73c...` expected versus `c18c1961...` current), as also
documented in `../csa_isolation/source_provenance_note.md`. That candidate
also has one archived max-capacitance violation. The archived pair is
therefore not used for a system-level always-on comparison.

`baseline_comparison.csv` contains column headers only; no unavailable
measurement rows or fabricated zeroes were added. No area, timing, energy,
or relative power improvement is asserted for a matched pair.

## Historical evidence reconciliation

- The earlier 10.442319 mW and 10.345010 mW nominal reports are archived
  CSA-isolation baseline/candidate estimates at TT/25 C/1.8 V. They were not
  generated from this state-window workload; they do not establish an
  always-on comparison. The candidate source provenance mismatch and
  max-capacitance check further limit their applicability.
- The earlier 2.943301 mW figure is a full-workload report. It is not
  interchangeable with any state-window report or a baseline measurement.
- Earlier 2.8-3.0 mW state-window outputs included windows that crossed FSM
  transitions and/or generated clipped-window clock warnings. The fresh
  results use new state-verified intervals and are kept separately rather
  than averaged with historical values.
- CSA product-bus transition counts (1098 versus 0 while disabled) are
  microbenchmark switching counts, not whole-chip power.

## Paper status

No LaTeX, bibliography, or PDF manuscript was found in the repository. The
untracked `FINAL_RESULTS.zip` also contains no `.tex`, `.bib`, or `.pdf`
entry. No manuscript claims were changed and no PDF was compiled. The paper
must not be updated with the provisional measurements as validated results.

## Tools and commands

- Power measurement and extraction:
  `bash docs/power_characterization/execution_20261026_015400/run_state_windows.sh`
- OpenROAD container: `openroad/orfs:latest`, pinned image digest and binary
  SHA-256 in `runtime.txt`. `openroad -version` reports `unknown` in this
  container.
- VCD validation and log extraction:
  `extract_results.py`, called by the measurement runner.
- Archive integrity:
  `sha256sum -c docs/power_characterization/csa_isolation/evidence_archive_20261025/SHA256SUMS.txt`
  passed for all archived baseline and candidate evidence.
- The archived candidate source manifest check fails for its top-level RTL
  file, confirming the documented source hash mismatch. The current wrapper
  hash matches.
- The prior requested image tag `openroad/orfs:lat` is not available; the
  already-present `openroad/orfs:latest` image was used and its content
  digest recorded.

## Deliverables and remaining blockers

Artifacts in this directory:

- `methodology.md`
- `execution_report.md`
- `state_power_results.csv`
- `baseline_comparison.csv` (header only; comparison unavailable)
- `run_state_windows.sh`
- `extract_results.py`
- `raw/` (one generated TCL and complete OpenROAD log per window)
- `repeat/` (repeat SLEEP TCL/log and exact-repeat check)
- `runtime.txt`
- `vcd_validation.txt`
- `artifact_manifest.sha256`

To complete the comparison and paper update:

1. Recover or regenerate the exact gate-level netlist for the archived ODB
   and verify its hash against the simulation manifest.
2. Define an always-on behavior that preserves the required observable
   outputs, sample processing, and latency; implement it in a separate
   experimental variant only after that definition is accepted.
3. Run same-stimulus functional equivalence and both variants through the
   same synthesis/physical flow, constraints, library corner, and activity
   analysis. Preserve both source revisions and raw outputs.
4. Obtain representative workload dwell-time data before calculating
   workload-weighted average power or energy.
5. Provide the current LaTeX manuscript source before making paper edits.

No commit or push was made. Pre-existing worktree changes were left intact.
