#!/usr/bin/env python3
# discover_vars.py — 复现的阶段 1：只扫描原始 .dta 的元数据（绝不读全量数据），
# 跨各 wave/模块；记录每个名称或 label 命中关键词的变量；导出一份被标记的变量清单。
# 请按你的项目调整加载器与路径。
import sys, csv, os
try:
    import pyreadstat
except ImportError:
    sys.exit("需要 pyreadstat：pip install pyreadstat --only-binary :all:")

# 按你的数据集修改以下内容（见 docs/references/datasets/<id>.md）：
RAW_DIR = "1.rawdata"                 # 项目相对路径，只读
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
    print("discover_vars：已写入 %d 行到 %s" % (len(rows), OUT))

if __name__ == "__main__":
    main()
