# AWAKE Power Evidence Status

## Scope

This report distinguishes functional activity evidence from power estimation.
A VCD file is not itself a power measurement.

## Functional activity trace

Expected trace:
`build/power_characterization/full_design/awake_top_workload.vcd`

The trace was produced from a directed simulation of `tb_top`.
Original trace duration: 2.481 us. The regenerated 50 MHz trace finishes at 4.961 us.

Previously parsed state occupancy:
- SLEEP: 221 ns (8.908%)
- MONITOR: 1700 ns (68.521%)
- WARNING: 380 ns (15.316%)
- CRITICAL: 175 ns (7.054%)
- UNKNOWN: 5 ns (0.202%)

Previously parsed logical domain-enable occupancy:
- Domain 2 disabled: 1921 ns; enabled: 555 ns; unknown: 5 ns
- Domain 3 disabled: 2301 ns; enabled: 175 ns; unknown: 5 ns
- Communication domain disabled: 2301 ns; enabled: 175 ns; unknown: 5 ns

These occupancy values describe this directed testbench only. They are not
representative field-duty-cycle estimates and do not quantify power savings.

## Existing physical-design power report

Run:
`runs/RUN_2026-10-24_19-16-36`

Corner:
`nom_tt_025C_1v80`

The saved STA log reports:
- Internal power: 5.664651 mW
- Switching power: 4.777620 mW
- Leakage power: approximately 0.0000484 mW
- Total power: 10.442319 mW

The inspected STA log contains `report_power`, but no explicit
`read_vcd`, `read_saif`, or `set_power_activity` command. Therefore,
this total must be treated as the existing tool-estimated result under
the run's configured activity assumptions, not a VCD-annotated workload
measurement.

## Missing evidence

- A repository-pinned, reproducible OpenROAD runtime and PDK setup
- Sufficient activity annotation coverage for the full mapped netlist
- Validation that the RTL-derived activity trace represents the mapped implementation
- Baseline-versus-gated comparison under the same workload, library,
  timing corner, parasitics, and analysis settings
- State-specific whole-design power results

## Scientific conclusion

Power savings from Domain 2 and Domain 3 gating have not yet been
quantified. A Docker-based OpenROAD probe successfully annotated 97
pin activities, but reported 26,298 unannotated activities (0.3675%
annotated fraction). The resulting 7.40 mW report is therefore not
a validated whole-design workload power result. Logical enable occupancy alone is insufficient to calculate
dynamic power or energy savings. Do not report an estimated percentage
saving without a controlled comparison.

## Next measurement procedure

1. Use the verified Docker OpenROAD environment and matching SKY130 PDK library.
2. Load the saved post-route design, timing constraints, Liberty and SPEF.
3. Generate mapped-netlist activity using the same directed workload.
4. Verify activity annotation coverage and inspect unannotated signals.
5. Run `report_power` and save the complete script and log.
6. Compare baseline and gated implementations under identical conditions.
7. Report internal, switching and leakage power separately, with units,
   corner, workload duration, annotation coverage, and limitations.
