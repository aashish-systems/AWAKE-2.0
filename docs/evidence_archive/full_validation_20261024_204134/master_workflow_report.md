# AWAKE-2.0 Full Validation Report

- Timestamp: 20261024_204134
- Branch: main
- Starting HEAD: c830aed944b8e821e1f37321656bfac4ca4c9b53
- Remote: https://github.com/aashish-systems/AWAKE-2.0
- Working tree was recorded before this script created its outputs.

## 1. Initial Git state
```
 M docs/evidence_archive/INVENTORY.md
 M docs/evidence_archive/archive_log.md
 M docs/evidence_archive/paper_claim_audit.md
 M docs/evidence_archive/run_comparison.md
 M docs/evidence_archive/tool_versions.md
 M flow/config.json
 M rtl/csa/crop_stress_accelerator.v
?? docs/evidence_archive/full_validation_20261024_204134/
?? docs/evidence_archive/signoff_claim_matrix.md
?? flow/config.json.bak
?? scripts/run_awake_full_validation.sh
```

## 2. Tool availability
- python3: /home/codespace/.python/current/bin/python3
- jq: /usr/bin/jq
- sha256sum: /usr/bin/sha256sum
- git: /usr/local/bin/git
- openlane: unavailable
- openroad: unavailable
- yosys: /usr/bin/yosys
- iverilog: /usr/bin/iverilog
- verilator: /usr/bin/verilator
- magic: unavailable
- klayout: unavailable
- netgen: unavailable
- pdflatex: unavailable
- latexmk: unavailable

## 3. Existing evidence documents
- FOUND: `docs/evidence_archive/INVENTORY.md`
- FOUND: `docs/evidence_archive/artifact_manifest.csv`
- FOUND: `docs/evidence_archive/run_comparison.md`
- FOUND: `docs/evidence_archive/paper_claim_audit.md`
- FOUND: `docs/evidence_archive/signoff_claim_matrix.md`
- FOUND: `docs/evidence_archive/tool_versions.md`
- FOUND: `docs/reviews/awake_paper_815/remediation_tracker.md`

### RUN_2026-10-24_17-48-54

- Directory: `runs/RUN_2026-10-24_17-48-54`
- Resolved configuration:
{
  "DESIGN_NAME": "agrisense_ipms_top",
  "CLOCK_PERIOD": 20,
  "CLOCK_PORT": "clk",
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY_PCT": 50
}

- Final metrics:
{
  "design__instance__count": 6343,
  "design__instance__area": 71208.2944,
  "design__core__area": null,
  "design__instance__utilization": null,
  "timing__setup__ws": null,
  "timing__setup__tns": null,
  "timing__setup_vio__count": null,
  "power__total": null,
  "antenna__violating__nets": null,
  "route__drc_errors": null,
  "magic__drc_error__count": null,
  "klayout__drc_error__count": null,
  "design__lvs_error__count": null,
  "design__lvs_device_difference__count": null,
  "design__lvs_net_difference__count": null,
  "design__lvs_property_fail__count": null
}

- Final SDC clock constraints:
No final SDC directory.

- Signoff evidence files:
runs/RUN_2026-10-24_17-48-54/06-yosys-synthesis/reports/stat.rpt

### RUN_2026-10-24_17-54-09

- Directory: `runs/RUN_2026-10-24_17-54-09`
- Resolved configuration:
{
  "DESIGN_NAME": "agrisense_ipms_top",
  "CLOCK_PERIOD": 20,
  "CLOCK_PORT": "clk",
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY_PCT": 50
}

- Final metrics:
{
  "design__instance__count": 9822,
  "design__instance__area": 71217.1,
  "design__core__area": 177839,
  "design__instance__utilization": 0.400457,
  "timing__setup__ws": -1.6932535852710704,
  "timing__setup__tns": -11.565447593641487,
  "timing__setup_vio__count": 29,
  "power__total": 0.013314031064510345,
  "antenna__violating__nets": 4,
  "route__drc_errors": 0,
  "magic__drc_error__count": 0,
  "klayout__drc_error__count": 0,
  "design__lvs_error__count": 0,
  "design__lvs_device_difference__count": 0,
  "design__lvs_net_difference__count": 0,
  "design__lvs_property_fail__count": 0
}

