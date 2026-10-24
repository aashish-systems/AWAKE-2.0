# Phase 1 evidence audit

Audit date: 2026-10-24

Repository: `/workspaces/AWAKE-2.0`

Branch and starting HEAD: `main`, `c830aed944b8e821e1f37321656bfac4ca4c9b53`

This audit uses the preserved local run artifacts as primary evidence. Existing
summaries are navigation aids only. It does not identify a historical paper
run unless the raw artifacts establish that identity. No RTL, flow
configuration, preserved run, or raw report was modified or regenerated.

## Run provenance and execution status

| Run ID | Observed execution extent | Configuration / SDC | Provenance conclusion |
|---|---|---|---|
| `RUN_2026-10-24_17-48-54` | Synthesis-focused stages through `06-yosys-synthesis`; its `final/` contains a netlist and metrics, but no final SDC, placement, CTS, routing, extraction, STA, power report, antenna report, DRC, or LVS. Its final metrics report 6,343 instances and 71,208.2944 µm² instance area; other physical-signoff metrics are absent. | `resolved.json` has `CLOCK_PERIOD=20`, but no generated final SDC is present. | Synthesis-only evidence. Not a completed physical-design/signoff run and not enough evidence to designate it the paper run. |
| `RUN_2026-10-24_17-54-09` | Stage directories proceed through synthesis, placement, CTS, global/detailed routing, fill, RC extraction, post-route STA/power, streamout, Magic/KLayout DRC, Netgen LVS, setup/hold checks, and final metrics. | Resolved config and final SDC specify 20 ns. | Completed physical-flow artifact set. Exact source commit and identity as the historical paper run are not recorded in the run metadata. |
| `RUN_2026-10-24_19-16-36` | Same physical-flow stage extent as the preceding run, through post-route STA/power and signoff reports. | Resolved config and final SDC specify 20 ns. | A separate completed physical-flow result, with different final netlists/metrics from `17-54-09`. The archive does not establish it as the historical paper run. |

The three `resolved.json` files have identical SHA-256
`c94336439e6b9cde6a6545c5830e646406f12b96151b7099ff27ea0d270b25e7`. They
identify the same top-level source file paths, clock setting, PDK and library
configuration, but do not contain a source Git SHA (`OPENLANE_VERSION`,
`flow__run__id`, and run-directory metadata are null). The two physical runs
have different final synthesized and placed netlist hashes. Thus, the outputs
are distinguishable run variants, but their exact RTL source revisions cannot
be tied to a commit from the preserved run metadata. Run-stage files establish
within-run continuation through physical design; they do not prove a commit
identity for the source snapshot.

The source paths in these run records point to `/root/AWAKE-2.0/...`, not to
an archived immutable source snapshot. The present checkout has pre-existing
local RTL and flow-config changes, which were left untouched and cannot be
used to infer what source text was used by the older runs. No paper source or
original manuscript bundle was found, so which completed run (if either) is
the historical paper run remains unverified.

## Timing and frequency

Both completed physical runs record `CLOCK_PERIOD=20` in their resolved
configuration and `create_clock -name clk -period 20.0000 [get_ports {clk}]`
in the final SDC. That is a **50 MHz constraint**. The final STA reports also
record 4 ns input and output delays and 0.25 ns clock uncertainty. No preserved
run SDC sets an 8.61 ns period.

The string `8.615015` occurs in
`RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ss_100C_1v60/sta.log`.
At that report location it is explicitly the data-arrival time on an
input-to-register path from `m_addr[4]`; the same path reports 21.163767 ns
required time and 12.589262 ns positive slack under the 20 ns clock. This is
not a clock constraint or the run's worst critical-path delay. The completed
run's aggregate worst setup slack is 0.624774916 ns at the max-SS corner.
Therefore, positive slack at 20 ns does not demonstrate timing closure at
8.61 ns or operation at 116.15 MHz.

`RUN_2026-10-24_17-54-09` reports setup WNS `-1.6932535852710704` ns, TNS
`-11.565447593641487` ns and 29 setup violations. `RUN_2026-10-24_19-16-36`
reports WNS `0.6247749161531793` ns, TNS 0 ns and zero setup violations.
These results are run-specific and must not be combined.

## Area and utilization

| Run ID | Instances | Instance area | Core area | Reported utilization |
|---|---:|---:|---:|---:|
| `17-48-54` | 6,343 | 71,208.2944 µm² | not reported | not reported |
| `17-54-09` | 9,822 | 71,217.1 µm² | 177,839 µm² | 0.400457 (40.0457%) |
| `19-16-36` | 9,894 | 71,996.6 µm² | 180,158 µm² | 0.399631 (39.9631%) |

The synthesis-only instance area is not directly comparable to the completed
physical-run area as a final signoff metric. The physical values come from
each run's own `final/metrics.json`.

## Power and measurement limitations

Both physical runs use PDK `sky130A`, standard-cell library
`sky130_fd_sc_hd`, configured VDD 1.8 V, and a 20 ns clock. The final power
reports have a max-FF corner named `max_ff_n40C_1v95` (FF, -40 °C, 1.95 V);
separate reports exist for other corners. Do not present the max-FF power as
the nominal 1.8 V result.

| Run ID | `power__total` raw value | Converted value | Internal | Switching | Leakage | Report |
|---|---:|---:|---:|---:|---:|---|
| `17-54-09` | 0.013314031064510345 W | 13.3140310645 mW | 0.006903085857629776 W | 0.00641086557880044 W | 7.974568205781907e-8 W | `54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt` |
| `19-16-36` | 0.012208886444568634 W | 12.2088864446 mW | 0.006340246181935072 W | 0.005868560168892145 W | 8.02500395025163e-8 W | `54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt` |

The totals and breakdowns are report values, not per-state measurements.
No VCD, FST, or SAIF activity trace exists under the preserved run
directories, and the archived power reports do not establish a workload,
activity source, or state dwell interval. The totals must therefore be
described as aggregate OpenROAD/OpenSTA flow power estimates under archived
constraints and report assumptions, not as measured or state-specific power.
The max-FF values above cannot substantiate a power-saving claim against a
baseline without comparable source, activity, corner, voltage, temperature,
and measurement conditions.

## DRC, LVS, antenna, and signoff scope

Both completed physical runs have final `route__drc_errors=0`,
`magic__drc_error__count=0`, and `klayout__drc_error__count=0`. The raw Magic
reports say `[INFO] COUNT: 0`; every count and total in each KLayout JSON is
zero. Their raw Netgen reports say `Final result: Circuits match uniquely.`
These results support the stated open-source-flow DRC/LVS outcomes only; they
do not constitute formal foundry signoff.

Final antenna metrics and the later post-repair antenna checks report 4
violating nets in `17-54-09` and 11 in `19-16-36`. Earlier repair-stage
counts of zero or one do not override the later check. Neither completed run
is antenna-clean. DRC or LVS pass status must not be represented as antenna
closure.

## Claim and phase disposition

The exact claim-level rows, status vocabulary, source paths, and corrective
actions are in [claim_evidence_matrix.csv](claim_evidence_matrix.csv).
Run-level signoff distinctions are summarized in
[signoff_reconciliation.md](signoff_reconciliation.md).

Phase 1 has reconciled the recorded configuration, clock target, run-stage
extent, available metrics, and signoff status. The historical paper-run
identity and source revisions remain unverified and must be disclosed. The
8.61 ns/116.15 MHz timing claim is not demonstrated by the preserved runs;
zero-antenna claims are contradicted; aggregate reports do not support
per-state or baseline power claims. No Phase 2 power experiment is included
in this audit.
