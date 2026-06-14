# 示例：基础数据清洗

本示例以一份合成的家庭调查 CSV 文件，带你走一遍 Research Agent Harness 的审计与清洗阶段。

---

## 本示例演示了什么

| 阶段 | 命令 | 产出 |
|---|---|---|
| Setup | `/research-harness-setup` | `study_spec.md`、文件夹结构 |
| Audit | `/research-harness-audit` | `4.reports/data_audit_report.md` |
| Clean | `/research-harness-clean` | `3.outdata/data/households_clean.csv`、`4.reports/data_cleaning_report.md` |

---

## 文件结构

```
basic-data-cleaning/
├── README.md                               ← 你在这里
├── study_spec.md                           ← 本示例已预填
├── 1.rawdata/
│   └── households.csv                      ← 合成数据（200 行）
├── 4.reports/
│   └── data_cleaning_plan.md               ← 已预填的清洗方案
└── 0.dofiles/
    └── clean_households.R                  ← 清洗脚本骨架
```

运行 harness 命令之后，将生成以下文件：

```
├── 3.outdata/data/households_clean.csv
├── 0.dofiles/logs/audit_YYYYMMDD.log
├── 0.dofiles/logs/clean_YYYYMMDD.log
└── 4.reports/
    ├── data_audit_report.md
    └── data_cleaning_report.md
```

---

## 快速上手

```bash
/research-harness-audit
# 查看 4.reports/data_audit_report.md
# 然后：
/research-harness-clean
```

---

## 值得留意之处

- 审计报告会标记 `income_annual` 使用了 `-9` 作为缺失码
- 审计报告会标记 `hh_size` 有 3 个异常值（> 15）
- 清洗脚本会删除 8 条 `hhid` 缺失的观测
- 清洗脚本会把收入变量中的 `-9` 重编码为 `NA`
- 最终的 `3.outdata/data/households_clean.csv` 有 183 行（200 − 8 缺失 ID − 9 超范围地区）
- 每一条被删除的观测都会记录删除理由与数量
