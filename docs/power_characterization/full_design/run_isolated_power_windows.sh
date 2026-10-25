#!/usr/bin/env bash
set -uo pipefail

OUT="docs/power_characterization/full_design"
PDK="/workspace/build/openlane/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
RUN="/workspace/runs/RUN_2026-10-24_19-16-36"
VCD="$OUT/gatelevel_workload.vcd"

measure_window() {
    local name="$1" begin="$2" end="$3"
    local tcl="$OUT/power_${name}.tcl"
    local log="$OUT/power_${name}.log"

    cat > "$tcl" <<TCL
read_liberty "$PDK/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "$RUN/final/odb/agrisense_ipms_top.odb"
read_sdc "$RUN/final/sdc/agrisense_ipms_top.sdc"
read_spef "$RUN/final/spef/nom/agrisense_ipms_top.nom.spef"
puts "=== WINDOW $name ${begin}-${end} ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time $begin -end_time $end "$VCD"
report_activity_annotation -report_unannotated
report_power -digits 9
exit
TCL

    echo "=== Measuring $name: ${begin}-${end} ps ==="
    docker run --rm --entrypoint /bin/bash \
      -v "$PWD:/workspace" -w /workspace \
      openroad/orfs:latest \
      -lc "cd /OpenROAD-flow-scripts && source ./env.sh && openroad -no_init -exit /workspace/$tcl" \
      > "$log" 2>&1 || echo "ERROR: $name failed; inspect $log"

    grep -E 'WINDOW|clock clk vcd period|Annotated|unannotated|^Total|Error|Warning' "$log" || true
    echo
}

# Windows are in VCD timescale units (1 ps).
# SLEEP window is after reset release and before the wake sequence.
measure_window SLEEP_STABLE 110000 150000
measure_window MONITOR_STABLE 200000 280000
measure_window MONITOR_PRIMED 1400000 1600000
measure_window CRITICAL 2100000 2300000
measure_window WARNING 2380000 2540000
measure_window MONITOR_RECOVERY 2620000 2700000
