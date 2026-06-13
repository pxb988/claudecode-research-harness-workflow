#!/usr/bin/env python3
# build_codebook.py — Stage 3: read the subsample, compute per-variable stats, attach
# the paper's PUBLISHED target means, and flag mean_match (CLOSE/MODERATE/DIFFERS).
import sys, os, csv
try:
    import pandas as pd
except ImportError:
    sys.exit("pandas required")

SUBSAMPLE = "3.outdata/data/_11_subsample.csv"
OUT = "3.outdata/data/_12_codebook.csv"

# Fill from the paper's Table 2 (published values only — never your own achieved runs):
PAPER_TARGETS = {}  # e.g. {"EDUCATION": 0.534, "MARITAL": 0.074}

def classify(diff):
    if diff < 0.02: return "CLOSE"
    if diff < 0.10: return "MODERATE"
    return "DIFFERS"

def main():
    df = pd.read_csv(SUBSAMPLE)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["variable", "our_mean", "paper_mean", "mean_match", "notes"])
        for var, target in PAPER_TARGETS.items():
            our = float(df[var].mean())
            label = classify(abs(our - target))
            note = "" if label != "DIFFERS" else "EXPLAIN before regression-ready"
            w.writerow([var, "%.3f" % our, "%.3f" % target, label, note])
    print("build_codebook: wrote %s (%d vars)" % (OUT, len(PAPER_TARGETS)))

if __name__ == "__main__":
    main()
