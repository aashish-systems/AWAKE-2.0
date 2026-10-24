# Paper claim audit

## Summary
This audit checks the evidence available in the repository against the numerical claims listed in the prompt. The conclusions below are drawn from the preserved raw metrics JSON and OpenLane flow logs only.

## Claim validation

| Run ID | Claim from prompt | Evidence | Result |
|---|---|---|---|
| RUN_2026-10-24_17-54-09 | Setup slack approx -1.693 ns; TNS -11.565 ns; 29 violations | `final/metrics.json` has `timing__setup__ws = -1.6932535852710704`, `timing__setup__tns = -11.565447593641487`, `timing__setup_vio__count = 29` | verified |
| RUN_2026-10-24_17-54-09 | Total power approx 13.314 mW at max FF | `power__total = 0.013314031064510345` | verified |
| RUN_2026-10-24_17-54-09 | Four antenna-violating nets; DRC and LVS pass | `antenna__violating__nets = 4`; `route__drc_errors = 0`; `design__violations = 0`; no LVS result is present in the raw files checked here | partially verified (antenna + DRC present; LVS status is not directly evidenced in reviewed files) |
| RUN_2026-10-24_19-16-36 | Setup slack approx +0.625 ns; TNS zero | `timing__setup__ws = 0.6247749161531793`, `timing__setup__tns = 0`, `timing__setup_vio__count = 0` | verified |
| RUN_2026-10-24_19-16-36 | Total power approx 12.209 mW; instance area 71,996.6 µm²; core area 180,158 µm²; utilization ~39.96% | metrics JSON shows the same values | verified |
| RUN_2026-10-24_19-16-36 | Eleven antenna nets, zero DRC, LVS matches | `antenna__violating__nets = 11`, `route__drc_errors = 0`, `design__violations = 0`; LVS results are not explicitly enumerated in the inspected files | partially verified |

## High-confidence conclusions

1. The run numbers and numerical values reported in the prompt are consistent with the preserved final metrics JSON files.
2. The second run is a distinct positive-slack design/flow variant and should not be assumed to be the same as the paper run without explicit paper metadata or a separate run identity.
3. Several reviewer concerns remain unverified because no original reviewer feedback file was present in the repository.

## Missing evidence / limitations

- No original reviewer feedback file or uploaded review attachment was found under `docs/reviews/` or the repository root.
- The repository does not include an explicit paper source TeX/PDF bundle, so manuscript-level claims cannot be revalidated beyond the run metrics and design docs.
- Large run outputs are preserved in-place and are git-ignored; they were not pushed because the repo ignores those directories and remote size limits would risk committing a multi-hundred-megabyte artifact set without a configured Git LFS or durable artifact store.
