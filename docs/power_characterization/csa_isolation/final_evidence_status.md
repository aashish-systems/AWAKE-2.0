# CSA Operand Isolation — Final Evidence Status

Date: 2026-10-25

## 1. Functional correctness

- Standalone mapped gate-level test passed.
- Enabled samples: 250.
- Disabled cycles: 200.
- Output mismatches: 0.
- Full-chip paired simulation passed 93 comparison samples.

These tests support functional equivalence for the tested inputs and scenarios,
not exhaustive equivalence for every possible input sequence.

## 2. Standalone mapped-netlist activity and power

| Phase | Baseline (mW) | Isolated candidate (mW) | Reported change |
|---|---:|---:|---:|
| Disabled | 0.624350 | 0.055817 | -91.06% |
| Enabled | 0.640958 | 0.691175 | +7.83% |

These are preliminary activity-driven estimates. The reports show zero clock
power, and the VCD annotation counts differ between the designs. The
percentages must not be described as validated whole-block or silicon power
savings.

The standalone activity trace shows substantially fewer transitions in the
isolated candidate during the disabled phase. This supports the intended
operand-isolation mechanism.

## 3. Full-chip synthesis area

- Baseline: 6,387 cells; 54,853.8592 um^2.
- Candidate: 6,409 cells; 55,110.3552 um^2.
- Area increase: 256.496 um^2, approximately 0.47%.

## 4. Full-chip nominal physical-design power

| Metric | Baseline (mW) | Candidate (mW) |
|---|---:|---:|
| Internal | 5.664651 | 5.716791 |
| Switching | 4.777620 | 4.628173 |
| Leakage | 0.0000484 | 0.0000476 |
| Total | 10.442319 | 10.345010 |

The nominal reports differ by approximately -0.93% in total power. Activity
provenance and equivalent workload annotation were not established for these
reports; this is not a validated workload-driven comparison.

## 5. Full-chip VCD-driven diagnostic

| Metric | Baseline | Candidate |
|---|---:|---:|
| Annotated pin activities | 13,138 | 13,250 |
| Unannotated pins | 13,257 | 12,947 |
| Reported total power (mW) | 2.982019 | 3.032094 |

The candidate's reported total is approximately 1.68% higher in this diagnostic.
A large number of pins remain unannotated, so this result is not a validated
whole-chip power estimate and should not be used to claim either a saving or
a regression.

## 6. Clock-power limitation

The standalone OpenROAD reports show zero clock power. The clock audit records
a warning that activity cannot be set on clock ports, and attempts to set
activity on sequential clock pins did not change the result. Clock power is
therefore not adequately represented by this experiment.

## 7. Physical checks

The archived candidate checks report one max-capacitance violation; the
baseline report shows none. Resolve or explicitly characterize this violation
before claiming that the candidate passes all physical checks.

## 8. Conclusion

The experiment demonstrates functional equivalence for the tested scenarios,
a small synthesis-area increase, and a strong reduction in disabled-phase
standalone activity/power estimates. It does not yet establish a reliable
whole-chip power-saving percentage.

A stronger power claim requires comparable activity annotation, explicit
clock-power treatment, matched workload and analysis settings, and review of
the candidate's capacitance violation.
