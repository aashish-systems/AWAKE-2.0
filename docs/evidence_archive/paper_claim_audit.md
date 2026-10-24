# Paper claim audit

## Summary
This audit checks the evidence available in the repository against the numerical claims listed in the prompt. The conclusions below are drawn from the preserved raw metrics JSON, SDC files, OpenLane flow logs, and validation documents only.

The full first-pass evidence audit, including exact paths for each signoff claim,
is in the [signoff claim matrix](signoff_claim_matrix.md).

## Claim validation matrix

| Run ID | Claim under review | Evidence path | Observed raw value | Status |
|---|---|---|---|---|
| RUN_2026-10-24_17-54-09 | Setup slack approx -1.693 ns; TNS -11.565 ns; 29 violations | `runs/RUN_2026-10-24_17-54-09/final/metrics.json` | `timing__setup__ws = -1.6932535852710704`, `timing__setup__tns = -11.565447593641487`, `timing__setup_vio__count = 29` | verified |
| RUN_2026-10-24_17-54-09 | Total power approx 13.314 mW at max FF | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt` | `power__total = 0.013314031064510345 W`; max-FF report total matches | verified |
| RUN_2026-10-24_17-54-09 | Four antenna-violating nets; DRC pass | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; Magic/KLayout reports; `runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/reports/lvs.netgen.rpt` | `antenna__violating__nets = 4`; route, Magic, and KLayout DRC counts are zero; Netgen says circuits match uniquely | DRC/LVS verified; antenna violations remain |
| RUN_2026-10-24_19-16-36 | Setup slack approx +0.625 ns; TNS zero; zero violations | `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | `timing__setup__ws = 0.6247749161531793`, `timing__setup__tns = 0`, `timing__setup_vio__count = 0` | verified |
| RUN_2026-10-24_19-16-36 | Total power approx 12.209 mW; instance area 71,996.6 µm²; core area 180,158 µm²; utilization ~39.96% | `runs/RUN_2026-10-24_19-16-36/final/metrics.json`; max-FF power report | `power__total = 0.012208886444568634 W`, `design__instance__area = 71996.6`, `design__core__area = 180158`, `design__instance__utilization = 0.399631`; max-FF report total matches | verified |
| RUN_2026-10-24_19-16-36 | Eleven antenna nets and zero DRC | `runs/RUN_2026-10-24_19-16-36/final/metrics.json`; Magic/KLayout reports; `runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/reports/lvs.netgen.rpt` | `antenna__violating__nets = 11`; route, Magic, and KLayout DRC counts are zero; Netgen says circuits match uniquely | DRC/LVS verified; antenna violations remain |
| any run | 116.15 MHz operation / 8.61 ns period | Preserved `resolved.json` files; the two completed runs' final SDCs; `runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ss_100C_1v60/sta.log`; `docs/validation_plan.md` | Completed-run SDCs specify 20 ns; the STA log has a path data-arrival value of 8.615015 ns | 8.61 ns clock claim unsupported; 8.61 ns is a data-arrival value |
| any run | zero antenna violations | final metrics and any available antenna logs | final metrics still show antenna violations (4 or 11 nets) | contradicted by preserved raw evidence |

## Clock-period reconciliation

The preserved evidence does not support the 116.15 MHz (8.61 ns clock-period) paper claim as a final demonstrated result:

- The preserved run `resolved.json` files contain `"CLOCK_PERIOD": 20`.
- `runs/RUN_2026-10-24_17-54-09/final/sdc/agrisense_ipms_top.sdc` contains `create_clock -name clk -period 20.0000 [get_ports {clk}]`.
- `runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc` also contains `create_clock -name clk -period 20.0000 [get_ports {clk}]`.
- In the `19-16-36` STA path report, `8.615015` is labeled `data arrival time`; the same path shows the 20 ns clock edge and a 12.589262 ns slack.
- `docs/validation_plan.md` explicitly states the initial clock target is a relaxed 50 ns (20 MHz) layout target.

Therefore, the present archived evidence is consistent with a 20 ns constraint and does not prove an 8.61 ns clock target. Any statement that this run proves 116.15 MHz must be backed by a different preserved SDC and timing report, not by the current run files. The current working-tree flow config is modified and is not used as the historical source.

## Antenna reconciliation

The preserved run summaries do not justify a claim of zero antenna violations:

- `runs/RUN_2026-10-24_17-54-09/final/metrics.json` reports `route__antenna_violation__count = 4` and `antenna__violating__nets = 4`.
- `runs/RUN_2026-10-24_19-16-36/final/metrics.json` reports `route__antenna_violation__count = 11` and `antenna__violating__nets = 11`.
- Earlier antenna-prevention stages in the same run directories also show nonzero violation counts before repair.

So the current archived evidence is consistent with antenna violations remaining in the final design. A final paper statement claiming zero antenna violations is not supported by the preserved local run evidence.

## High-confidence conclusions

1. The numerical values in the prompt are consistent with the preserved final metrics JSON files for the two runs under review.
2. The second run is a distinct positive-slack run and should not be assumed to be the historical paper run without explicit run metadata or manuscript text.
3. The 20 ns clock constraint is the actual preserved constraint in both completed runs. The 8.61 ns STA value is a data-arrival time, not a clock period, so it does not support the 116.15 MHz claim.
4. Final antenna violations are present in the preserved metrics output; zero-antenna claims are contradicted by the archive.
5. No original reviewer feedback file or paper-source bundle was present in the repository snapshot.

## Missing evidence / limitations

- No original reviewer feedback file or uploaded review attachment was found under `docs/reviews/` or the repository root.
- No manuscript TeX/PDF bundle was found in the preserved repo, so paper-level wording and figure captions cannot be revalidated directly beyond the run metrics and design docs.
- The large generated run directories remain preserved in place and git-ignored; they were not pushed because remote auth is not available in this environment.
