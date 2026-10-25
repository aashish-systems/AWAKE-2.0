# CSA Operand-Isolation Microbenchmark

## Scope
Compare the existing CSA implementation with a testbench-only candidate
that forces the five sensor operands and five weights to zero while disabled.

## Results
- Disabled-state sampled product-bus bit transitions:
  - Baseline: 1098
  - Isolated candidate: 0
- Enabled-state sampled product-bus bit transitions:
  - Baseline: 766
  - Isolated candidate: 766
- Testbench functional-equivalence checks: PASS
- Production RTL modified: NO

## Interpretation
The test demonstrates elimination of sampled transitions on the five
multiplier product buses during the tested disabled interval. Enabled-state
sampled activity is unchanged.

These are settled-value bit-transition counts, not glitch-aware switching
activity or power measurements. They do not establish a percentage reduction
in total or dynamic power. A mapped-netlist comparison with equivalent
workloads, consistent timing, and activity-driven power analysis is required.

## Reproduction
Compile and run from the repository root:

    iverilog -g2012 -I rtl/common -s tb_csa_isolation \
      -o build_csa_isolation_sim \
      rtl/csa/weighted_sum.v \
      rtl/csa/normalization_unit.v \
      rtl/csa/crop_stress_accelerator.v \
      docs/power_characterization/csa_isolation/tb_csa_isolation.v

    vvp build_csa_isolation_sim

## Production RTL integrity
Expected SHA-256 for rtl/csa/crop_stress_accelerator.v:

    5a5d5618f1776dab29c38494518cacff9601822392c530fe2d4e0434b9a1b3fc
