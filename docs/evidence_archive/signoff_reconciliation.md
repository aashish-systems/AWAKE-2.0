# Phase 1 signoff reconciliation

Audit date: 2026-10-24

## Disposition

| Check | `RUN_2026-10-24_17-48-54` | `RUN_2026-10-24_17-54-09` | `RUN_2026-10-24_19-16-36` |
|---|---|---|---|
| Run extent | Synthesis-only; not signoff | Physical run through final STA and signoff stages | Physical run through final STA and signoff stages |
| Clock | Resolved period 20 ns; no final SDC | 20 ns, final SDC confirmed | 20 ns, final SDC confirmed |
| Setup WNS/TNS/violations | Not present | -1.6932535852710704 ns / -11.565447593641487 ns / 29 | +0.6247749161531793 ns / 0 ns / 0 |
| Total max-FF power report | Not present | 0.013314031064510345 W (13.3140310645 mW) | 0.012208886444568634 W (12.2088864446 mW) |
| Route DRC | Not present | 0 errors | 0 errors |
| Magic DRC | Not present | 0 errors | 0 errors |
| KLayout DRC | Not present | Not present | 0 errors |
| Netgen LVS | Not present | Circuits match uniquely | Circuits match uniquely |
| Final antenna count | Not present | 4 nets | 11 nets |
| Historical paper-run attribution | Unverified | Unverified | Unverified |

## Clock claim

The resolved configs and final SDCs for both completed physical runs specify
20 ns, equivalent to 50 MHz. The STA text `8.615015` is a data-arrival value
for one input-to-register path in
`RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ss_100C_1v60/sta.log`.
That path has 12.589262 ns slack under the 20 ns clock; it is not evidence
that an 8.61 ns clock was constrained or that the design closes timing at
116.15 MHz. The run's worst setup slack is 0.624774916 ns at the max-SS
corner, also under the 20 ns constraint.

## DRC, LVS, and antenna are separate outcomes

The two completed physical runs report zero route, Magic, and KLayout DRC
errors, and their Netgen reports state `Final result: Circuits match
uniquely.` Their final antenna counts are nevertheless nonzero: 4 and 11,
respectively. Intermediate antenna-repair counters (0 and 1) are followed by
later checks that report 4 and 11. Consequently:

- The evidence supports the named open-source DRC and LVS checks for the two
  completed runs.
- It does not support an antenna-clean claim.
- It does not establish formal foundry signoff.

## Power scope

Power figures in the reports are watts; the milliwatt values are calculated
by multiplying by 1,000. The compared values are each run's max-FF
`max_ff_n40C_1v95` result, corresponding to -40 °C and 1.95 V; configured
VDD is 1.8 V. No VCD/FST/SAIF activity file or reproducible state workload is
archived for these runs. Use these as aggregate flow estimates at the
specified corner only. They do not verify state power, energy per operation,
or a power reduction versus a comparable baseline.

## Run/source provenance limitation

The earliest run only provides synthesis output. The two completed runs have
different final netlist hashes, but their resolved configuration hashes and
recorded top-level source paths are identical. No source Git revision or
immutable RTL snapshot is recorded. The repository contains no manuscript
source that identifies the historical paper run. Therefore neither completed
run can be asserted as the paper's historical implementation solely from
this archive.

See [evidence_audit.md](evidence_audit.md) for metric and provenance detail
and [claim_evidence_matrix.csv](claim_evidence_matrix.csv) for claim-level
evidence paths, status, and corrective action.
