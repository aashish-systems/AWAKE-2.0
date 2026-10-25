# SLEEP Window Power Diagnostic

## State verification
- VCD: `gatelevel_workload.vcd`
- Selected interval: 100,000–200,000 ps
- Testbench and DUT `ipm_state` identifiers: `#` and `` `/ ``
- RTL encoding: `IPM_SLEEP = 2'b00`; `IPM_MONITOR = 2'b01`
- Observed state: `00` at 0 ps, transitioning to `01` at 210,000 ps
- Conclusion: selected interval remains in SLEEP according to the observed state trace.

## Power estimate
- OpenROAD log: `batch_archive_20261025_174603/sleep_long_window.log`
- Total estimated power: 2.829380799 mW
- Internal power: 2.082295483 mW
- Switching power: 0.747035665 mW
- Leakage power: 0.000049641628 mW
- Annotated pin activities: 26,395
- Unannotated pin activities: 0
- Clock-period warning: none reported in the extracted diagnostic output

## Limitations
This is a short, directed gate-level VCD window and a tool-based power estimate.
It is not evidence of deployment-level sleep power or a measured power-saving
percentage. The activity annotation report does not independently establish
the representativeness of the stimulus, clock activity, or power assumptions.
Do not claim a validated whole-chip power reduction from this result alone.
