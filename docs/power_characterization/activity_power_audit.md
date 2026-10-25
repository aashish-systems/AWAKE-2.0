# Activity-Driven Power Comparison: Readiness Audit

Generated: 2026-10-25T12:46:52+00:00

## 1. Production RTL Integrity
5a5d5618f1776dab29c38494518cacff9601822392c530fe2d4e0434b9a1b3fc  rtl/csa/crop_stress_accelerator.v

## 2. Available Tools
iverilog: /usr/bin/iverilog
vvp: /usr/bin/vvp
verilator: /usr/bin/verilator
yosys: /usr/bin/yosys
openroad: NOT FOUND ON PATH
sta: NOT FOUND ON PATH
python3: /home/codespace/.python/current/bin/python3
docker: /usr/bin/docker

## 3. Existing Power Characterization Files
docs/power_characterization/activity_provenance.md
docs/power_characterization/csa_isolation/csa_isolation.vcd
docs/power_characterization/csa_isolation/experiment_report.md
docs/power_characterization/csa_isolation/tb_csa_isolation.v
docs/power_characterization/full_design/activity_baseline.md
docs/power_characterization/full_design/activity_coverage_probe.log
docs/power_characterization/full_design/activity_coverage_probe.tcl
docs/power_characterization/full_design/activity_coverage_summary.txt
docs/power_characterization/full_design/annotate_gatelevel_vcd.log
docs/power_characterization/full_design/annotate_gatelevel_vcd.tcl
docs/power_characterization/full_design/annotate_probe.log
docs/power_characterization/full_design/annotate_probe.tcl
docs/power_characterization/full_design/full_workload_power_report.md
docs/power_characterization/full_design/gatelevel_functional_compile.log
docs/power_characterization/full_design/gatelevel_functional_hashes.sha256
docs/power_characterization/full_design/gatelevel_functional_sim
docs/power_characterization/full_design/gatelevel_functional_simulation.log
docs/power_characterization/full_design/gatelevel_sim
docs/power_characterization/full_design/gatelevel_simulation.log
docs/power_characterization/full_design/gatelevel_workload.vcd
docs/power_characterization/full_design/input_artifact_hashes.sha256
docs/power_characterization/full_design/isolated_power_windows_summary.log
docs/power_characterization/full_design/measure_full_vcd.log
docs/power_characterization/full_design/measure_full_vcd.tcl
docs/power_characterization/full_design/measure_state_windows.log
docs/power_characterization/full_design/measure_state_windows.tcl
docs/power_characterization/full_design/openroad_power_help.log
docs/power_characterization/full_design/openroad_power_help.tcl
docs/power_characterization/full_design/power_50mhz.log
docs/power_characterization/full_design/power_CRITICAL.log
docs/power_characterization/full_design/power_CRITICAL.tcl
docs/power_characterization/full_design/power_CRITICAL_retry.log
docs/power_characterization/full_design/power_MONITOR_PRIMED.log
docs/power_characterization/full_design/power_MONITOR_PRIMED.tcl
docs/power_characterization/full_design/power_MONITOR_PRIMED_retry.log
docs/power_characterization/full_design/power_MONITOR_RECOVERY.log
docs/power_characterization/full_design/power_MONITOR_RECOVERY.tcl
docs/power_characterization/full_design/power_MONITOR_RECOVERY_retry.log
docs/power_characterization/full_design/power_MONITOR_STABLE.log
docs/power_characterization/full_design/power_MONITOR_STABLE.tcl
docs/power_characterization/full_design/power_MONITOR_STABLE_retry.log
docs/power_characterization/full_design/power_SLEEP_STABLE.log
docs/power_characterization/full_design/power_SLEEP_STABLE.tcl
docs/power_characterization/full_design/power_SLEEP_STABLE_retry.log
docs/power_characterization/full_design/power_WARNING.log
docs/power_characterization/full_design/power_WARNING.tcl
docs/power_characterization/full_design/power_WARNING_retry.log
docs/power_characterization/full_design/power_evidence_status.md
docs/power_characterization/full_design/run_isolated_power_windows.sh
docs/power_characterization/full_design/scope_tb_top.log
docs/power_characterization/full_design/scope_tb_top.tcl
docs/power_characterization/full_design/scope_tb_top_uut.log
docs/power_characterization/full_design/scope_tb_top_uut.tcl
docs/power_characterization/full_design/simulation_50mhz.log
docs/power_characterization/full_design/tb_gatelevel_vcd.v
docs/power_characterization/full_design/tb_gatelevel_vcd_previous.v
docs/power_characterization/methodology.md
docs/power_characterization/phase2_execution_report.md
docs/power_characterization/phase3_baseline_report.md
docs/power_characterization/state_energy_results.csv
docs/power_characterization/state_occupancy_results.csv
docs/power_characterization/state_power_results.csv

## 4. Existing Physical Design Artifacts
FOUND runs/RUN_2026-10-24_19-16-36/final/odb/agrisense_ipms_top.odb
FOUND runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc
FOUND runs/RUN_2026-10-24_19-16-36/final/spef/nom/agrisense_ipms_top.nom.spef
FOUND runs/RUN_2026-10-24_19-16-36/final/nl/agrisense_ipms_top.nl.v
FOUND runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/nom_tt_025C_1v80/power.rpt

