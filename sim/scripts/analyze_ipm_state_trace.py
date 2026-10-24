#!/usr/bin/env python3
"""Validate a directed IPM FSM trace and summarize simulated state occupancy."""

import argparse
import csv
from collections import Counter
from pathlib import Path


STATE_NAMES = {
    0: "SLEEP",
    1: "MONITOR",
    2: "WARNING",
    3: "CRITICAL",
}
EXPECTED_OUTPUTS = {
    0: (0, 0, 0, 0, 0, 0, 0),
    1: (1, 1, 0, 0, 0, 0, 0),
    2: (1, 1, 1, 1, 1, 0, 0),
    3: (1, 1, 1, 1, 1, 1, 1),
}
EXPECTED_SEQUENCE = [0, 1, 2, 3, 2, 1]
RESET_PHASE = 0
EXPECTED_OPERATING_CYCLES = 81
CLOCK_PERIOD_NS = 20


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--trace",
        type=Path,
        default=Path("sim/power_characterization/state_trace.csv"),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/power_characterization/state_occupancy_results.csv"),
    )
    args = parser.parse_args()

    required = {
        "cycle",
        "phase",
        "state_code",
        "wake_timer",
        "stress_event",
        "leaf_valid",
        "leaf_severity",
        "sensor_en",
        "decde_en",
        "domain2_pwr_en",
        "csa_en",
        "dtree_en",
        "domain3_pwr_en",
        "comm_en",
    }
    with args.trace.open(newline="", encoding="utf-8") as trace_file:
        reader = csv.DictReader(trace_file)
        if set(reader.fieldnames or ()) != required:
            raise ValueError(f"Unexpected trace columns: {reader.fieldnames}")
        rows = list(reader)

    if not rows:
        raise ValueError("The state trace is empty")

    counts = Counter()
    phase_counts = Counter()
    observed_sequence = []
    previous_state = None
    for expected_cycle, row in enumerate(rows, start=1):
        cycle = int(row["cycle"])
        phase = int(row["phase"])
        state = int(row["state_code"])
        if cycle != expected_cycle:
            raise ValueError(f"Cycle sequence breaks at row {expected_cycle}: {cycle}")
        if state not in STATE_NAMES:
            raise ValueError(f"Unknown state code {state} at cycle {cycle}")

        outputs = tuple(
            int(row[name])
            for name in (
                "sensor_en",
                "decde_en",
                "domain2_pwr_en",
                "csa_en",
                "dtree_en",
                "domain3_pwr_en",
                "comm_en",
            )
        )
        if outputs != EXPECTED_OUTPUTS[state]:
            raise ValueError(
                f"State/output mismatch at cycle {cycle}: {state} {outputs}"
            )

        counts[state] += 1
        phase_counts[(phase, state)] += 1
        if state != previous_state:
            observed_sequence.append(state)
            previous_state = state

    if observed_sequence != EXPECTED_SEQUENCE:
        raise ValueError(f"Unexpected transition sequence: {observed_sequence}")
    if sum(counts.values()) - phase_counts[(RESET_PHASE, 0)] != EXPECTED_OPERATING_CYCLES:
        raise ValueError(f"Unexpected operating-cycle count: {counts}")
    if [counts[state] for state in range(4)] != [14, 32, 21, 16]:
        raise ValueError(f"Unexpected per-state sample counts: {counts}")

    transition_entries = Counter(observed_sequence[1:])
    output_rows = []
    for state, name in STATE_NAMES.items():
        total_cycles = counts[state]
        reset_cycles = phase_counts[(RESET_PHASE, state)]
        operating_cycles = total_cycles - reset_cycles
        steady_cycles = sum(
            count
            for (phase, observed_state), count in phase_counts.items()
            if observed_state == state and phase not in {RESET_PHASE, 2, 4, 6, 8, 11}
        )
        transition_cycles = operating_cycles - steady_cycles
        output_rows.append(
            {
                "state": name,
                "transition_entries": transition_entries[state],
                "reset_cycles_excluded": reset_cycles,
                "operating_cycles_including_transitions": operating_cycles,
                "steady_phase_cycles": steady_cycles,
                "transition_phase_cycles": transition_cycles,
                "operating_occupancy_fraction": f"{operating_cycles / EXPECTED_OPERATING_CYCLES:.8f}",
                "simulated_occupancy_ns_at_20ns_period": operating_cycles * CLOCK_PERIOD_NS,
                "state_outputs": "|".join(
                    str(bit) for bit in EXPECTED_OUTPUTS[state]
                ),
                "power_status": "unavailable",
                "energy_status": "unavailable",
            }
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as output_file:
        writer = csv.DictWriter(output_file, fieldnames=output_rows[0].keys())
        writer.writeheader()
        writer.writerows(output_rows)

    print(f"Trace valid: {len(rows)} sampled cycles including reset.")
    print(f"Operating workload: {EXPECTED_OPERATING_CYCLES} cycles at 20 ns/cycle.")
    print(f"Observed state sequence: {' -> '.join(STATE_NAMES[s] for s in observed_sequence)}")
    print(f"Occupancy summary: {args.output}")
    print("Power/energy: unavailable; this FSM-only simulation is not a power model.")


if __name__ == "__main__":
    main()
