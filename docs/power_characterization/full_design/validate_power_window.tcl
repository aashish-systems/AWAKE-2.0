set pdk "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
set run "/workspace/runs/RUN_2026-10-24_19-16-36"
set out "/workspace/docs/power_characterization/full_design"

read_liberty "$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "$run/final/odb/agrisense_ipms_top.odb"
read_sdc "$run/final/sdc/agrisense_ipms_top.sdc"
read_spef "$run/final/spef/nom/agrisense_ipms_top.nom.spef"

puts "=== Baseline full-workload VCD ==="
read_vcd -scope tb_gatelevel_vcd/uut "$out/gatelevel_workload.vcd"
report_activity_annotation -report_unannotated

puts "=== Baseline full-workload power ==="
report_power -digits 9

exit