## 5. Existing Power-Analysis Scripts and Commands
docs/power_characterization/activity_power_audit.md
docs/power_characterization/activity_provenance.md
docs/power_characterization/csa_isolation/csa_isolation.vcd
docs/power_characterization/full_design/activity_baseline.md
docs/power_characterization/full_design/activity_coverage_probe.log
docs/power_characterization/full_design/activity_coverage_probe.tcl
docs/power_characterization/full_design/activity_coverage_summary.txt
docs/power_characterization/full_design/annotate_gatelevel_vcd.log
docs/power_characterization/full_design/annotate_gatelevel_vcd.tcl
docs/power_characterization/full_design/full_workload_power_report.md
docs/power_characterization/full_design/gatelevel_workload.vcd
docs/power_characterization/full_design/isolated_power_windows_summary.log
docs/power_characterization/full_design/measure_full_vcd.log
docs/power_characterization/full_design/measure_full_vcd.tcl
docs/power_characterization/full_design/openroad_power_help.log
docs/power_characterization/full_design/openroad_power_help.tcl
docs/power_characterization/full_design/power_50mhz.log
docs/power_characterization/full_design/power_CRITICAL.log
docs/power_characterization/full_design/power_CRITICAL.tcl
docs/power_characterization/full_design/power_CRITICAL_retry.log
docs/power_characterization/full_design/power_MONITOR_PRIMED.log
docs/power_characterization/full_design/power_MONITOR_PRIMED.tcl
docs/power_characterization/full_design/power_MONITOR_PRIMED_retry.log
docs/power_characterization/full_design/power_MONITOR_RECOVERY.log
docs/power_characterization/full_design/power_MONITOR_RECOVERY.tcl
docs/power_characterization/full_design/power_MONITOR_RECOVERY_retry.log
docs/power_characterization/full_design/power_MONITOR_STABLE.log
docs/power_characterization/full_design/power_MONITOR_STABLE.tcl
docs/power_characterization/full_design/power_MONITOR_STABLE_retry.log
docs/power_characterization/full_design/power_SLEEP_STABLE.log
docs/power_characterization/full_design/power_SLEEP_STABLE.tcl
docs/power_characterization/full_design/power_SLEEP_STABLE_retry.log
docs/power_characterization/full_design/power_WARNING.log
docs/power_characterization/full_design/power_WARNING.tcl
docs/power_characterization/full_design/power_WARNING_retry.log
docs/power_characterization/full_design/power_evidence_status.md
docs/power_characterization/full_design/run_isolated_power_windows.sh
docs/power_characterization/full_design/tb_gatelevel_vcd.v
docs/power_characterization/full_design/tb_gatelevel_vcd_previous.v
docs/power_characterization/state_power_results.csv

## 6. VCD Metadata
--- docs/power_characterization/full_design/gatelevel_workload.vcd ---
-rw-rw-rw- 1 codespace codespace 3.2M Oct 25 12:01 docs/power_characterization/full_design/gatelevel_workload.vcd
$date
	Sun Oct 25 12:01:00 2026
$end
$version
	Icarus Verilog
$end
$timescale
	1ps
$end
$scope module tb_gatelevel_vcd $end
$var wire 8 ! m_rdata [7:0] $end
$var wire 4 " leaf_output [3:0] $end
$var wire 2 # ipm_state [1:0] $end
$var wire 1 $ domain3_pwr_en $end
$var wire 1 % domain2_pwr_en $end
--- docs/power_characterization/csa_isolation/csa_isolation.vcd ---
-rw-rw-rw- 1 codespace codespace 71K Oct 25 12:40 docs/power_characterization/csa_isolation/csa_isolation.vcd
$date
	Sun Oct 25 12:40:49 2026
$end
$version
	Icarus Verilog
$end
$timescale
	1ps
$end
$scope module tb_csa_isolation $end
$var wire 1 ! isolated_valid $end
$var wire 8 " isolated_score [7:0] $end
$var wire 1 # baseline_valid $end
$var wire 8 $ baseline_score [7:0] $end
$var reg 8 % air_temp [7:0] $end

## 7. Existing Power Report Summary
# Gate-Level Full-Workload Power Characterization

- Corner: TT, 25°C, 1.8 V
- Activity source: gate-level VCD
- VCD SHA-256: 0d9e0bbcec7484ca088acbf5752d4690243db761cdea108db646d828bac37d39
- Physical run: RUN_2026-10-24_19-16-36
- Activity annotation: 26,395 pins; 0 unannotated
- Clock: 20 ns SDC; no clock-period warning on full-trace import
- Total estimated power: 2.943301108 mW
- Sequential: 1.435626647 mW
- Combinational: 0.104663850 mW
- Clock: 1.403011149 mW
- Leakage: 0.000049432 mW

## Limitations

- Full-workload estimate; not a sleep-only measurement.
- No verified greater-than-80% dynamic-power reduction claim.
- Requires equivalent baseline-versus-gated comparison for the target compute domain.

## Raw tool log

See measure_full_vcd.log in this directory.

## 8. Git Status
?? build_csa_isolation_sim
?? docs/power_characterization/activity_power_audit.md
?? docs/power_characterization/csa_isolation/
?? docs/power_characterization/full_design/
