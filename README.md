<a href="https://doi.org/10.5281/zenodo.20453003"><img src="https://zenodo.org/badge/1252855897.svg" alt="DOI"></a>

# Claude Code Research Harness Workflow

> **面向 Agent 辅助实证研究的受控执行框架。**
> 在可审计、可复现的流程里走完实证研究全程——审查原始数据 → 清洗合并 → 构造指标 → 分析 → 审阅 → 复制包，每一步强制留下证据。

**作者：** 朱 晨 \| 遗传社科研究 Chen Zhu \| China Agricultural University (CAU)　·　**最后更新：** 2026-06-13

<p align="center">
  <strong>Setup → Audit → Clean → Plan → Work → Review → Release</strong><br>
  <strong>定义问题 → 审查数据 → 清洗合并 → 制定计划 → 执行分析 → 审阅结果 → 发布复制包</strong>
</p>

<p align="center">
  <img alt="Status" src="https://img.shields.io/badge/status-research--harness-blue">
  <img alt="Raw data" src="https://img.shields.io/badge/raw%20data-read--only-critical">
  <img alt="Evidence" src="https://img.shields.io/badge/evidence-required-success">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-lightgrey">
</p>

> **No script, no log, no claim. — 没有脚本，没有日志，就没有结论。**

软件 Harness 约束 Agent 写代码，追求"代码通过测试"；**Research Harness 约束 Agent 做研究，追求"结论经得起追溯"**。这是一个投入均衡的完整七阶段实证研究 Harness——数据清洗与指标生成是其中扎实的核心支柱，论文复现是主流程之外的独立模式。

> 🔰 **第一次使用、完全没接触过这套流程?** 先读 [入门指南](docs/入门指南.md)——手把手带你用一个现成例子跑完第一个研究项目。

---

## 快速上手

> 第一次用、社科背景、不是程序员？跟着下面三步走即可；想要带完整例子的逐步详解，看 **[入门指南](docs/入门指南.md)**。

