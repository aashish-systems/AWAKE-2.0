# Reviewer feedback summary

## Source of the review record
The prompt for Paper ID 815 enumerates the review action items. No independent reviewer file was found in the repository snapshot, so this file is a faithful reconstruction of the stated concerns from the prompt.

| # | Reviewer source | Exact concern | Required evidence | Existing artifact | Status | Next action | Owner |
|---|---|---|---|---|---|---|---|
| 1 | Prompt item 1 | Per-state power characterization for MONITOR, WARNING, and CRITICAL | per-state power numbers, activity assumptions | `docs/power_domains.md`, `final/metrics.json` | unverified | collect and document per-state switching/leakage by state | TBD |
| 2 | Prompt item 2 | State-occupancy distribution and duty-cycle-weighted power estimate | state occupancy vs time and weighted power calculation | no direct artifact found | unverified | add occupancy model and weighted estimate | TBD |
| 3 | Prompt item 3 | Same-flow always-on baseline for fair power/area comparison | baseline run or equivalent same-flow numbers | `flow/config.json`, `metrics.json` | partially verified | identify and document the baseline configuration | TBD |
| 4 | Prompt item 4 | Replace remaining placeholder wording in physical-implementation figure captions | final figure files and captions | no figure source found in repo | unverified | review final paper figures and caption wording | TBD |
| 5 | Prompt item 5 | Verify placement, CTS, routing, congestion, and worst-path figures are real artifacts | figure binaries or source files in repo | run directories contain raw OpenLane logs; no figure source found | partially verified | inspect the commit artifacts and raw report images | TBD |
| 6 | Prompt item 6 | Clarify that the sensor interface is abstracted and inputs are pre-digitized | architecture doc and sensor interface contract | `README.md`, `docs/architecture.md` | partially verified | add explicit interface/abstraction clause to paper | TBD |
| 7 | Prompt item 7 | Clarify LoRa TX path abstraction if not implemented in RTL | design docs and port definitions | `README.md` table states the LoRa block is not implemented | verified as an explicit scope statement | keep scope distinction in final manuscript | TBD |
| 8 | Prompt item 8 | Clarify the status of the 2 KB history SRAM | evidence of implementation status and area tradeoff | `README.md` states history SRAM is out of scope | partially verified | document whether the SRAM is future work, placeholder, or abstracted block | TBD |
| 9 | Prompt item 9 | Explain SA-ADC state machine, register interface, and polling/control assumptions | RTL and register map docs | `docs/register_map.md`, `rtl/sa_adc/sa_adc_controller.v` | partially verified | link the formal register map to the paper clarifications | TBD |
| 10 | Prompt item 10 | Discuss software load and memory implications where applicable | architecture and software assumptions | no software burden artifact found | unverified | document firmware assumptions and memory impacts | TBD |
| 11 | Prompt item 11 | Assess public agricultural time-series validation and synthetic-trace limitations | validation docs and data sources | `sim/traces/*.csv`, `sim/scripts/generate_traces.py`, `docs/validation_plan.md` | partially verified | document synthetic-trace limitations | TBD |
| 12 | Prompt item 12 | Document register-file area tradeoff and possible SRAM/latch alternatives | design decisions documentation | `docs/design_decisions.md`, `docs/register_map.md` | partially verified | add explicit tradeoff section to paper | TBD |
| 13 | Prompt item 13 | Distinguish implemented functionality, abstraction, and future work throughout the paper | architecture and implementation contract docs | `README.md`, `docs/architecture.md` | partially verified | standardize implementation-scope wording in manuscript | TBD |