- Final SDC clock constraints:
runs/RUN_2026-10-24_17-54-09/final/sdc/agrisense_ipms_top.sdc:8:create_clock -name clk -period 20.0000 [get_ports {clk}]
runs/RUN_2026-10-24_17-54-09/final/sdc/agrisense_ipms_top.sdc:10:set_clock_uncertainty 0.2500 clk

- Signoff evidence files:
runs/RUN_2026-10-24_17-54-09/06-yosys-synthesis/reports/stat.rpt
runs/RUN_2026-10-24_17-54-09/12-openroad-staprepnr/nom_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_17-54-09/12-openroad-staprepnr/nom_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_17-54-09/12-openroad-staprepnr/nom_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_17-54-09/30-openroad-stamidpnr/power.rpt
runs/RUN_2026-10-24_17-54-09/35-openroad-stamidpnr-1/power.rpt
runs/RUN_2026-10-24_17-54-09/37-openroad-stamidpnr-2/power.rpt
runs/RUN_2026-10-24_17-54-09/38-openroad-globalrouting/antenna.rpt
runs/RUN_2026-10-24_17-54-09/39-openroad-checkantennas/openroad-checkantennas.log
runs/RUN_2026-10-24_17-54-09/39-openroad-checkantennas/openroad-checkantennas.process_stats.json
runs/RUN_2026-10-24_17-54-09/39-openroad-checkantennas/reports/antenna.rpt
runs/RUN_2026-10-24_17-54-09/39-openroad-checkantennas/reports/antenna_summary.rpt
runs/RUN_2026-10-24_17-54-09/41-openroad-repairantennas/2-openroad-checkantennas/openroad-checkantennas.log
runs/RUN_2026-10-24_17-54-09/41-openroad-repairantennas/2-openroad-checkantennas/openroad-checkantennas.process_stats.json
runs/RUN_2026-10-24_17-54-09/41-openroad-repairantennas/2-openroad-checkantennas/reports/antenna.rpt
runs/RUN_2026-10-24_17-54-09/41-openroad-repairantennas/2-openroad-checkantennas/reports/antenna_summary.rpt
runs/RUN_2026-10-24_17-54-09/42-openroad-stamidpnr-3/power.rpt
runs/RUN_2026-10-24_17-54-09/43-openroad-detailedrouting/agrisense_ipms_top.drc
runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/openroad-checkantennas-1.log
runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/openroad-checkantennas-1.process_stats.json
runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/reports/antenna.rpt
runs/RUN_2026-10-24_17-54-09/45-openroad-checkantennas-1/reports/antenna_summary.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/max_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/min_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/min_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/min_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/nom_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/nom_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/nom_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_17-54-09/59-odb-checkdesignantennaproperties/odb-checkdesignantennaproperties.log
runs/RUN_2026-10-24_17-54-09/59-odb-checkdesignantennaproperties/odb-checkdesignantennaproperties.process_stats.json
runs/RUN_2026-10-24_17-54-09/62-magic-drc/magic-drc.log
runs/RUN_2026-10-24_17-54-09/62-magic-drc/magic-drc.process_stats.json
runs/RUN_2026-10-24_17-54-09/62-magic-drc/reports/drc_violations.magic.rpt
runs/RUN_2026-10-24_17-54-09/62-magic-drc/reports/drc_violations.magic.xml
runs/RUN_2026-10-24_17-54-09/62-magic-drc/views/agrisense_ipms_top.drc.mag
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/klayout-drc.log
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/klayout-drc.process_stats.json
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/reports/drc_violations.klayout.json
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/reports/drc_violations.klayout.xml
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/xml_drc_report_to_json.log
runs/RUN_2026-10-24_17-54-09/63-klayout-drc/xml_drc_report_to_json.process_stats.json
runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/lvs_script.lvs
runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/netgen-lvs.log
runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/netgen-lvs.process_stats.json
runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/reports/lvs.netgen.json
runs/RUN_2026-10-24_17-54-09/68-netgen-lvs/reports/lvs.netgen.rpt

### RUN_2026-10-24_19-16-36

- Directory: `runs/RUN_2026-10-24_19-16-36`
- Resolved configuration:
{
  "DESIGN_NAME": "agrisense_ipms_top",
  "CLOCK_PERIOD": 20,
  "CLOCK_PORT": "clk",
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY_PCT": 50
}

