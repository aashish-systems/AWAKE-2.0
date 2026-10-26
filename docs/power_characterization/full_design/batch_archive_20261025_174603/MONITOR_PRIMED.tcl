read_liberty "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "/workspace/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.odb"
read_sdc "/workspace/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.sdc"
read_spef "/workspace/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline/agrisense_ipms_top.nom.spef"
puts "=== WINDOW MONITOR_PRIMED 1400000-1600000 ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time 1400000 -end_time 1600000 "/workspace/docs/power_characterization/full_design/gatelevel_workload.vcd"
report_activity_annotation -report_unannotated
report_power -digits 9
exit
