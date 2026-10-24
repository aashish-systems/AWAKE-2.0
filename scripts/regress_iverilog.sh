#!/usr/bin/env bash
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$REPO_ROOT/build/sim"
rm -rf "$WORK_DIR"; mkdir -p "$WORK_DIR"

# Every bench must end with "TEST PASSED <module>"; a bench that only prints
# signals, exits early or reports FAIL/ERROR/FATAL is a failure.
RTL_SOURCES=(
  "$REPO_ROOT"/rtl/common/*.v
  "$REPO_ROOT"/rtl/decde/*.v
  "$REPO_ROOT"/rtl/csa/*.v
  "$REPO_ROOT"/rtl/dt/*.v
  "$REPO_ROOT"/rtl/ipm/*.v
  "$REPO_ROOT"/rtl/sa_adc/*.v
  "$REPO_ROOT"/rtl/top/*.v
)

total=0
passed=0
failed=0
skipped=0

for bench in "$REPO_ROOT"/tb/*.v; do
  if [[ ! -s "$bench" ]]; then
    printf 'SKIP_EMPTY %s\n' "${bench#"$REPO_ROOT"/}"
    skipped=$((skipped + 1))
    continue
  fi

  top="$(sed -n 's/^[[:space:]]*module[[:space:]]\+\([A-Za-z0-9_]*\).*/\1/p' "$bench" | head -1)"
  if [[ -z "$top" ]]; then
    printf 'FAIL_NO_TOP %s\n' "${bench#"$REPO_ROOT"/}"
    failed=$((failed + 1))
    continue
  fi

  total=$((total + 1))
  compile_log="$WORK_DIR/$top.compile.log"
  run_log="$WORK_DIR/$top.run.log"
  executable="$WORK_DIR/$top"

  if ! iverilog -g2012 -I "$REPO_ROOT/rtl/common" -s "$top" \
    -o "$executable" "${RTL_SOURCES[@]}" "$bench" >"$compile_log" 2>&1; then
    printf 'FAIL_COMPILE %s\n' "${bench#"$REPO_ROOT"/}"
    sed -n '1,8p' "$compile_log"
    failed=$((failed + 1))
    continue
  fi

  if ! (cd "$WORK_DIR" && vvp -n "$executable") >"$run_log" 2>&1; then
    printf 'FAIL_SIM %s\n' "${bench#"$REPO_ROOT"/}"
    sed -n '1,8p' "$run_log"
    failed=$((failed + 1))
    continue
  fi

  if grep -Eiq '(^|[^[:alpha:]])(FAIL|ERROR|FATAL)([^[:alpha:]]|$)' "$run_log"; then
    printf 'FAIL_ASSERTION %s\n' "${bench#"$REPO_ROOT"/}"
    grep -Ei 'FAIL|ERROR|FATAL' "$run_log" | head -5
    failed=$((failed + 1))
    continue
  fi

  if ! grep -qx "TEST PASSED $top" "$run_log"; then
    printf 'FAIL_NO_PASS_MARKER %s\n' "${bench#"$REPO_ROOT"/}"
    tail -5 "$run_log"
    failed=$((failed + 1))
    continue
  fi

  printf 'PASS %s\n' "${bench#"$REPO_ROOT"/}"
  passed=$((passed + 1))
done

printf 'SUMMARY total=%d passed=%d failed=%d skipped_empty=%d artifacts=%s\n' \
  "$total" "$passed" "$failed" "$skipped" "$WORK_DIR"

[[ "$failed" -eq 0 ]]