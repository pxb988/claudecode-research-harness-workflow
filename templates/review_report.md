# 科研审稿报告

> 由 `/research-harness-review` 生成。这是一次只读审稿——未运行或修改任何脚本。
> 审稿人只读取既有的日志和产出。任何数字若不能追溯到日志文件，就不得出现在本报告中。
> 将本报告归档于 `4.reports/review_report.md`。

---

## 审稿元信息

- **日期：** YYYY-MM-DD
- **审稿人：** Claude Code（只读）
- **受审研究规格说明：** `study_spec.md`
- **受审分析计划：** `analysis_plan.md`
- **受审脚本：** （列出）
- **受审日志：** （列出）
- **受审产出：** （列出）
- **受审清洗报告：** `4.reports/data_cleaning_report.md`
- **受审合并报告：** `4.reports/merge_report.md`

---

## 1. 识别可信度

| 维度 | 评估 | 证据 |
|---|---|---|
| study_spec.md 中陈述的设计 | | |
| 关键假设可检验 / 部分可检验 | | |
| 是否有安慰剂或证伪检验 | YES / NO / not applicable | |
| 平行趋势或可比的前趋势（针对 DiD） | | |
| 排他性约束可信度（针对 IV） | | |
| 带宽敏感性（针对 RD） | | |

**识别可信度结论：** `strong` / `moderate` / `weak` / `insufficient`

**说明：**
unknown

---

## 2. 模型设定一致性

| 检查项 | 结果 | 备注 |
|---|---|---|
| 估计量与 study_spec.md §2 一致 | YES / NO | |
| 结果变量与 study_spec.md §4 一致 | YES / NO | |
| 协变量与 study_spec.md §4 一致 | YES / NO | |
| 样本限制条件与 study_spec.md §5 一致 | YES / NO | |
| 固定效应 / 聚类与设定一致 | YES / NO | |

**模型一致性结论：** `aligned` / `minor deviations` / `major deviations`

**偏离（如有）：**
unknown

---

## 3. 数值准确性

对每一个报告的数字，核验它确实出现在对应的日志文件中。

| 论断 | 报告值 | 日志文件 | 日志中的值 | 是否一致 |
|---|---|---|---|---|
| N（主样本） | | | | YES / NO |
| 主系数 | | | | YES / NO |
| p 值 | | | | YES / NO |
| （按需添加行） | | | | |

**任何无法追溯到日志的数字都标记为未经验证。**

**未经验证的数字：**
none / （列出）

---

## 4. 数据清洗完整性

| 检查项 | 结果 | 备注 |
|---|---|---|
| 清洗报告存在 | YES / NO | |
| 合并报告存在（若发生过合并） | YES / NO / not applicable | |
| 全部丢弃已记录 | YES / NO | |
| 全部合并都有前后行数 | YES / NO | |
| 原始数据未被修改 | YES / NO | （用 `git status 1.rawdata/` 或等价方式检查） |

---

## 5. 因果论断评估

列出在产出或中间报告中发现的每一项因果论断。

| 论断 | 位置 | 所用识别标签 | 评估 |
|---|---|---|---|
| | | `[descriptive]` / `[correlational]` / `[quasi-experimental]` / `[experimental]` | appropriate / overstated / understated |

**夸大的因果论断（发布前必须更正）：**
none / （列出）

---

## 6. 幻觉与捏造检查

| 检查项 | 结果 | 备注 |
|---|---|---|
| 所有引用可追溯到真实来源 | YES / NO / not checked | |
| 所有样本量与日志一致 | YES / NO | |
| 没有结果在缺乏对应日志的情况下被声称 | YES / NO | |
| 规格说明中列出的稳健性检验都已包含 | YES / NO | |

---

## 7. 发现

### 关键发现（APPROVE 前必须解决）

| # | 发现 | 位置 | 必需的处理 |
|---|---|---|---|
| | | | |

### 重要发现（应当解决；可能阻塞 APPROVE）

| # | 发现 | 位置 | 建议 |
|---|---|---|---|
| | | | |

### 次要发现（提示性）

| # | 发现 | 位置 | 建议 |
|---|---|---|---|
| | | | |

---

## 8. 结论

**APPROVE** — 所有关键和重要发现已解决；证据链完整。

**REQUEST_CHANGES** — 有一项或多项关键或重要发现需在发布前解决。

**结论：** `APPROVE` / `REQUEST_CHANGES`

**APPROVE 的条件（若为 REQUEST_CHANGES）：**
unknown
