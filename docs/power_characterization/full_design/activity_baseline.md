# AWAKE Full-Top Functional Activity Baseline

## Trace provenance
- Design top: agrisense_ipms_top
- Testbench: temporary VCD-enabled copy of tb/tb_top.v
- Simulator: Icarus Verilog
- Trace: build/power_characterization/full_design/awake_top_workload.vcd
- VCD timescale: 1 ps per timestamp unit
- Trace duration: 2.481 us
- Simulation result: TEST PASSED tb_top

## State occupancy
| State | Duration (ns) | Fraction (%) |
|---|---:|---:|
| SLEEP | 221 | 8.908 |
| MONITOR | 1700 | 68.521 |
| WARNING | 380 | 15.316 |
| CRITICAL | 175 | 7.054 |
| UNKNOWN | 5 | 0.202 |

## Power-domain enable occupancy
| Signal | Enabled (ns) | Disabled (ns) | Unknown (ns) |
|---|---:|---:|---:|
| d2 | 555 | 1921 | 5 |
| d3 | 175 | 2301 | 5 |
| comm | 175 | 2301 | 5 |

## Interpretation and limitations
- This trace comes from a directed functional verification test, not a representative field workload.
- The occupancy includes reset, configuration writes, sensor samples, state transitions, and recovery.
- UNKNOWN intervals are retained rather than silently assigned to a state.
- Domain-enable duration measures logical activity, not actual transistor switching or supply power.
- No power, energy, leakage, or percentage power-saving claim can be inferred from these values alone.
- The trace is a candidate input for activity-aware power analysis after validating signal mapping, netlist compatibility, and activity annotation.

## Reproduction
The temporary testbench is:
build/power_characterization/full_design/tb_top_vcd.v

The original tb/tb_top.v was not modified for VCD instrumentation.
