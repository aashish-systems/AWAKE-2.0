# CSA Operand-Isolation Power Comparison

Preliminary activity-driven standalone mapped-netlist estimates.

| Phase | Baseline (mW) | Isolated (mW) | Change |
|---|---:|---:|---:|
| Disabled | 0.624349690 | 0.055817109 | -91.06% |
| Enabled | 0.640958431 | 0.691175403 | 7.83% |

## Simplified break-even estimate

Break-even enabled fraction: **91.88%**.

This assumes average power is a linear mixture of the two reported phase powers. It is not an application-level or silicon measurement.

## Limitations

- Both reports currently show zero clock power.
- These are standalone mapped-netlist estimates, not post-route matched measurements.
- VCD annotation counts differ between netlists; equivalent coverage has not been established.
- Validate clock/activity handling before claiming power savings.
