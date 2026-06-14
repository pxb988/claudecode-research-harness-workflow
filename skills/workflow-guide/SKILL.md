---
name: workflow-guide
description: "RES: Navigation entry point — explains which research-harness skill to invoke at each stage of an empirical study, from setup to release plus paper replication. Trigger: which skill do I use, where do I start, research workflow help, harness overview. Load this when the user is unsure which stage they are in."
description-en: "RES: Navigation entry point — which research-harness skill to invoke at each stage, setup to release plus replication. Trigger: which skill, where do I start, workflow help, harness overview."
kind: reference
purpose: "Route the researcher to the right skill for their current stage"
trigger: "which skill do I use, where do I start, research workflow help, harness overview, /workflow-guide"
shape: reference
role: navigator
owner: research-harness-core
since: "2026-06-13"
allowed-tools: ["Read"]
user-invocable: true
effort: low
---

# 工作流导航 —— 用哪个 skill、什么时候用

八个 skill 驱动一项实证研究。按你「手上有什么、下一步要什么」来挑。

## 七阶段流水线（完整研究）

| 阶段 | Skill | 在以下情形使用 |
|---|---|---|
| 1 | `/research-harness-setup` | 开始一个项目 —— 创建权威来源文件、标准目录结构、数据保护 |
| 2 | `/research-harness-audit` | 原始数据已放入 `1.rawdata/` —— 检查变量、缺失、ID、可行性 |
| 3 | `/research-harness-clean` | 审计完成 —— 清洗、重编码、合并为可分析数据集 |
| 4 | `/research-harness-plan` | 数据就绪 —— 把研究规格转成具体的分析计划 |
| 5 | `/research-harness-work` | 计划已批准 —— 执行一个分析任务（脚本 → 日志 → 输出） |
| 6 | `/research-harness-review` | 结果初稿完成 —— 核查数字、识别策略诚实性、数据保护 |
| 7 | `/research-harness-release` | 审稿 = APPROVE —— 组装复现/证据包 |

完整研究按顺序运行。每一步都把证据写入 `4.reports/` 并更新
`analysis_plan.md`。

## 复现捷径（独立使用）

| Skill | 在以下情形使用 |
|---|---|
| `/research-harness-replicate` | 你有一篇已发表的论文 + 原始面板，只想要论文用到的子样本。直接读原始元数据，无需完整清洗；并把你算出的均值与论文已发表的目标值做校验。 |

## skill 会自动查阅的知识
- `docs/references/datasets/<id>.md` —— 各数据集的文件命名 + 变量编码坑点。
- `docs/references/replications/<paper>.md` —— 各论文的概念→变量映射 + 目标均值。
- `docs/survey-pipeline-engineering.md` —— 宽面板的内存/dtype 工程规则。

新增一个文件 + 一条 `index.json` 记录即可扩展覆盖范围，无需改动 skill。

## 贯穿所有 skill 的唯一铁律
> **没有脚本，就没有日志；没有日志，就没有论断。** 每个数字都可追溯到一次脚本运行和磁盘上的日志。
