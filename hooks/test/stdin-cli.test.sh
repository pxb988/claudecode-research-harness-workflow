#!/usr/bin/env bash
# End-to-end: pipe real JSON into each hook's stdin, assert stdout decision.
set -uo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
check() { # $1=desc $2=expected-substr-or-EMPTY $3=actual
  if [ -z "$2" ]; then
    if [ -z "$3" ]; then echo "ok: $1"; pass=$((pass+1)); else echo "FAIL: $1 (expected empty, got: $3)"; fail=$((fail+1)); fi
  else
    case "$3" in *"$2"*) echo "ok: $1"; pass=$((pass+1));; *) echo "FAIL: $1 (want '$2', got: $3)"; fail=$((fail+1));; esac
  fi
}
# guard-raw-data: deny write to 1.rawdata
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"1.rawdata/x.csv"}}' | node "$here/guard-raw-data.js")
check "raw-data denies 1.rawdata" "deny" "$out"
# guard-raw-data: empty stdin must not crash, no output
out=$(printf '' | node "$here/guard-raw-data.js"); check "raw-data empty stdin no-op" "" "$out"
# guard-raw-data: broken JSON must not crash, no output
out=$(printf 'not json' | node "$here/guard-raw-data.js"); check "raw-data bad json no-op" "" "$out"
# guard-git-add: deny add of dta
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"git add panel.dta"}}' | node "$here/guard-git-add.js")
check "git-add denies dta" "deny" "$out"
# guard-git-add: allow examples synthetic csv
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"git add examples/x/data/raw/households.csv"}}' | node "$here/guard-git-add.js")
check "git-add allows examples csv" "" "$out"
# remind-evidence: reminder when no log
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"Rscript 0.dofiles/clean.R"}}' | node "$here/remind-evidence.js")
check "remind fires without log" "Reminder" "$out"
echo "stdin-cli: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
