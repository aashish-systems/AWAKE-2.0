# Power characterization methodology

## Scope and interpretation

This execution reruns state-window power analysis on the archived physical
implementation using the checked-in gate-level workload trace. The results
are OpenROAD activity-annotated static power estimates, not silicon
measurements. They are marked `PROVISIONAL`: the state and enable signals
were verified directly in the VCD and all physical-design pins were
annotated, but the exact gate-level netlist used to generate the VCD is no
longer present for independent comparison with the archived ODB.

No energy-per-state, workload-weighted power, energy reduction, or
baseline-versus-managed difference is calculated from these provisional
estimates.

## Inputs and implementation

| Item | Artifact or setting |
|---|---|
| Physical design | `../csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.odb` |
| Constraints | Matching archived `agrisense_ipms_top.sdc`; 20 ns clock |
| Parasitics | Matching archived nominal SPEF |
| PDK/library | SKY130A, `sky130_fd_sc_hd`, TT, 25 C, 1.8 V |
| Workload trace | `../full_design/gatelevel_workload.vcd` |
| VCD scope | `tb_gatelevel_vcd/uut` |
| VCD timescale and duration | 1 ps; 2,840,000 ps (2.84 us) |
| Clock | 142 rising edges; all 141 rising-edge intervals are 20,000 ps |
| Testbench | `../full_design/tb_gatelevel_vcd.v`; Icarus run log reports all checks passed |
| Tool container | `openroad/orfs:latest`, image digest recorded in `runtime.txt` |

The archived ODB, SDC, and SPEF pass the archive's SHA-256 manifest. The
gate-level simulation hash manifest records the netlist used by the
simulation, but that netlist is absent from the current workspace; therefore
the exact VCD-to-ODB netlist correspondence cannot now be independently
re-hashed.

## Window selection and validation

Each interval is open at its end, spans complete clock cycles, and starts
5,000 ps after a clock edge rather than on the edge. The same-phase boundary
selection avoids the OpenROAD VCD-period warning observed when
`read_vcd -begin_time/-end_time` clips at clock transition timestamps. The
full trace itself has a 20 ns period, matching the SDC. The observed warning
was a clipped-window period-inference artifact, not evidence that the
simulated clock was 16 ns.

`extract_results.py` reads the VCD's top-level state and power-enable signals
and verifies they remain constant over each selected interval. It also
checks the clock period and reads the complete power and activity-annotation
reports. The exact interval, state code, enable values, VCD scope, pin
coverage, power breakdown, warnings, and provisional status are in
`state_power_results.csv`.

| Window | Interval (ps) | State | Domain 2 | Domain 3 | Communication |
|---|---:|---:|---:|---:|---:|
| SLEEP_STABLE | 125000-165000 | `00` | 0 | 0 | 0 |
| MONITOR_STABLE | 225000-285000 | `01` | 0 | 0 | 0 |
| MONITOR_PRIMED | 1405000-1545000 | `01` | 0 | 0 | 0 |
| CRITICAL | 1945000-2105000 | `11` | 1 | 1 | 1 |
| WARNING | 2185000-2445000 | `10` | 1 | 0 | 0 |
| MONITOR_RECOVERY | 2565000-2705000 | `01` | 0 | 0 | 0 |

Each OpenROAD run reported 26,395 annotated pin activities and zero
unannotated pins. The six analyzed windows are different lengths and contain
different directed input activity. They are not interchangeable samples of
one universal state power.

## Reproduction

From the repository root, run:

```sh
bash docs/power_characterization/execution_20261026_015400/run_state_windows.sh
```

The runner writes an individual TCL script and complete OpenROAD log for
each window under `raw/`. It uses the pinned local Docker image digest
reported in `runtime.txt`, the archived physical-design files, and the
existing VCD. It then validates the selected windows and writes the results
CSV. The same SLEEP window was run a second time; all reported power
components matched exactly. The duplicate TCL, log, and comparison are in
`repeat/`.

## Why the result remains provisional

- The workload is a short, directed testbench sequence, not field data or a
  deployment duty-cycle profile.
- Although the VCD is identified as gate-level and its hash manifest records
  a netlist hash, that netlist is not retained to independently verify its
  identity against the archived ODB.
- A full-pin annotation count does not establish functional equivalence,
  representative workload activity, or equivalence of the trace netlist and
  analyzed physical implementation.
- The clock is active in every state, and the reports include approximately
  1.403 mW clock power. The RTL enable and isolation signals do not prove
  physical supply gating or clock-tree gating.
- No matching always-on implementation was identified. The existing
  baseline/candidate archive concerns CSA operand isolation and has a
  candidate-source hash mismatch; it is not a matched always-on comparison.
