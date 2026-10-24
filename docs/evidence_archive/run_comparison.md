# Run comparison

This comparison is based solely on the raw final metrics JSON in the preserved run directories and does not merge evidence between runs.

## Run comparison table

| Run ID | Setup slack (ns) | Setup TNS (ns) | Setup violations | Total power (mW) | Core area (µm²) | Instance area (µm²) | Utilization | Antenna violations | Notes |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| RUN_2026-10-24_17-54-09 | -1.6932535852710704 | -11.565447593641487 | 29 | 0.013314031064510345 | 177839 | 71217.1 | 0.400457 | 4 | preliminary run evidence |
| RUN_2026-10-24_19-16-36 | 0.6247749161531793 | 0 | 0 | 0.012208886444568634 | 180158 | 71996.6 | 0.399631 | 11 | adder-tree experiment / variant run |

## Interpretation

- `RUN_2026-10-24_17-54-09` is a negative-slack run with 29 setup violations and 4 antenna nets, consistent with the prior observations in the prompt.
- `RUN_2026-10-24_19-16-36` is a positive-slack run with zero setup violations and 11 antenna nets; the metrics align with the prompt and confirm it is a distinct design/flow variant.
- The repo contains no evidence that the second run was the historical paper run; it should be treated as a separate experiment unless the final paper explicitly names it.
