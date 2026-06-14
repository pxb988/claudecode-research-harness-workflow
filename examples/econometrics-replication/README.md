# 示例：计量经济学复制（DiD）

本示例以一份合成的双重差分数据集，带你走一遍 Research Agent Harness 的全部 7 个阶段。该研究考察某区域职业培训项目是否提高了家庭收入。

所有数据均为合成数据，其中的数字没有实际意义。

---

## 研究设计

- **设计：** 交错双重差分（Staggered difference-in-differences）
- **处理：** 区域职业培训项目的推行（随地区和年份而变化）
- **结果：** 家庭年收入
- **识别：** `[quasi-experimental: DiD]` — 平行趋势假设
- **数据：** 需要合并的两个文件（面板结果 + 政策时点）

---

## 本示例演示了什么

| 阶段 | 命令 | 演示内容 |
|---|---|---|
| 1 | `/research-harness-setup` | 创建规格与文件夹结构 |
| 2 | `/research-harness-audit` | 审计两个文件、识别合并键 |
| 3 | `/research-harness-clean` | 合并 面板 + 政策 文件、完整合并报告 |
| 4 | `/research-harness-plan` | 生成含 DiD 任务的分析方案 |
| 5 | `/research-harness-work 1.1` | 描述性统计表 |
| 5 | `/research-harness-work 2.1` | 主 DiD 回归 |
| 5 | `/research-harness-work 3.1` | 稳健性：替代设定 |
| 6 | `/research-harness-review` | 识别审查 + 数值核验 |
| 7 | `/research-harness-release` | 复制包组装 |

---

## 文件结构

```
econometrics-replication/
├── README.md                                     ← 你在这里
├── study_spec.md                                 ← 已预填的 DiD 研究规格
├── 1.rawdata/
│   ├── panel_outcomes.csv                        ← 合成面板（家庭 × 年份）
│   └── policy_timing.csv                         ← 按 地区 × 年份 的处理推行
├── 4.reports/
│   └── data_cleaning_plan.md                     ← 已预填的合并方案
└── 0.dofiles/
    ├── clean_merge.R                             ← 合并脚本骨架
    ├── analysis_descriptive.R                   ← 描述性统计脚本骨架
    ├── analysis_main_did.R                      ← DiD 回归脚本骨架
    └── analysis_robustness.R                    ← 稳健性脚本骨架
```

运行完整工作流之后，将生成以下文件：

```
├── 3.outdata/data/panel_analysis.csv
├── 0.dofiles/logs/
├── 3.outdata/tables/
├── 3.outdata/figures/
└── 4.reports/
    ├── data_audit_report.md
    ├── data_cleaning_report.md
    ├── merge_report.md
    ├── review_report.md
    └── reproducibility_report.md
```

---

## 快速上手

```bash
/research-harness-setup
/research-harness-audit
/research-harness-clean
/research-harness-plan
/research-harness-work 1.1
/research-harness-work 2.1
/research-harness-work 3.1
/research-harness-review
/research-harness-release
```

---

## 关于合并值得留意之处

- `panel_outcomes.csv` 每行对应一个 家庭 × 年份（hhid、year、income_annual、region）
- `policy_timing.csv` 每行对应一个 地区 × 年份，带有一个处理指示变量
- 合并为 `m:1`：每个 地区-年份 的处理值对应多条 家庭-年份 观测
- 合并报告会显示：面板 600 行 × 政策 20 行 → 合并后 600 行，匹配率 100%
- 合并后派生 `treated = (policy_active == 1)` 与 `post = (year >= treat_year)`

---

## 关于 DiD 审查值得留意之处

- 审查会检查识别标签 `[quasi-experimental: DiD]` 是否出现在脚本头部
- 审查会检查 `analysis_plan.md` 中是否存在事前趋势检验任务
- 审查会核验输出表中的所有系数都出现在日志文件中
- 任何在缺少 DiD 标签的情况下声称"因果效应"的说法，都会被标记为重大发现
