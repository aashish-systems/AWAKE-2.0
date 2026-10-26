#!/usr/bin/env python3
import argparse
import csv
import re
from collections import defaultdict
from pathlib import Path


WINDOWS = (
    ("SLEEP_STABLE", 125000, 165000, "00", "0", "0", "0"),
    ("MONITOR_STABLE", 225000, 285000, "01", "0", "0", "0"),
    ("MONITOR_PRIMED", 1405000, 1545000, "01", "0", "0", "0"),
    ("CRITICAL", 1945000, 2105000, "11", "1", "1", "1"),
    ("WARNING", 2185000, 2445000, "10", "1", "0", "0"),
    ("MONITOR_RECOVERY", 2565000, 2705000, "01", "0", "0", "0"),
)


def read_vcd(path):
    lines = path.read_text(errors="replace").splitlines()
    scope = []
    ids = {}
    events = defaultdict(list)
    time_ps = 0
    timescale = None
    timescale_match = re.search(
        r"\$timescale\s+(\d+)\s*(fs|ps|ns|us|ms|s)\s+\$end",
        "\n".join(lines[:80]),
        re.IGNORECASE,
    )
    if timescale_match:
        timescale = (int(timescale_match.group(1)), timescale_match.group(2).lower())

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("$scope"):
            scope.append(stripped.split()[2])
        elif stripped.startswith("$upscope"):
            if scope:
                scope.pop()
        elif stripped.startswith("$var"):
            parts = stripped.split()
            if len(parts) >= 6 and scope == ["tb_gatelevel_vcd"]:
                name = parts[4]
                if name in {"clk", "ipm_state", "domain2_pwr_en", "domain3_pwr_en", "comm_en_out"}:
                    ids[name] = (parts[3], int(parts[2]))
        elif stripped.startswith("#"):
            time_ps = int(stripped[1:])
        elif stripped and stripped[0] in "01xXzZ" and stripped[1:] in {
            ident for ident, _ in ids.values()
        }:
            events[stripped[1:]].append((time_ps, stripped[0].lower()))
        elif stripped.startswith("b"):
            parts = stripped.split()
            if len(parts) == 2 and parts[1] in {
                ident for ident, _ in ids.values()
            }:
                width = next(width for ident, width in ids.values() if ident == parts[1])
                events[parts[1]].append((time_ps, parts[0][1:].lower().zfill(width)))

    missing = {"clk", "ipm_state", "domain2_pwr_en", "domain3_pwr_en", "comm_en_out"} - ids.keys()
    if missing:
        raise ValueError(f"VCD top-level scope is missing signals: {sorted(missing)}")
    return ids, events, time_ps, timescale


def value_at(events, ident, when):
    value = None
    for timestamp, new_value in events[ident]:
        if timestamp > when:
            break
        value = new_value
    return value


def stable_values(events, ident, begin, end):
    values = {value_at(events, ident, begin)}
    values.update(
        value for timestamp, value in events[ident]
        if begin < timestamp < end
    )
    values.discard(None)
    return values


def validate_trace(path):
    ids, events, duration, timescale = read_vcd(path)
    clock_edges = [
        timestamp for timestamp, value in events[ids["clk"][0]]
        if value == "1"
    ]
    periods = [
        second - first for first, second in zip(clock_edges, clock_edges[1:])
    ]
    if not periods or set(periods) != {20000}:
        raise ValueError(f"VCD clock rising-edge intervals are not all 20000 ps: {sorted(set(periods))}")

    results = {}
    for name, begin, end, state, d2, d3, comm in WINDOWS:
        expected = {
            "ipm_state": state,
            "domain2_pwr_en": d2,
            "domain3_pwr_en": d3,
            "comm_en_out": comm,
        }
        errors = []
        if begin % 20000 != end % 20000 or begin % 10000 == 0:
            errors.append("window boundaries do not span complete clock cycles")
        for signal, required in expected.items():
            observed = stable_values(events, ids[signal][0], begin, end)
            if observed != {required}:
                errors.append(f"{signal} observed {sorted(observed)}, expected {required}")
        results[name] = {
            "begin": begin,
            "end": end,
            "duration": end - begin,
            "state": state,
            "d2": d2,
            "d3": d3,
            "comm": comm,
            "errors": errors,
        }
    return results, len(clock_edges), sorted(set(periods)), duration, timescale


