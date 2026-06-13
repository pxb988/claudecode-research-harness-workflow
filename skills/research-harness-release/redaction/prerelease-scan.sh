#!/usr/bin/env bash
# prerelease-scan.sh — scan a release/ package for research-data leakage before sharing.
# No third-party deps. Exits 1 on any hit (fail-loud); 0 if clean.
# Usage: bash prerelease-scan.sh <release-dir>
set -uo pipefail
dir="${1:-release}"
[ -d "$dir" ] || { echo "prerelease-scan: '$dir' not found"; exit 2; }
hits=0
report() { echo "LEAK[$1]: $2"; hits=$((hits+1)); }

# 1) private absolute paths
m=$(grep -rInE 'C:\\Users\\|/Users/[a-z]|/home/[a-z]|\.conda[\\/]envs' "$dir" 2>/dev/null) && [ -n "$m" ] && report "private-path" "$m"
# 2) data-file extensions inside the package (microdata must never ship)
m=$(find "$dir" -type f \( -name '*.dta' -o -name '*.parquet' -o -name '*.sas7bdat' -o -name '*.rds' -o -name '*.feather' \) 2>/dev/null) && [ -n "$m" ] && report "data-file" "$m"
# 3) codebook files (variable-level metadata)
m=$(find "$dir" -type f -iname '*codebook*' 2>/dev/null) && [ -n "$m" ] && report "codebook" "$m"
# 4) raw microdata copied into the package
[ -d "$dir/1.rawdata" ] && report "raw-dir" "$dir/1.rawdata present in package"

if [ "$hits" -gt 0 ]; then echo "prerelease-scan: FAIL ($hits leak signal(s))"; exit 1; fi
echo "prerelease-scan: PASS (no leakage signals)"
