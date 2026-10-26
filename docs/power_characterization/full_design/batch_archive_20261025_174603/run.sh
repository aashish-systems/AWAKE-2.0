#!/usr/bin/env bash
set -u

DB="/workspace/$A/baseline/agrisense_ipms_top.odb"
SDC="/workspace/$A/baseline/agrisense_ipms_top.sdc"
SPEF="/workspace/$A/baseline/agrisense_ipms_top.nom.spef"
VCD="/workspace/$OUT/gatelevel_workload.vcd"
LIB="$PDK/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

for spec in \
  "SLEEP_STABLE 110000 150000" \
  "MONITOR_STABLE 200000 280000" \
  "MONITOR_PRIMED 1400000 1600000" \
  "CRITICAL 2100000 2300000" \
  "WARNING 2380000 2540000" \
  "MONITOR_RECOVERY 2620000 2700000"
do
  read -r name begin end <<< "$spec"
  tcl="$BATCH/$name.tcl"
  log="$BATCH/$name.log"

  cat > "$tcl" <<TCL
read_liberty "$LIB"
read_db "$DB"
read_sdc "$SDC"
read_spef "$SPEF"
puts "=== WINDOW $name ${begin}-${end} ps ==="
read_vcd -scope tb_gatelevel_vcd/uut -begin_time $begin -end_time $end "$VCD"
report_activity_annotation -report_unannotated
report_power -digits 9
exit
TCL

  (
    cd /OpenROAD-flow-scripts
    source ./env.sh
    openroad -no_init -exit "/workspace/$tcl" \
      > "/workspace/$log" 2>&1
  ) &
done

wait
