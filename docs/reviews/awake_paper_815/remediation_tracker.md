# Reviewer remediation tracker

## Scope and status
The repository snapshot does not include original reviewer files. This tracker records the action items enumerated in the paper prompt and their corresponding evidence status.

| Reviewer item | Concern summary | Evidence required | Evidence found | Status | Next action |
|---|---|---|---|---|---|
| 1 | Per-state power characterization | per-state power numbers and state description | `docs/power_domains.md`, `final/metrics.json` | not found | add a per-state power table to the paper and archive |
| 2 | Duty-cycle weighted power estimate | occupancy distribution and weighted estimates | no direct artifact found | not found | calculate from trace data and document assumptions |
| 3 | Fair baseline comparison | functionally comparable, same-flow baseline run with matched activity | No always-on design/run or matched full-design activity found; see `docs/power_characterization/phase3_baseline_report.md` | blocked | Define the always-on behavior, then produce and validate a paired same-flow run |
| 4 | Placeholder wording in figure captions | paper figure source and captions | No manuscript or caption source found; see `docs/evidence_archive/phase4_figure_audit.md` | blocked | Obtain the authoritative manuscript and caption source, then review unsupported claims |
| 5 | Figure artifact validation | traceable placement/CTS/routing artifacts and rendered figure source | Stage ODB/DEF/CTS/route/STA/GDS artifacts exist for both completed runs; no project-owned rendered figures; see `docs/evidence_archive/phase4_figure_audit.md` | partial | Obtain the manuscript/figure source and map each figure to its run and stage evidence |
| 6 | Sensor input abstraction | clear pre-digitized sensor contract | `README.md` and `docs/architecture.md` | partial | add explicit statement in manuscript |
| 7 | LoRa TX abstraction | scope statement | explicit README limitation table | verified | preserve the limitation statement |
| 8 | 2 KB history SRAM status | implementation status | `README.md` out-of-scope statement | partial | define future-work vs placeholder status |
| 9 | SA-ADC register contract | register map and RTL | `docs/register_map.md`, `rtl/sa_adc/sa_adc_controller.v` | partial | connect the register spec to the paper |
| 10 | Software load and memory implications | software/memory assumptions | not found | not found | define firmware assumptions and memory footprint |
| 11 | Agricultural dataset and synthetic trace limits | validation data and conclusions | `sim/traces`, `validate_plan` | partial | document limitations of synthetic traces |
| 12 | Register-file area tradeoff | design decision rationale | `docs/design_decisions.md` | partial | add explicit area tradeoff text |
| 13 | Scope distinction implemented vs future work | architecture and implementation contract | `README.md` explicit scope table | partial | keep distinction consistent throughout paper |

## Owner
Owner is `TBD` for all items unless explicitly assigned by the paper team.
