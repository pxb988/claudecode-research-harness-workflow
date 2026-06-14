#!/usr/bin/env python3
# build_codebook.py — 阶段 3：读取子样本，逐变量计算统计量，附上论文「已发表」的
# 目标均值，并标记 mean_match（CLOSE/MODERATE/DIFFERS）。
import sys, os, csv
try:
    import pandas as pd
except ImportError:
    sys.exit("需要 pandas")

SUBSAMPLE = "3.outdata/data/_11_subsample.csv"
OUT = "3.outdata/data/_12_codebook.csv"

# 从论文 Table 2 填入（只用已发表的值 —— 绝不用你自己跑出来的结果）：
PAPER_TARGETS = {}  # 例如 {"EDUCATION": 0.534, "MARITAL": 0.074}

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
            note = "" if label != "DIFFERS" else "需在进入回归前说明原因"
            w.writerow([var, "%.3f" % our, "%.3f" % target, label, note])
    print("build_codebook：已写入 %s（%d 个变量）" % (OUT, len(PAPER_TARGETS)))

if __name__ == "__main__":
    main()
