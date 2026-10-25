set root "/workspace"
set run "$root/runs/RUN_2026-10-24_19-16-36"
set pdk "$root/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"

set stdlib "$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set odb "$run/final/odb/agrisense_ipms_top.odb"
set sdc "$run/final/sdc/agrisense_ipms_top.sdc"
set spef "$run/final/spef/nom/agrisense_ipms_top.nom.spef"
set vcd "$root/build/power_characterization/full_design/awake_top_workload.vcd"

puts "=== LOAD SKY130 STANDARD-CELL LIBRARY ==="
read_liberty $stdlib

puts "=== LOAD PHYSICAL DESIGN ==="
read_db $odb

puts "=== LOAD CONSTRAINTS ==="
read_sdc $sdc

puts "=== LOAD PARASITICS ==="
read_spef $spef

puts "=== CHECK DESIGN AND CLOCK ==="
puts "DESIGN_AND_CONSTRAINTS_LOADED"
report_checks -path_delay max -format summary

puts "=== READ_VCD COMMAND HELP ==="
if {[catch {help read_vcd} msg]} {
  puts "READ_VCD_HELP_RESULT: $msg"
}

puts "=== VCD ANNOTATION ATTEMPT ==="
if {[catch {read_vcd -scope tb_top.uut $vcd} msg]} {
  puts "VCD_ANNOTATION_FAILED: $msg"
} else {
  puts "VCD_ANNOTATION_COMMAND_ACCEPTED"
}

puts "=== POWER REPORT ==="
if {[catch {report_power} msg]} {
  puts "POWER_REPORT_FAILED: $msg"
} else {
  puts "POWER_REPORT_COMMAND_COMPLETED"
}
