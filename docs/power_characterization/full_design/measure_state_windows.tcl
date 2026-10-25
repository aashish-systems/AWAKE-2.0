set pdk "/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
set run "/workspace/runs/RUN_2026-10-24_19-16-36"
set out "/workspace/docs/power_characterization/full_design"
set vcd "$out/gatelevel_workload.vcd"

read_liberty "$pdk/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "$run/final/odb/agrisense_ipms_top.odb"
read_sdc "$run/final/sdc/agrisense_ipms_top.sdc"
read_spef "$run/final/spef/nom/agrisense_ipms_top.nom.spef"

# Each interval excludes the checkpoint itself and samples a later,
# steady-state portion where possible. Times are in VCD timescale units (ps).
foreach window {
    {SLEEP_INITIAL 60000 120000}
    {MONITOR_INITIAL 200000 280000}
    {MONITOR_PRIMED 1400000 1600000}
    {CRITICAL 2100000 2300000}
    {WARNING 2380000 2540000}
    {MONITOR_RECOVERY 2620000 2700000}
} {
    lassign $window name begin end
    puts "\n========== WINDOW $name ${begin}-${end} ps =========="

    # Re-read the same VCD restricted to this observation window.
    read_vcd -scope tb_gatelevel_vcd/uut \
        -begin_time $begin -end_time $end $vcd

    report_activity_annotation -report_unannotated
    report_power -digits 9
}
exit
