#!/usr/bin/env python3
# build_subsample.py — 阶段 2：每个 wave 只加载需要的列，套用论文的样本筛选条件，
# 构造结果/处理/控制变量，保存为可分析数据。
# 构造规则来自 docs/references/datasets/<id>.md + 论文。请按需调整。
import sys, os
try:
    import pandas as pd, pyreadstat  # noqa: F401
except ImportError:
    sys.exit("需要 pandas + pyreadstat")

OUT_PARQUET = "3.outdata/data/_11_subsample.parquet"
OUT_CSV = "3.outdata/data/_11_subsample.csv"

def main():
    os.makedirs(os.path.dirname(OUT_PARQUET), exist_ok=True)
    # 1) 每个 wave 只加载 discover_vars 已确认的列（usecols）。
    # 2) 套用论文的样本筛选条件（把每一次丢弃的数量都记录到日志）。
    # 3) 用文档记载的编码规则构造变量（例如 BD001 >= 5 表示「初中及以上」；
    #    对稀疏字段用预加载的 Z 前缀变量做 coalesce 合并）。
    # 4) 保存。（函数体是模板 —— 请按数据集 reference + 论文填写。）
    raise SystemExit("build_subsample 是一份 reference 模板 —— 请按项目实现，"
                     "然后保存到 3.outdata/data/ 并记录所有丢弃数量。")

if __name__ == "__main__":
    main()
