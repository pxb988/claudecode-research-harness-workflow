#!/usr/bin/env bash
# Run all node-based hook unit tests. No third-party deps — plain node assert.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
fail=0
for t in "$here"/*.test.js; do
  [ -e "$t" ] || continue
  echo "── $t"
  node "$t" || fail=1
done
for t in "$here"/*.test.sh; do
  [ -e "$t" ] || continue
  echo "── $t"
  bash "$t" || fail=1
done
if [ "$fail" -ne 0 ]; then echo "HOOK TESTS: FAIL"; exit 1; fi
echo "HOOK TESTS: PASS"
