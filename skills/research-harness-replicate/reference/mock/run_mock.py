#!/usr/bin/env python3
# Mock replication run (CSV variant) — proves the discover -> subsample -> codebook
# pattern and the mean_match (CLOSE/MODERATE/DIFFERS) logic end-to-end, using only the
# Python standard library and a 6-row synthetic panel. No real data, no Stata, no deps.
import csv, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.join(HERE, "mock_panel.csv")

# Published target means for this MOCK paper (illustrative, not real):
PAPER_TARGETS = {"EDU_MIDDLE_PLUS": 0.67, "MARRIED": 0.50, "GENDER_FEMALE": 0.50}

def classify(diff):
    if diff < 0.02: return "CLOSE"
    if diff < 0.10: return "MODERATE"
    return "DIFFERS"

def main():
    with open(PANEL, newline="") as f:
        rows = list(csv.DictReader(f))
    # discover: report available columns (stand-in for .dta metadata scan)
    cols = list(rows[0].keys())
    sys.stderr.write("discover: columns = %s\n" % ",".join(cols))
    # subsample: construct analysis vars from documented encodings
    n = len(rows)
    edu = sum(1 for r in rows if int(r["education_code"]) >= 5) / n      # middle+ : code>=5
    married = sum(1 for r in rows if int(r["married_code"]) <= 2) / n    # married : code 1 or 2
    female = sum(1 for r in rows if int(r["gender"]) == 2) / n           # female : gender==2
    ours = {"EDU_MIDDLE_PLUS": edu, "MARRIED": married, "GENDER_FEMALE": female}
    # codebook: compare to published targets, classify
    out = os.path.join(HERE, "codebook_out.csv")
    with open(out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["variable", "our_mean", "paper_mean", "mean_match"])
        for v in ["EDU_MIDDLE_PLUS", "MARRIED", "GENDER_FEMALE"]:
            diff = abs(ours[v] - PAPER_TARGETS[v])
            w.writerow([v, "%.3f" % ours[v], "%.3f" % PAPER_TARGETS[v], classify(diff)])
    sys.stderr.write("codebook: wrote %s\n" % out)
    print("mock replication OK: N=%d, codebook=%s" % (n, out))

if __name__ == "__main__":
    main()
