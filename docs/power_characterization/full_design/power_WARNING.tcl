read_liberty "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "/workspace/runs/RUN_2026-10-24_19-16-36/final/odb/agrisense_ipms_top.odb"
read_sdc "/workspace/runs/RUN_2026-10-24_19-16-36/final/sdc/agrisense_ipms_top.sdc"
read_spef "/workspace/runs/RUN_2026-10-24_19-16-36/final/spef/nom/agrisense_ipms_top.nom.spef"
puts "=== WINDOW WARNING 2380000-2540000 ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time 2380000 -end_time 2540000 "/workspace/docs/power_characterization/full_design/gatelevel_workload.vcd"
report_activity_annotation -report_unannotated
report_power -digits 9
exit