- Final metrics:
{
  "design__instance__count": 9894,
  "design__instance__area": 71996.6,
  "design__core__area": 180158,
  "design__instance__utilization": 0.399631,
  "timing__setup__ws": 0.6247749161531793,
  "timing__setup__tns": 0,
  "timing__setup_vio__count": 0,
  "power__total": 0.012208886444568634,
  "antenna__violating__nets": 11,
  "route__drc_errors": 0,
  "magic__drc_error__count": 0,
  "klayout__drc_error__count": 0,
  "design__lvs_error__count": 0,
  "design__lvs_device_difference__count": 0,
  "design__lvs_net_difference__count": 0,
  "design__lvs_property_fail__count": 0
}

- Final SDC clock constraints:
runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc:8:create_clock -name clk -period 20.0000 [get_ports {clk}]
runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc:10:set_clock_uncertainty 0.2500 clk

- Signoff evidence files:
runs/RUN_2026-10-24_19-16-36/06-yosys-synthesis/reports/stat.rpt
runs/RUN_2026-10-24_19-16-36/12-openroad-staprepnr/nom_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_19-16-36/12-openroad-staprepnr/nom_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_19-16-36/12-openroad-staprepnr/nom_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_19-16-36/30-openroad-stamidpnr/power.rpt
runs/RUN_2026-10-24_19-16-36/35-openroad-stamidpnr-1/power.rpt
runs/RUN_2026-10-24_19-16-36/37-openroad-stamidpnr-2/power.rpt
runs/RUN_2026-10-24_19-16-36/38-openroad-globalrouting/antenna.rpt
runs/RUN_2026-10-24_19-16-36/39-openroad-checkantennas/openroad-checkantennas.log
runs/RUN_2026-10-24_19-16-36/39-openroad-checkantennas/openroad-checkantennas.process_stats.json
runs/RUN_2026-10-24_19-16-36/39-openroad-checkantennas/reports/antenna.rpt
runs/RUN_2026-10-24_19-16-36/39-openroad-checkantennas/reports/antenna_summary.rpt
runs/RUN_2026-10-24_19-16-36/41-openroad-repairantennas/2-openroad-checkantennas/openroad-checkantennas.log
runs/RUN_2026-10-24_19-16-36/41-openroad-repairantennas/2-openroad-checkantennas/openroad-checkantennas.process_stats.json
runs/RUN_2026-10-24_19-16-36/41-openroad-repairantennas/2-openroad-checkantennas/reports/antenna.rpt
runs/RUN_2026-10-24_19-16-36/41-openroad-repairantennas/2-openroad-checkantennas/reports/antenna_summary.rpt
runs/RUN_2026-10-24_19-16-36/42-openroad-stamidpnr-3/power.rpt
runs/RUN_2026-10-24_19-16-36/43-openroad-detailedrouting/agrisense_ipms_top.drc
runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/openroad-checkantennas-1.log
runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/openroad-checkantennas-1.process_stats.json
runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/reports/antenna.rpt
runs/RUN_2026-10-24_19-16-36/45-openroad-checkantennas-1/reports/antenna_summary.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/max_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/min_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/min_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/min_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ff_n40C_1v95/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_ss_100C_1v60/power.rpt
runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_tt_025C_1v80/power.rpt
runs/RUN_2026-10-24_19-16-36/59-odb-checkdesignantennaproperties/odb-checkdesignantennaproperties.log
runs/RUN_2026-10-24_19-16-36/59-odb-checkdesignantennaproperties/odb-checkdesignantennaproperties.process_stats.json
runs/RUN_2026-10-24_19-16-36/62-magic-drc/magic-drc.log
runs/RUN_2026-10-24_19-16-36/62-magic-drc/magic-drc.process_stats.json
runs/RUN_2026-10-24_19-16-36/62-magic-drc/reports/drc_violations.magic.rpt
runs/RUN_2026-10-24_19-16-36/62-magic-drc/reports/drc_violations.magic.xml
runs/RUN_2026-10-24_19-16-36/62-magic-drc/views/agrisense_ipms_top.drc.mag
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/klayout-drc.log
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/klayout-drc.process_stats.json
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/reports/drc_violations.klayout.json
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/reports/drc_violations.klayout.xml
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/xml_drc_report_to_json.log
runs/RUN_2026-10-24_19-16-36/63-klayout-drc/xml_drc_report_to_json.process_stats.json
runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/lvs_script.lvs
runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/netgen-lvs.log
runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/netgen-lvs.process_stats.json
runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/reports/lvs.netgen.json
runs/RUN_2026-10-24_19-16-36/68-netgen-lvs/reports/lvs.netgen.rpt

