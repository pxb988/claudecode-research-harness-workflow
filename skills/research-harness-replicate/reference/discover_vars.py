#!/usr/bin/env python3
# discover_vars.py — Stage 1 of replication: scan raw .dta METADATA only (never full
# data) across waves/modules; log every variable whose name OR label matches keywords;
# export a flagged variable list. Adapt loader/paths to your project.
import sys, csv, os
try:
    import pyreadstat
except ImportError:
    sys.exit("pyreadstat required: pip install pyreadstat --only-binary :all:")

# EDIT THESE for your dataset (see docs/references/datasets/<id>.md):
RAW_DIR = "1.rawdata"                 # project-relative, read-only
KEYWORDS = ["educ", "marit", "gender", "insur", "hukou"]
OUT = "3.outdata/data/_10_var_list.csv"

def find_dta(root):
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if fn.lower().endswith(".dta"):
                yield os.path.join(dp, fn)

def main():
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    rows = []
    for path in find_dta(RAW_DIR):
        _, meta = pyreadstat.read_dta(path, metadataonly=True)
        for name, label in zip(meta.column_names, meta.column_labels or []):
            hay = (name + " " + (label or "")).lower()
            flagged = any(k in hay for k in KEYWORDS)
            rows.append([os.path.basename(os.path.dirname(path)), os.path.basename(path), name, label or "", flagged])
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["wave", "file", "var_name", "label", "flagged"]); w.writerows(rows)
    print("discover_vars: wrote %d rows to %s" % (len(rows), OUT))

if __name__ == "__main__":
    main()
