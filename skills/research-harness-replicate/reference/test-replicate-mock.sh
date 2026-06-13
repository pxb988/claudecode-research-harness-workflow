#!/usr/bin/env bash
# Run the mock replication and assert its codebook matches the expected output.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

# Pick a Python that ACTUALLY runs (on Windows, `python3` is often a Store stub that
# prints nothing). Verify by running a sentinel and checking its output.
PY=""
for c in python3 python py; do
  command -v "$c" >/dev/null 2>&1 || continue
  if [ "$("$c" -c 'print(42)' 2>/dev/null)" = "42" ]; then PY="$c"; break; fi
done
[ -n "$PY" ] || { echo "FAIL: no working python interpreter found"; exit 1; }

"$PY" "$here/mock/run_mock.py" >/dev/null 2>&1 || { echo "FAIL: mock run errored"; exit 1; }
# --strip-trailing-cr: csv.writer emits CRLF on Windows; ignore CR so LF-committed
# expected_codebook.csv still matches byte-for-byte on content (adversarial review).
if diff -u --strip-trailing-cr "$here/mock/expected_codebook.csv" "$here/mock/codebook_out.csv"; then
  echo "replicate-mock: PASS ($PY)"
  rm -f "$here/mock/codebook_out.csv"
else
  echo "replicate-mock: FAIL (codebook mismatch)"; exit 1
fi
