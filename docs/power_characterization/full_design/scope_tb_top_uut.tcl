set root "/workspace"
set run "$root/runs/RUN_2026-10-24_19-16-36"
set pdk "$root/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"

read_liberty "$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "$run/final/odb/agrisense_ipms_top.odb"
read_sdc "$run/final/sdc/agrisense_ipms_top.sdc"
read_spef "$run/final/spef/nom/agrisense_ipms_top.nom.spef"

puts "=== SCOPE TEST: tb_top/uut ==="
if {[catch {read_vcd -scope "tb_top/uut" "$root/build/power_characterization/full_design/awake_top_workload.vcd"} msg]} {
  puts "ANNOTATION_ERROR: $msg"
} else {
  puts "ANNOTATION_CALL_COMPLETED"
}
report_power
