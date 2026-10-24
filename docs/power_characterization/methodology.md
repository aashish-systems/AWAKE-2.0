# State power and energy methodology

## Phase 2 result

Reliable state-specific power and energy are **unavailable** from the
preserved evidence and the tools available in this workspace. This phase
therefore does not assign a power or energy value to SLEEP, MONITOR, WARNING,
or CRITICAL and makes no power-saving claim. The reproducible simulation
records the controller's state sequence, enable outputs, and synthetic
cycle occupancy only.

## Verified state behavior

The implementation under test is `rtl/ipm/ipm_fsm.v`; encodings are defined
in `rtl/common/agrisense_defs.vh`.

| State | Code | Implemented asserted outputs |
|---|---:|---|
| SLEEP | `00` | None of the seven decoded enables |
| MONITOR | `01` | `sensor_en`, `decde_en` |
| WARNING | `10` | `sensor_en`, `decde_en`, `domain2_pwr_en`, `csa_en`, `dtree_en` |
| CRITICAL | `11` | All seven decoded enables, including Domain 3 and communication |

The directed sequence is reset/SLEEP → MONITOR → WARNING → CRITICAL →
WARNING → MONITOR. WARNING-to-MONITOR recovery exercises the RTL's
two-consecutive-valid-normal-sample hysteresis; invalid leaf cycles do not
count toward recovery. These signal semantics are established in the FSM RTL
and the self-checking testbench, not inferred only from state names.

The top-level RTL connects all modules to the same `clk`; the state outputs
are enables and control/isolated signals, not evidence of physical
power-switch cells or clock-tree gating. Disabled behavior may suppress
sample acceptance and disable the CSA, but the present testbench instantiates
only the FSM and does not measure switching in the complete datapath.

## Executable measurement method

Run from the repository root:

```sh
bash sim/scripts/run_ipm_state_workload.sh
```

The script compiles the actual `ipm_fsm.v` with Icarus Verilog, runs
`tb/tb_ipm_state_workload.sv`, and validates the resulting state trace with
`sim/scripts/analyze_ipm_state_trace.py`. The bench uses a 20 ns simulation
clock period to align the stimulus schedule with the archived physical-run
constraint; this does not constitute a power analysis or a timing-closure
claim.

Outputs:

- `sim/power_characterization/state_trace.csv` — checked-in per-cycle
  controller inputs, state, phase, and enable outputs.
- `docs/power_characterization/state_occupancy_results.csv` — derived
  controller-state cycle counts and occupancy for this directed workload.
- `build/power_characterization/ipm_state_workload.vcd` — local VCD containing
  only the FSM/testbench scope. This path is ignored by the repository's
  generated-file rules and can be regenerated.
- `build/power_characterization/simulation.log` — simulator pass/fail and
  cycle-count log; local generated output.

The analyzer checks the exact sampled sequence, cycle numbering, per-state
outputs, and expected state counts; it fails rather than emitting a
success-shaped occupancy file if these checks fail.

## Why power and energy remain unavailable

The preserved OpenROAD/OpenSTA `power__total` values are whole-design
aggregate corner estimates, not state-indexed measurements. The run archives
contain no VCD, FST, or SAIF activity trace and do not define a state workload
or measurement window. Available OpenLane/OpenROAD power tools are also not
installed in this workspace. An FSM-only VCD cannot provide complete
datapath, clock-tree, or standard-cell activity for state power.

The archived aggregate reports use max-FF corner `max_ff_n40C_1v95`
(-40 °C, 1.95 V), while the resolved config sets VDD to 1.8 V and a 20 ns
clock. They do not support a per-state, nominal-voltage, or energy-per-state
interpretation. No values from those reports are copied into the
state-specific power or energy result tables.

## Confidence and limits

- **High confidence:** state encoding, transition behavior, FSM output decode,
  and the simulated occupancy of this exact directed control sequence, once
  the test passes.
- **No power confidence/value:** this simulation has no cell library,
  post-route parasitics, state-annotated activity, or power model.
- **Not representative field data:** stimuli directly force `wake_timer`,
  `stress_event`, `leaf_valid`, and leaf severity. They are synthetic FSM
  controls, not generated sensor readings, real field observations, or a
  simulation of equivalent sensor/compute work.
- The transition-heavy schedule's occupancy must not be interpreted as a
  deployment duty cycle or used as occupancy weights for an average-power
  estimate.

Consequently, `state_power_results.csv` and `state_energy_results.csv`
intentionally mark all target values unavailable. No Phase 3 baseline
comparison is included.