### Archive manifest integrity
Manifest: docs/evidence_archive/artifact_manifest.csv
Manifest columns: ['artifact_path', 'category', 'run_id', 'size_bytes', 'sha256', 'git_status', 'archive_status', 'notes']
Hash checked: 2435
Missing files: 0
Hash mismatches: 0
Rows without recognized path/hash fields: 0

## 4. Per-state power and energy characterization

This script does not invent state-specific power. It inventories available aggregate power reports and relevant simulation/activity artifacts.

A state-specific result requires verified MONITOR, WARNING, and CRITICAL state occupancy, reproducible stimulus, and suitable activity-annotated power analysis. Aggregate `power__total` is not a substitute for state-specific power.

Required future outputs:
- `docs/power_characterization/methodology.md`
- `docs/power_characterization/state_power_results.csv`
- `docs/power_characterization/state_energy_results.csv`
- `docs/power_characterization/activity_provenance.md`

Until these measurements exist, state-specific power and energy remain UNVERIFIED.

## 5. Always-on baseline

Baseline candidate paths are listed in `baseline_candidates.txt`. The presence of a baseline file is not proof of a fair comparison.

A valid comparison requires the same technology/library corner, voltage, temperature, timing constraints, activity assumptions, measurement interval, and comparable functional workload.

No power savings should be claimed until the baseline and event-driven design have comparable, reproducible measurements.

## 6. Figure and manuscript provenance

Candidate files are listed in `figure_source_candidates.txt` and `figure_inventory.csv`.

The inventory is not an assertion that every PDF is a manuscript or every image is a paper figure. Inspect the actual manuscript and determine figure-to-run provenance before changing captions.

Figures must not claim 116.15 MHz, zero antenna violations, measured state power, or baseline savings unless the relevant evidence proves those claims.

## 7. Generated audit outputs
- Claim and metric inventory: `docs/evidence_archive/full_validation_20261024_204134/claim_evidence_matrix.csv`
- Figure inventory: `docs/evidence_archive/full_validation_20261024_204134/figure_inventory.csv`
- Power evidence inventory: `docs/evidence_archive/full_validation_20261024_204134/power_evidence_inventory.csv`
- Baseline evidence inventory: `docs/evidence_archive/full_validation_20261024_204134/baseline_evidence_inventory.csv`
- Power-related files: `docs/evidence_archive/full_validation_20261024_204134/power_related_file_list.txt`
- Baseline candidates: `docs/evidence_archive/full_validation_20261024_204134/baseline_candidates.txt`
- Figure/manuscript candidates: `docs/evidence_archive/full_validation_20261024_204134/figure_source_candidates.txt`
- Gate checklist: `docs/evidence_archive/full_validation_20261024_204134/next_actions.md`

## 8. Validation status

This script inventories and validates available evidence. It does not claim that state-specific power characterization, a fair always-on baseline, figure remediation, or manuscript revision has been experimentally completed.

## 9. Git state after audit
```
 M docs/evidence_archive/INVENTORY.md
 M docs/evidence_archive/archive_log.md
 M docs/evidence_archive/paper_claim_audit.md
 M docs/evidence_archive/run_comparison.md
 M docs/evidence_archive/tool_versions.md
 M flow/config.json
 M rtl/csa/crop_stress_accelerator.v
?? docs/evidence_archive/full_validation_20261024_204134/
?? docs/evidence_archive/signoff_claim_matrix.md
?? flow/config.json.bak
?? scripts/run_awake_full_validation.sh
```

- Ending HEAD: c830aed944b8e821e1f37321656bfac4ca4c9b53
- Remote push: not attempted by this script.

## 10. Required manual review
Inspect every generated file and complete the phase gates in `next_actions.md` before claiming the project is camera-ready.
