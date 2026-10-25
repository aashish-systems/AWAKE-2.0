set run "/workspace/runs/RUN_2026-10-24_19-16-36"

read_db "$run/final/odb/agrisense_ipms_top.odb"

puts "=== CSA-related physical instances ==="
set matches 0

foreach inst [get_cells *] {
    set name [get_full_name $inst]
    if {[regexp -nocase {csa|weighted_sum|u_csa} $name]} {
        puts $name
        incr matches
    }
}

puts "CSA_NAME_MATCH_COUNT=$matches"
exit
