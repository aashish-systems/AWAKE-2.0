puts "=== OpenROAD power-analysis capability check ==="
puts "OpenROAD version: [ord::openroad_version]"
puts "=== Load Sky130 Liberty ==="
read_liberty /workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
puts "PASS: Liberty loaded"
puts "=== Check report_power ==="
help report_power
puts "=== Check read_vcd ==="
help read_vcd
puts "=== Capability check complete ==="
