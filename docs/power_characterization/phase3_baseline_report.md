# Phase 3 execution report — always-on baseline comparison

Execution date: 2026-10-24

Repository: `/workspaces/AWAKE-2.0`

Branch: `main`

## Outcome

**Gate blocked; no valid always-on baseline or comparative power/area result
is available.** The preserved archive contains two completed physical runs,
but neither is identified as an always-on implementation. Their aggregate
power values are not comparable to the directed FSM-only Phase 2 trace or to
each other as baseline-versus-managed measurements. No percentage change,
energy delta, or power-saving claim is calculated.

Phase 3 was limited to evidence reconciliation and baseline readiness. No RTL,
flow configuration, preserved run directory, or raw report was changed.

## Preserved-run evidence

| Run | Physical result | Archived conditions | Aggregate max-FF power | Baseline disposition |
|---|---|---|---:|---|
| `RUN_2026-10-24_17-54-09` | Completed physical flow | `sky130A`, `sky130_fd_sc_hd`, 20 ns clock; final max-FF report at `max_ff_n40C_1v95` | 0.013314031064510345 W | Not identified as always-on; source revision and activity provenance are absent |
| `RUN_2026-10-24_19-16-36` | Completed physical flow | `sky130A`, `sky130_fd_sc_hd`, 20 ns clock; final max-FF report at `max_ff_n40C_1v95` | 0.012208886444568634 W | Not identified as always-on; source revision and activity provenance are absent |
| `RUN_2026-10-24_17-48-54` | Synthesis-only | 20 ns configured clock; no completed physical flow | Unavailable | Not eligible for a physical power or area comparison |

The two completed-run metrics and configurations are recorded in
[`runs/RUN_2026-10-24_17-54-09/final/metrics.json`](../../runs/RUN_2026-10-24_17-54-09/final/metrics.json),
[`runs/RUN_2026-10-24_19-16-36/final/metrics.json`](../../runs/RUN_2026-10-24_19-16-36/final/metrics.json),
and their respective `resolved.json` files. Their final instance areas are
71,217.1 µm² and 71,996.6 µm², respectively. These distinct run outputs are
not evidence of an always-on versus managed comparison: neither run has a
recorded source commit, an identified baseline variant, or an archived
VCD/FST/SAIF activity trace. The aggregate power reports also do not document
a common workload, activity source, or measurement window.

The max-FF values are report estimates at the report's -40 °C, 1.95 V corner.
They are not re-labeled as nominal 1.8 V power, measured power, state power,
or energy. The raw report paths are
[`runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt`](../../runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt)
and
[`runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt`](../../runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt).

## Candidate audit

| Candidate path | Finding | Why it is not a baseline |
|---|---|---|
| `build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/combined/test/baseline_results.txt` | Library test data; sampled entries name `sky130_fd_pr__*` cells and capacitances | It is PDK/library collateral, not a synthesized or placed AWAKE design |
| `build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130B/libs.tech/combined/test/baseline_results.txt` | Same library-test-data form as the sky130A candidate | Wrong evidence type and no AWAKE design, workload, or flow metrics |
| `sim/traces/baseline_diurnal.csv` | Input stimulus trace | A workload file does not define an always-on hardware implementation or provide power results |
| `docs/evidence_archive/full_validation_20261024_204134/baseline_candidates.txt` and `baseline_evidence_inventory.csv` | Candidate indexes | Inventories identify paths for review; they do not establish a baseline run |
| `sim/power_characterization/state_trace.csv` and `build/power_characterization/ipm_state_workload.vcd` | Directed FSM-only Phase 2 activity | The trace is synthetic and covers the controller/testbench only; it does not model equivalent whole-design work or provide annotated full-design activity |

## Comparability and implementation gate

The workflow requires matching implementation conditions, activity, and
functionality. The current evidence does not meet those requirements:

1. **No baseline implementation is identified.** Archived run metadata
   identifies the design and flow conditions but not an always-on variant or
   a source revision that would establish the variant.
2. **Functional equivalence cannot be assumed by forcing the power enables
   high.** In
   [`rtl/top/agrisense_ipms_top.v`](../../rtl/top/agrisense_ipms_top.v),
   `domain2_pwr_en` controls CSA enable/capture and the
   [`rtl/ipm/power_controller.v`](../../rtl/ipm/power_controller.v)
   isolation behavior. A baseline definition must specify which activity
   controls are removed while preserving the same useful operations, outputs,
   and latency; simply tying a power-enable high could change functionality.
3. **No matched full-design activity is available.** Neither completed run
   archives VCD/FST/SAIF. The Phase 2 FSM-only trace is not an equivalent
   activity source for the full top-level design.
4. **The physical-flow tools are unavailable in this workspace.** `openlane`
   and `openroad` are not on `PATH`, so a matched place-and-route and
   activity-based power run cannot be produced here. The preserved run
   directories were not used as writable output locations.

Accordingly, the comparison result is:

| Metric | Always-on baseline | Managed design | Change |
|---|---:|---:|---:|
| Physical instance area | Unavailable | Existing run-specific values only; no matched pair | Unavailable |
| Whole-design power | Unavailable | Existing aggregate run estimates only; no matched activity | Unavailable |
| Energy over a common workload | Unavailable | Unavailable | Unavailable |
| Functional equivalence | Not established | Existing implementation only | Not established |

## Requirements to unblock the comparison

- Approve a precise always-on behavior definition that preserves useful-work
  semantics, observable outputs, and latency, including the role of the
  domain-2 enable and isolation paths.
- Freeze and record an immutable source revision for both variants.
- Use the same full-design workload and measurement window for both variants;
  validate behavioral equivalence before comparing power.
- Run both variants through the same physical flow, library, constraints,
  voltage, temperature, corner, and activity-annotation methodology.
- Record power breakdown, area, activity coverage, and measurement duration
  from the paired raw outputs before computing differences or percentages.

Until these prerequisites are met, the baseline comparison is **unverified**,
not a zero-power or zero-delta result. No power savings or area tradeoff
should be claimed from the available archive.
