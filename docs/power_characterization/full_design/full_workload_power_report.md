# Gate-Level Full-Workload Power Characterization

- Corner: TT, 25°C, 1.8 V
- Activity source: gate-level VCD
- VCD SHA-256: 0d9e0bbcec7484ca088acbf5752d4690243db761cdea108db646d828bac37d39
- Physical run: RUN_2026-10-24_19-16-36
- Activity annotation: 26,395 pins; 0 unannotated
- Clock: 20 ns SDC; no clock-period warning on full-trace import
- Total estimated power: 2.943301108 mW
- Sequential: 1.435626647 mW
- Combinational: 0.104663850 mW
- Clock: 1.403011149 mW
- Leakage: 0.000049432 mW

## Limitations

- Full-workload estimate; not a sleep-only measurement.
- No verified greater-than-80% dynamic-power reduction claim.
- Requires equivalent baseline-versus-gated comparison for the target compute domain.

## Raw tool log

See measure_full_vcd.log in this directory.