def parse_log(path):
    text = path.read_text(errors="replace")
    annotation = re.findall(r"^Annotated\s+(\d+) pin activities", text, re.MULTILINE)
    unannotated = re.findall(r"^unannotated\s+(\d+)\s*$", text, re.MULTILINE | re.IGNORECASE)
    totals = re.findall(
        r"^Total\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)",
        text,
        re.MULTILINE,
    )
    warnings = re.findall(r"^\[WARNING[^\]]*\]", text, re.MULTILINE)
    errors = re.findall(r"^\[ERROR[^\]]*\]|^Error:", text, re.MULTILINE)
    return {
        "annotation": int(annotation[-1]) if annotation else None,
        "unannotated": int(unannotated[-1]) if unannotated else None,
        "power": totals[-1] if totals else None,
        "warning_count": len(warnings),
        "errors": errors,
        "log": text,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    trace = args.root / "docs/power_characterization/full_design/gatelevel_workload.vcd"
    validated, edges, periods, duration, timescale = validate_trace(trace)
    (args.out / "vcd_validation.txt").write_text(
        "VCD: docs/power_characterization/full_design/gatelevel_workload.vcd\n"
        "VCD scope used for gate-level pin annotation: tb_gatelevel_vcd/uut\n"
        f"Timescale: {timescale}\n"
        f"Last timestamp: {duration} (timescale units)\n"
        f"Clock rising edges: {edges}\n"
        f"Unique rising-edge intervals (ps): {periods}\n"
        "Windows: every state and enable signal was checked for constancy over [start,end).\n"
        + "\n".join(
            f"{name}: {result['begin']}-{result['end']} ps state={result['state']} "
            f"d2={result['d2']} d3={result['d3']} comm={result['comm']} "
            f"validation={'PASS' if not result['errors'] else '; '.join(result['errors'])}"
            for name, result in validated.items()
        )
        + "\n"
    )

    columns = [
        "implementation", "state", "start_ps", "end_ps", "duration_ps",
        "state_code", "domain2_pwr_en", "domain3_pwr_en", "comm_en_out",
        "vcd_scope", "clock_period_ns", "annotated_pins", "unannotated_pins",
        "internal_power_w", "switching_power_w", "leakage_power_w",
        "total_power_w", "clock_power_w", "warning_count", "validity", "status",
    ]
    output = args.out / "state_power_results.csv"
    with output.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        for name, window in validated.items():
            log_path = args.out / "raw" / f"{name}.log"
            if not log_path.exists():
                raise FileNotFoundError(f"Missing raw OpenROAD log: {log_path}")
            report = parse_log(log_path)
            errors = list(window["errors"])
            if report["annotation"] is None or report["unannotated"] is None or report["power"] is None:
                errors.append("missing activity annotation or power report")
            if report["unannotated"] not in (None, 0):
                errors.append("unannotated pins are present")
            errors.extend(report["errors"])

            validity = "INVALID" if errors else "PROVISIONAL"
            status = (
                "; ".join(errors)
                if errors
                else "state_window_verified; full_pin_annotation; directed_workload; "
                     "source_to_netlist_provenance_unverified; no_matched_always_on_baseline"
            )
            powers = report["power"] or ("", "", "", "")
            clock_rows = re.findall(
                r"^Clock\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)\s+([0-9.eE+-]+)",
                report["log"],
                re.MULTILINE,
            )
            writer.writerow({
                "implementation": "archived_full_design_implementation",
                "state": name,
                "start_ps": window["begin"],
                "end_ps": window["end"],
                "duration_ps": window["duration"],
                "state_code": window["state"],
                "domain2_pwr_en": window["d2"],
                "domain3_pwr_en": window["d3"],
                "comm_en_out": window["comm"],
                "vcd_scope": "tb_gatelevel_vcd/uut",
                "clock_period_ns": "20",
                "annotated_pins": report["annotation"] if report["annotation"] is not None else "",
                "unannotated_pins": report["unannotated"] if report["unannotated"] is not None else "",
                "internal_power_w": powers[0],
                "switching_power_w": powers[1],
                "leakage_power_w": powers[2],
                "total_power_w": powers[3],
                "clock_power_w": clock_rows[-1][3] if clock_rows else "",
                "warning_count": report["warning_count"],
                "validity": validity,
                "status": status,
            })


if __name__ == "__main__":
    main()
