# 示例 —— Research Agent Harness

每个示例都用合成数据演示科研工作流的一个或多个阶段。不使用任何真实数据。所有示例都是自包含的桩示例：它们展示预期的文件结构、脚本范式与报告格式，而无需外部数据源。

---

## 示例索引

### 1. basic-data-cleaning

**学习目标：** 在单个合成 CSV 文件上运行 `/research-harness-audit` 与 `/research-harness-clean`。

**涵盖：**
- 变量检查与缺失情况报告
- 重命名与类型转换
- 缺失值重编码
- 带记录的观测过滤（每次丢弃都有据可查）
- 把清洗后的数据集保存到 `3.outdata/data/`
- 生成 `data_audit_report.md` 与 `data_cleaning_report.md`

**不涵盖：** 合并、计量模型、审稿、发布。

**入口：** `examples/basic-data-cleaning/README.md`

---

### 2. econometrics-replication

**学习目标：** 在一个合成的双重差分（DiD）数据集上运行完整的 7 阶段工作流。

**涵盖：**
- 采用 DiD 识别策略的研究规格
- 两文件合并（面板结果 + 政策时点），含完整合并报告
- 描述性统计与预趋势检验
- 带固定效应的主 DiD 回归
- 稳健性检验（替换对照组）
- 审稿：识别策略评估、数值核验
- 复现包组装

**入口：** `examples/econometrics-replication/README.md`

---

## 如何使用示例

```bash
# 把示例文件夹复制到一个工作目录
cp -r examples/basic-data-cleaning /tmp/my-cleaning-test
cd /tmp/my-cleaning-test

# 启动 Claude Code 并运行工作流
claude
/research-harness-audit
/research-harness-clean
```

两个示例都使用**标准项目目录结构**（`0.dofiles/`、`1.rawdata/`、
`2.workdata/`、`3.outdata/`、`4.reports/`）—— 与 `/research-harness-setup`
生成的结构一致。示例脚本中的所有路径都相对于示例文件夹根目录。

---

## 合成数据声明

这些示例中的所有 CSV 文件都包含随机生成的数据。
它们仅用于演示数据结构 —— 其中的数字没有实际含义。
