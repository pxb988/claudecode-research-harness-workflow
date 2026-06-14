# 研究：计量经济学复制示例 — DiD
# 任务：2.1 — 主 DiD 回归（双向 FE）
# 识别：[quasi-experimental: DiD]
# 假设：在没有职业培训项目的情形下趋势平行
# 日期：2026-05-29
# 分析师：Claude Code
# _fixture: synthetic — randomly generated DiD demo data, not real survey microdata.

library(here)
library(fixest)   # 用于带双向固定效应的 feols()

# --- 打开日志 ---
log_file <- here("0.dofiles", "logs", "main_did.log")
dir.create(here("0.dofiles", "logs"), showWarnings = FALSE, recursive = TRUE)
sink(log_file, append = FALSE, split = TRUE)

cat("=== 主 DiD 回归日志 ===\n")
cat("任务：            2.1 — 主 DiD\n")
cat("识别：  [quasi-experimental: DiD]\n")
cat("假设：      趋势平行\n")
cat("估计量：       双向 FE（地区 + 年份），按地区聚类标准误\n")
cat("开始时间：        ", format(Sys.time()), "\n\n")

# --- 载入可分析数据 ---
data_path <- here("3.outdata", "data", "panel_analysis.csv")
cat("正在载入：", data_path, "\n")
df <- read.csv(data_path, stringsAsFactors = FALSE)
cat("已载入：", nrow(df), "行\n\n")

# --- 本任务的样本限制 ---
n_before <- nrow(df)
df <- df[!is.na(df$treated) & !is.na(df$income_annual), ]
n_dropped <- n_before - nrow(df)
cat("限制 — 删除 treated 或 income 缺失：\n")
cat("  删除前：", n_before, "| 已删除：", n_dropped, "| 删除后：", nrow(df), "\n\n")

cat("估计样本 N：", nrow(df), "\n")
cat("处理组观测：        ", sum(df$treated), "\n")
cat("控制组观测：        ", sum(!df$treated), "\n\n")

# --- 主 DiD 回归 ---
cat("=== 模型：income_annual ~ treated | region + year, cluster = region ===\n")
fit_main <- feols(income_annual ~ treated | region + year,
                  data    = df,
                  cluster = ~region)

cat("\n--- 主 DiD 结果 ---\n")
print(summary(fit_main))

# 提取并记录关键数字
coef_treated <- coef(fit_main)["treated"]
se_treated   <- se(fit_main)["treated"]
pval_treated <- pvalue(fit_main)["treated"]
nobs_main    <- nobs(fit_main)

cat("\n=== 关键结果 ===\n")
cat("N（估计样本）：      ", nobs_main, "\n")
cat("DiD 系数（treated）：  ", round(coef_treated, 2), "\n")
cat("标准误：             ", round(se_treated, 2), "\n")
cat("p 值：                    ", round(pval_treated, 4), "\n\n")

# --- 保存输出表 ---
dir.create(here("3.outdata", "tables"), showWarnings = FALSE, recursive = TRUE)
out_path <- here("3.outdata", "tables", "table2_main_did.csv")

results_df <- data.frame(
  term       = "treated",
  estimate   = round(coef_treated, 2),
  std_error  = round(se_treated, 2),
  p_value    = round(pval_treated, 4),
  n_obs      = nobs_main,
  fe         = "region + year",
  cluster    = "region"
)
write.csv(results_df, out_path, row.names = FALSE)
cat("输出已保存：", out_path, "\n")

cat("\n完成时间：", format(Sys.time()), "\n")
cat("退出：0（成功）\n")
sink()
