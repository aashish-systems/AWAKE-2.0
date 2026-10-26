set pdk "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
set baseline "/workspace/docs/power_characterization/csa_isolation/evidence_archive_20261025/baseline"
set vcd "/workspace/docs/power_characterization/full_design/gatelevel_workload.vcd"

read_liberty "$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "$baseline/agrisense_ipms_top.odb"
read_sdc "$baseline/agrisense_ipms_top.sdc"
read_spef "$baseline/agrisense_ipms_top.nom.spef"

puts "=== WINDOW MONITOR_RECOVERY 2565000-2705000 ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time 2565000 -end_time 2705000 "$vcd"
report_activity_annotation -report_unannotated
report_power -digits 12
exit
