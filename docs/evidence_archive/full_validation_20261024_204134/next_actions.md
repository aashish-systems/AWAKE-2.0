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
