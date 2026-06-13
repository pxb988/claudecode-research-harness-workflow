#!/usr/bin/env python3
# build_subsample.py — Stage 2: load ONLY needed columns per wave, apply the paper's
# sample filter, construct outcome/treatment/control variables, save analysis-ready.
# Construction rules come from docs/references/datasets/<id>.md + the paper. Adapt.
import sys, os
try:
    import pandas as pd, pyreadstat  # noqa: F401
except ImportError:
    sys.exit("pandas + pyreadstat required")

OUT_PARQUET = "3.outdata/data/_11_subsample.parquet"
OUT_CSV = "3.outdata/data/_11_subsample.csv"

def main():
    os.makedirs(os.path.dirname(OUT_PARQUET), exist_ok=True)
    # 1) Load only the columns confirmed by discover_vars (usecols), per wave.
    # 2) Apply the paper's sample filter (document every dropped count to a log).
    # 3) Construct variables using the documented encodings (e.g. BD001 >= 5 for
    #    "middle school and above"; coalesce preloaded Z-prefix vars for sparse fields).
    # 4) Save. (Body is a template — fill from the dataset reference + paper.)
    raise SystemExit("build_subsample is a reference template — implement per project, "
                     "then save to 3.outdata/data/ and log all dropped counts.")

if __name__ == "__main__":
    main()
