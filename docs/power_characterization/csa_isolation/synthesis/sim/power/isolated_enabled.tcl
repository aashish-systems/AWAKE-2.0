read_lef /workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty /workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog /workspace/docs/power_characterization/csa_isolation/synthesis/isolated_sky130.v
link_design crop_stress_accelerator_isolated
create_clock -name core_clk -period 20.0 [get_ports clk]
read_vcd -scope tb_matched_gatelevel/isolated -begin_time 101000 -end_time 4101000 /workspace/docs/power_characterization/csa_isolation/synthesis/sim/matched_gatelevel.vcd
puts "=== Enabled-window power: isolated ==="
report_power -digits 9
