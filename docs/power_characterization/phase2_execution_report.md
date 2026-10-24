# Phase 2 execution report — state power and energy characterization

Execution date: 2026-10-24

Repository: `/workspaces/AWAKE-2.0`

Branch: `main`
Starting HEAD: `7c3dae1e0326c4d0051481ab215e3e807632254d`

## Scope and preservation

Phase 2 only was executed. The pre-existing changes to `flow/config.json`,
`rtl/csa/crop_stress_accelerator.v`, Phase 1 audit deliverables, and
`flow/config.json.bak` were preserved. No RTL implementation, flow
configuration, preserved OpenLane run, or raw report was modified. No Phase 3
always-on baseline or paper revision was started.

## Method and result

Inspected `rtl/ipm/ipm_fsm.v`, `rtl/common/agrisense_defs.vh`,
`rtl/top/agrisense_ipms_top.v`, and `docs/fsm.md`. Created a deterministic
FSM-only workload that exercises the real state transitions and enable
outputs, including WARNING invalid-leaf hold, critical escalation/recovery,
and the two-valid-normal-sample hysteresis exit.

Run from the repository root:

```sh
bash sim/scripts/run_ipm_state_workload.sh
```

Validated execution:

```text
WORKLOAD PASSED cycles=83 sleep=14 monitor=32 warning=21 critical=16
Trace valid: 83 sampled cycles including reset.
Operating workload: 81 cycles at 20 ns/cycle.
Observed state sequence: SLEEP -> MONITOR -> WARNING -> CRITICAL -> WARNING -> MONITOR
Power/energy: unavailable; this FSM-only simulation is not a power model.
```

The simulator was Icarus Verilog 12.0 (stable); the analyzer ran with Python
3.14.2. The new bench and analyzer both validate expected state/output
behavior and trace counts. The existing `tb_ipm_fsm` regression also passed
before Phase 2 additions.

## Artifacts

- `methodology.md` — verified state contract, method, and limitations.
- `state_power_results.csv` — explicit `unavailable` values for all four
  states; no aggregate metric was relabeled as state power.
- `state_energy_results.csv` — simulated directed-trace occupancy and
  duration, with power and energy explicitly unavailable.
- `state_occupancy_results.csv` — analyzer-derived occupancy, including
  transition samples and excluding reset.
- `activity_provenance.md` — stimulus, reset, sequence, phase codes, tool
  versions, artifact hashes, and scope limitations.
- Stimulus source: `tb/tb_ipm_state_workload.sv`.
- Reproduction scripts: `sim/scripts/run_ipm_state_workload.sh` and
  `sim/scripts/analyze_ipm_state_trace.py`.
- Per-cycle trace: `sim/power_characterization/state_trace.csv`.
- Local ignored generated files: `build/power_characterization/ipm_state_workload.vcd`
  and `build/power_characterization/simulation.log`.

The operating schedule has 81 cycles after reset: SLEEP 12, MONITOR 32,
WARNING 21, CRITICAL 16. This occupancy belongs only to the directed
synthetic controller workload; it is not a deployment duty cycle or a
measured power window.

## Power/energy gate

State-specific power and energy remain unavailable. The archived physical
reports provide only aggregate power estimates, there are no archived
full-design VCD/FST/SAIF activity traces, and OpenLane/OpenROAD are not
installed in the current workspace. The generated VCD covers only the IPM
FSM/testbench. No physical cell model, datapath activity, clock-tree
activity, or state-specific power can be derived from it.

The simulation does not establish equivalent useful work between states,
does not use sensor input traces, and does not represent real agricultural
field data. Consequently no occupancy-weighted average power, energy per
state, or energy reduction is calculated. This meets the Phase 2 fallback
gate: unavailable values are reported without fabrication. Phase 3
comparison requires separate authorization and valid comparable power
evidence.