**前置（开始前确认）：**
- **Claude Code** 与 **git** 已就绪，且你会打开 Claude Code 并和它对话。
- 装好一种**分析语言运行时**——**R / Stata / Python 任一**即可（主流程未指定语言时默认 R）。**论文复现模式**额外需要 Python（含读取 `.dta` 的依赖）。不确定怎么装？[入门指南的「前置检查」](docs/入门指南.md#0-这份指南给谁--你需要先准备什么)附了官方下载链接。

### Step 1 · 安装插件（项目级）

「项目目录」= 你**这个研究项目的文件夹**（不是本插件仓库）。先 `cd` 进去，在那里启动 Claude Code，再输入下面两行：

```text
/plugin marketplace add pxb988/claudecode-research-harness-workflow
/plugin install claudecode-research-harness-workflow
```

- 第一行：把本插件的「市场」地址告诉 Claude Code。
- 第二行：从该市场安装插件到当前项目。

**怎么确认装好了：** 开始输入 `/research-harness` 时，应能看到 9 个技能(8 个 `/research-harness-*` 功能技能 + `/workflow-guide` 导航)被提示出来。若没看到，多半是没在本项目启用——见[常见问题](docs/入门指南.md#7-常见问题--出错怎么办)。

### Step 2 · 初始化并开工

```text
/research-harness-setup
```

它会生成 canonical 布局（标准文件夹结构）、项目治理 `CLAUDE.md`、数据保护 `.gitignore`，以及项目级 `.claude/settings.json`（启用插件 + 数据保护权限），并在原始数据放入 `1.rawdata/` 后为其施加 OS 只读锁。

**怎么确认成功：** 项目里出现 `0.dofiles/`、`1.rawdata/`、`2.workdata/`、`3.outdata/`、`4.reports/` 等目录，以及 `study_spec.md`、`analysis_plan.md`。之后按 `audit → clean → plan → work → review → release` 顺序推进即可（每阶段详解见[入门指南](docs/入门指南.md#3-手把手跑完一个完整项目主线)）。

### 让协作者克隆即得插件（可选）

**你不用手写任何配置**——上一步的 `setup` 已经在项目里生成了 `.claude/settings.json`（若该文件已存在，则把下列字段合并进去，不覆盖你原有设置）。它的关键就是这两段：

```json
{
  "extraKnownMarketplaces": {
    "research-harness": {
      "source": { "source": "github", "repo": "pxb988/claudecode-research-harness-workflow" }
    }
  },
  "enabledPlugins": ["claudecode-research-harness-workflow"]
}
```

- `extraKnownMarketplaces` 告诉 Claude Code 去哪里找这个插件，`enabledPlugins` 声明本项目启用它。
- **「提交」就是把这个文件用 git 纳入版本库：**

  ```bash
  git add .claude/settings.json
  git commit -m "chore: 启用 research-harness 插件"
  ```

这样别人 `git clone` 你的项目、信任其设置后，**无需再走 Step 1 安装**，就自动得到同一个插件和同一套数据防护。

> **不确定该用哪个技能？运行 `/workflow-guide`。**

> 可选：把 output style 设为 **Harness Ops**——运行 `/config` 选 Output style，或在项目 `.claude/settings.json` 设 `outputStyle`，获得 Plan / Work / Review 的结构化进度输出。

---

## 七阶段参考

完整生命周期，也可从任意中间阶段进入（见"模块化使用"）。

| # | 阶段 · 命令 | 输入 | 产出 | 强制 · 留痕 |
|---:|---|---|---|---|
| 1 | `setup` | — | `study_spec.md`、`analysis_plan.md`、canonical 布局、治理 `CLAUDE.md` | 建立研究合同与原始数据保护规则 |
| 2 | `audit` | `1.rawdata/` | `4.reports/data_audit_report.md` | **只读**；不改原始数据；评估设计可行性 |
| 3 | `clean` | 原始数据 + 审查报告 | `2.workdata/`、`3.outdata/data/`、清洗报告、`merge_report.md` | 每步 drop/recode/reshape/merge 留痕；merge 必报诊断 |
| 4 | `plan` | `study_spec.md` + 审查报告 + 清洗后结构 | `analysis_plan.md`（任务台账） | 研究者批准后方可执行 |
| 5 | `work <id>` / `work all` | 已批准的 `analysis_plan.md` | 脚本、日志、表格、图形 | 任务达 `cc:done` 须脚本·日志·输出·证据路径齐全 |
| 6 | `review` | 全部产出 | `4.reports/review_report.md` | **只读**；每个数字须可追溯；判定 APPROVE / REQUEST_CHANGES / BLOCK |
| 7 | `release` | review = APPROVE | `release/` 复制包 + `reproducibility_report.md` | 仅 APPROVE 后可发；机密数据未批准不入包 |

实操要点：

- **`clean` 每次 merge 必报：** 合并键 / 合并前后行数 / 匹配·未匹配数 / 重复键诊断 / 变量冲突 / 未解决问题。合并键不明确则停止询问，不靠猜测继续。
- **`work` 的 `cc:done`：** 脚本存在、已运行、日志存在、预期输出存在、且证据路径已写入 `analysis_plan.md`——五者缺一不可。反复失败标 `cc:blocked` 并报告原因，绝不编造输出。
- **`review` 三结论：** `APPROVE`（证据链足够，可发布）/ `REQUEST_CHANGES`（仍有重要问题，需修改后重审）/ `BLOCK`（严重失败，如数字不可验证或因果声明无支撑）。

> 想了解每阶段的目的与交接契约，见 [`docs/RESEARCH-WORKFLOW.md`](docs/RESEARCH-WORKFLOW.md)（英文）。

---

## 🔒 自动强制层

Harness 不只是 prompt 约束——它由**代码强制**。三层兜底：OS 只读锁 + hooks + agents，**跨所有阶段全局生效**，不依赖当前所处阶段。

**3 个 hooks（自动拦截 / 提醒）：**

| 钩子 | 触发时机 | 拦截或提醒什么 |
|---|---|---|
| `guard-raw-data` | 写入 / 编辑文件前 | **拒绝**对 `1.rawdata/`、`data/raw/` 的任何写入或编辑——原始数据只读，须改写到 `2.workdata/` 或 `3.outdata/`（`examples/` 除外） |
| `guard-git-add` | 执行 `git add` 前 | **拒绝**把数据文件（`.csv/.parquet/.dta/.sas7bdat/.rds/.feather`）或 `1.rawdata/`、`2.workdata/`、`3.outdata/data/` 下文件加入暂存（`examples/`、`3.outdata/tables/` 与 `figures/` 除外） |
| `remind-evidence` | 运行脚本后 | 检测到 R/Stata/Python 脚本运行但无日志重定向时，**提醒**：每次运行须在 `0.dofiles/logs/` 留日志，标记完成前先确认日志存在 |

**2 个子 agent：**

- **`analyst`** — 驱动 `work` 阶段：写并运行 R / Stata / Python 脚本、保存日志与输出、更新 `analysis_plan.md` 证据台账。**从不编造数字，从不修改原始数据。**
- **`reviewer`** — 驱动 `review` 阶段：只读审阅，检查识别策略、数字可追溯性、因果表述强度、清洗 / 合并完整性与数据保护。**从不运行代码，从不改文件。**

---

## 模块化使用

你**不需要每次都走完整流程**，可以从中间阶段进入：

| 你想做什么 | 使用命令 |
|---|---|
| 只检查一个新数据集、不修改它 | `/research-harness-audit` |
| 清洗一个混乱的调查数据文件 | `/research-harness-audit` → `/research-harness-clean` |
| 合并个人 / 家庭 / 社区 / 政策时间文件 | `/research-harness-clean` |
| 按论文定义提取分析就绪子样本 | 见下"论文复现子样本提取" |
| 把研究想法变成可执行实证计划 | `/research-harness-setup` → `/research-harness-plan` |
| 只运行已批准的回归 / 表格 / 图形任务 | `/research-harness-work <task-id>` |
| 检查已有结果是否可信 | `/research-harness-review` |
| 投稿前整理复制包 | `/research-harness-release` |

从中间进入时，每个命令都会提示：跳过前序阶段会损失哪些检查、增加哪些风险。例如 `clean` 可单独用，但更安全的最小路径是 `audit → clean`——如果 ID、缺失值编码、日期、单位或合并键还不清楚，不要盲目清洗数据。

---

## 论文复现子样本提取

七阶段主流程之外的一个**可选独立模式**：给定一篇已发表论文，直接读取原始调查面板的元数据，提取与论文样本筛选、变量构造和编码一致的子样本——不需先走完整 clean。

适用场景：复现基准回归前先还原论文样本与变量定义；用同一原始库做不同样本 / 变量的比较或扩展；验证论文描述统计能否从原始数据复现。

**标准流程（三脚本）：**

```text
*_10_discover_vars.py      # 读原始 .dta 元数据，定位论文所需变量的实际名称
*_11_<paper>_subsample.py  # 按论文筛选条件和变量定义提取子样本
*_12_<paper>_codebook.py   # 生成含论文变量定义和均值对比的 codebook
```

所有输出写入 `3.outdata/data/`：`*_var_list.csv`（变量元数据）、`*_subsample.parquet` / `.csv`（分析就绪子样本）、`*_codebook.csv`（含论文定义、来源说明和均值对比）。

**质量验证：** codebook 对每个构造变量标注与论文描述统计表的均值差距（`CLOSE` / `MODERATE` / `DIFFERS`）。`DIFFERS` 级别须在 `notes` 列记录差距成因，方可视为就绪。

**适用数据：** 多波次调查面板（年度或隔年追踪）、含多个模块的大型微观数据、变量名与编码跨波次有差异的数据集。工程规则见 `docs/survey-pipeline-engineering.md`，已积累的数据集编码经验见 `docs/references/datasets/`。

---

## 项目结构

`setup` 创建以下 canonical 布局（8 个目录）：

```text
your-project/
├── study_spec.md             # 研究合同
├── analysis_plan.md          # 任务台账
├── CLAUDE.md                 # 项目治理（由 setup 交付）
├── 0.dofiles/                # R / Stata / Python 脚本
│   └── logs/                 # 运行日志
├── 1.rawdata/                # 原始微数据（OS 只读，从不写入）
│   └── READONLY.md
├── 2.workdata/               # 中间清洗数据，可重生成
├── 3.outdata/
│   ├── data/                 # 分析就绪数据 + codebook
│   ├── figures/
│   └── tables/
└── 4.reports/                # 审查 / 清洗 / 合并 / 审阅 / 复现报告
```

`release/`（项目根）由 `release` 阶段在 APPROVE 后按需生成，存放最终复制包——不属于 `setup` 的初始布局。

## 核心文件

| 文件 | 作用 |
|---|---|
| `study_spec.md` | 研究合同：问题、数据、设计、变量、样本和预期产出。 |
| `analysis_plan.md` | 任务台账：任务、路径、证据、完成标准和状态标记。 |
| `4.reports/data_audit_report.md` | 原始数据结构和研究可行性的只读证据。 |
| `4.reports/data_cleaning_report.md` | recode、filter、派生变量和样本变化的证据。 |
| `4.reports/merge_report.md` | 每一次 merge 的诊断和冲突解决记录。 |
| `4.reports/review_report.md` | 对识别策略、模型匹配、数字准确性和研究声明的独立审阅。 |
| `4.reports/reproducibility_report.md` | 最终结果的复现说明和证据索引。 |

## 可累积的知识层（references）

技能会自动查阅去标识化的可复用知识：

- `docs/references/datasets/<id>.md` — 数据集的文件命名与变量编码 gotchas（当前已含 CHARLS）
- `docs/references/replications/<paper>.md` — 论文的概念→变量映射与公开目标均值（当前为可扩展模板）
- `docs/survey-pipeline-engineering.md` — 宽面板内存 / 类型工程规律

新增 1 个文件 + `docs/references/index.json` 一条登记即可扩展覆盖，**无需改任何技能**。

---

## 任务状态标记

| 标记 | 含义 |
|---|---|
| `cc:todo` | 尚未开始。 |
| `cc:wip` | 正在进行。 |
| `cc:done` | 已完成，且脚本、日志、输出和证据路径齐全。 |
| `cc:blocked` | 无法继续，原因已记录。 |
| `cc:infeasible` | 数据或设计不支持该任务，停止原因已记录。 |

## 研究诚信规则

完整规则见 [`docs/INTEGRITY-RULES.md`](docs/INTEGRITY-RULES.md)。简版：

| 规则 | 要求 |
|---|---|
| 保护原始数据 | 永远不要修改 `1.rawdata/`。 |
| 不编造证据 | 不得捏造结果、样本量、系数、引用或稳健性检验。 |
| 没有日志就没有结论 | 没有脚本和日志，不得声称分析已运行。 |
| 不静默改变样本 | 每一次 drop、filter 和 recode 都必须记录。 |
| 每次合并都要诊断 | 报告合并键、行数、匹配率、重复键和变量冲突。 |
| 使用相对路径 | 脚本中不得使用机器特定的绝对路径。 |
| 标注因果声明 | 使用 `[descriptive]`、`[associational]`、`[quasi-experimental]` 或 `[experimental]`。 |
| 不可行时停止 | 数据不能支撑设计时报告不可行原因，不得发明变通方法。 |
| 合并键不清楚就询问 | 不得在合并键模糊时靠猜测继续。 |

## 示例项目

`examples/` 提供**起始夹具**——含原始数据 + `study_spec.md`，供你对其运行对应阶段命令（不是预先跑完的成品）。详见 [`examples/README.md`](examples/README.md)。

**`examples/basic-data-cleaning/`** — 小型合成家户调查，内置典型数据质量问题（缺失 ID、`-9` 缺失值编码、异常家庭规模、无效地区编码）。目录含 `0.dofiles/`、`1.rawdata/`、`4.reports/` 及 `study_spec.md`，可对其运行：

```text
/research-harness-audit
/research-harness-clean
```

**`examples/econometrics-replication/`** — 带双重差分设计的合成面板（household-year 面板 + 政策时间文件）。目录含 `0.dofiles/`、`1.rawdata/` 及 `study_spec.md` 作为起点，可对其运行完整七阶段命令序列（`setup → audit → clean → plan → work → review → release`）。

---

## 为什么需要这个框架

AI 智能体能帮研究者写代码、清洗数据、跑模型、生成表格。但没有结构性约束，实证研究里的 agent work 很容易出问题：

- 同一分析跑两遍，样本不一致；
- 正文系数手动复制，后来和表格对不上；
- 因果表述超过识别策略实际能支撑的范围；
- 清洗时悄悄改了原始文件；
- merge 失败却被总结成"分析已完成"；
- 脚本无法复现最终结果；日志缺失，数字来源无法追溯。

Harness 把这些风险转化为显式检查点：原始数据受保护、每次清洗决策留痕、每次合并有诊断、每个分析任务有脚本 / 日志 / 输出 / 状态、每个因果声明经识别策略审查、每个发布包含完整证据链。这就是 AI 助手和可审计研究智能体的区别。

### 软件 Harness 与 Research Harness 有什么不同？

软件开发（含 vibe coding）里的 Harness 把编程 Agent 约束在"需求 → 任务 → 改码 → 测试 → review → release"，核心是**不让 Agent 凭感觉写代码，而让每次修改都能被测试、回滚、验收**。Research Harness 继承这个思想，但把对象从"软件代码"换成"实证研究"。研究里真正危险的不是语法错误，而是样本构造不透明、清洗不可追溯、合并键错、结果不可复现、因果表述超出识别设计、正文数字找不到对应日志。所以它要求 Agent 证明：原始数据未改；清洗合并有脚本、有日志、有报告；样本 / 变量 / 设定与规格一致；每个表图数字可追溯；每个因果声明经审查；数据或设计不支持某结论时停止，而非编造一个看似合理的结果。

> 软件 Harness 约束 Agent 写代码（求"代码通过测试"）；Research Harness 约束 Agent 做研究（求"结论经得起追溯"）。

## 适用场景

| 场景 | 适配程度 |
|---|---|
| 经济学和应用社会科学 | 非常适合 |
| 健康经济学和公共卫生 | 非常适合 |
| 教育学、政治学、社会学 | 非常适合 |
| 面板数据、调查数据、行政数据 | 非常适合 |
| DiD、IV、RD、事件研究、RCT | 非常适合 |
| 数据清洗和多源数据合并 | 非常适合 |
| 按论文定义提取子样本和变量集 | 非常适合 |
| 复制包和投稿前核查 | 非常适合 |
| 可复现实证研究教学 | 非常适合 |
| 没有研究设计需求的纯机器学习 | 部分适合 |

## 设计哲学

**1. 数据约束研究问题。** 智能体不得提出数据无法支撑的研究设计。

**2. 确定性工作必须留下确定性证据。** 清洗、合并、估计和制表都必须有脚本、日志和输出。

**3. 人类审查门槛是系统的一部分。** 研究设计、样本限制和因果声明的关键变更需要研究者批准。

**4. 失败也是有效的研究输出。** 如果数据不足、前提失败或证据链断裂，正确做法是停止，并说明原因。

## 致谢

本仓库的 Harness 框架结构借鉴 [Chachamaru127/claude-code-harness](https://github.com/Chachamaru127/claude-code-harness) 开发，在此对原作者表示感谢。

## License

MIT — see [`LICENSE.md`](LICENSE.md).
