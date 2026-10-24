# Preserved-run evidence audit and signoff reconciliation

Audit date: 2026-10-24

## Scope and method

This is a read-only audit of the preserved local run archive. No RTL, flow
configuration, or `runs/` artifacts were changed, and no flow was rerun. Run
artifacts, rather than the current working-tree `flow/config.json`, are the
source of truth for the historical results. The current flow config is locally
modified and is not used to infer the configuration of a preserved run.

Three run directories are present:

- `RUN_2026-10-24_17-48-54` contains synthesis-stage output only; it is not
  evidence of physical-design or signoff results.
- `RUN_2026-10-24_17-54-09` and `RUN_2026-10-24_19-16-36` contain completed
  physical-design runs with final metrics and signoff-stage artifacts.

All evidence paths in the matrix are repository-relative and point into the
preserved local archive. The `runs/` tree is git-ignored, so these paths are
locally available but are not carried by the repository commit.

## Claim matrix

| Claim / check | Run and result | Exact evidence paths | Audit conclusion |
|---|---|---|---|
| Applied clock configuration | `17-48-54`, `17-54-09`, and `19-16-36`: `CLOCK_PERIOD=20` ns. The two completed runs' final SDCs each contain `create_clock -name clk -period 20.0000`. | `runs/RUN_2026-10-24_17-48-54/resolved.json`; `runs/RUN_2026-10-24_17-54-09/resolved.json`; `runs/RUN_2026-10-24_17-54-09/final/sdc/agrisense_ipms_top.sdc`; `runs/RUN_2026-10-24_19-16-36/resolved.json`; `runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc` | **Verified:** the preserved physical runs used a 20 ns clock. |
| Reconciliation of 20 ns and 8.61 ns | In the `19-16-36` STA path report under `nom_ss_100C_1v60`, `8.615015` is a data-arrival time for one input-to-register path. The same path report shows a 20.000000 ns clock edge, 21.163767 ns required time, and 12.589262 ns slack. The run's worst setup slack metric is 0.624774916 ns. | `runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ss_100C_1v60/sta.log`; `runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | **Reconciled:** 8.61 ns is not the clock period. It is a path data-arrival value, and does not replace the 20 ns constraint. Do not describe this run as using an 8.61 ns clock. |
| Setup timing | `17-54-09`: WNS `-1.6932535852710704` ns, TNS `-11.565447593641487` ns, 29 setup violations. `19-16-36`: WNS `0.6247749161531793` ns, TNS `0`, zero setup violations. | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ss_100C_1v60/sta.log`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ss_100C_1v60/sta.log` | **Verified:** the timing outcomes differ by run; do not combine the failing first physical run with the passing second-run timing. |
| Total power, max-FF corner | `17-54-09`: `power__total=0.013314031064510345 W` (13.3140310645 mW). `19-16-36`: `power__total=0.012208886444568634 W` (12.2088864446 mW). In each case the final metric equals the max-FF report total. | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt` | **Verified:** the previously reported milliwatt figures are the raw watt values converted to mW; max-FF attribution is confirmed by the matching max-FF power reports. |
| Routing, Magic, and KLayout DRC | Both completed runs: final `route__drc_errors=0`, `magic__drc_error__count=0`, and `klayout__drc_error__count=0`. Magic reports `[INFO] COUNT: 0`; all KLayout rule counts and `total` are zero. | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_17-54-09/62-magic-drc/reports/drc_violations.magic.rpt`; `runs/RUN_2026-10-24_17-54-09/63-klayout-drc/reports/drc_violations.klayout.json`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/62-magic-drc/reports/drc_violations.magic.rpt`; `runs/RUN_2026-10-24_19-16-36/63-klayout-drc/reports/drc_violations.klayout.json` | **Verified:** the named routing and physical DRC checks are clean in both completed runs. This is separate from antenna checking. |
| Antenna status after repair and final check | `17-54-09`: 14 violating nets before repair, 0 at the repair sub-check, then 4 at the later `45-openroad-checkantennas-1` check and in final metrics. `19-16-36`: 16 before repair, 1 at the repair sub-check, then 11 at the later check and in final metrics. | `runs/RUN_2026-10-24_17-54-09/39-openroad-checkantennas/or_metrics_out.json`; `runs/RUN_2026-10-24_17-54-09/41-openroad-repairantennas/2-openroad-checkantennas/or_metrics_out.json`; `runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/or_metrics_out.json`; `runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/reports/antenna_summary.rpt`; `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/39-openroad-checkantennas/or_metrics_out.json`; `runs/RUN_2026-10-24_19-16-36/41-openroad-repairantennas/2-openroad-checkantennas/or_metrics_out.json`; `runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/or_metrics_out.json`; `runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/reports/antenna_summary.rpt`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | **Not antenna-clean:** the authoritative later check and final metric report 4 and 11 violating nets, respectively. Intermediate repair-stage zero/one counts do not establish final antenna closure. Zero DRC counts do not clear these antenna violations. |
| LVS | Both completed runs: Netgen says `Final result: Circuits match uniquely.` Final metrics report zero LVS errors, unmatched devices/nets/pins, device/net differences, and property failures. | `runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/reports/lvs.netgen.rpt`; `runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/state_out.json`; `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/reports/lvs.netgen.rpt`; `runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/state_out.json`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | **Verified:** LVS matches uniquely in both completed runs. |
| Final physical metrics | `17-54-09`: core area `177839 µm²`, instance area `71217.1 µm²`, utilization `0.400457`. `19-16-36`: core area `180158 µm²`, instance area `71996.6 µm²`, utilization `0.399631`. | `runs/RUN_2026-10-24_17-54-09/final/metrics.json`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | **Verified:** values are run-specific and taken from each run's own final metrics. |
| Result checkpoints | Both repository result checkpoints have the same principal timing, power, DRC, and antenna metric values as `19-16-36`. | `results/checkpoint_20261024_194321/reports/metrics.json`; `results/checkpoint_20261024_194335/reports/metrics.json`; `runs/RUN_2026-10-24_19-16-36/final/metrics.json` | **Consistent but not independent:** checkpoint copies corroborate the second run's values but are not separate signoff runs. |
| Earliest preserved run as signoff evidence | `17-48-54` has resolved configuration and synthesis outputs, but no final SDC, routing, DRC, antenna, LVS, or routed final metrics. | `runs/RUN_2026-10-24_17-48-54/resolved.json`; `runs/RUN_2026-10-24_17-48-54/final/metrics.json`; `runs/RUN_2026-10-24_17-48-54/06-yosys-synthesis/` | **Insufficient for physical signoff:** use only as synthesis-stage evidence. |

## Signoff disposition

The two completed runs have clean reported route, Magic, and KLayout DRC and
matching LVS. Both nevertheless retain antenna violations in their later
antenna check and final metrics. Therefore, the evidence supports DRC and LVS
pass claims for those runs, but does **not** support an antenna-clean or
unqualified all-signoff-pass claim. The run with positive setup slack is
`RUN_2026-10-24_19-16-36`; it is not evidence that the separate
`RUN_2026-10-24_17-54-09` timing result passed.
