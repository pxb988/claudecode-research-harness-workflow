# 研究：计量经济学复制示例 — DiD
# 任务：数据清洗与合并 — panel_outcomes + policy_timing
# 日期：2026-05-29
# 分析师：Claude Code
# 描述：将家庭面板与政策时点文件合并；施加样本限制。
# 清洗方案：4.reports/data_cleaning_plan.md
# _fixture: synthetic — randomly generated DiD demo data, not real survey microdata.

library(here)

# --- 打开日志 ---
log_file <- here("0.dofiles", "logs", paste0("clean_", format(Sys.Date(), "%Y%m%d"), ".log"))
dir.create(here("0.dofiles", "logs"), showWarnings = FALSE, recursive = TRUE)
sink(log_file, append = FALSE, split = TRUE)

cat("=== 合并与清洗日志 ===\n")
cat("研究：    计量经济学复制示例\n")
cat("任务：    clean_merge\n")
cat("开始时间：", format(Sys.time()), "\n\n")

# --- 载入左表（面板结果） ---
panel_path <- here("1.rawdata", "panel_outcomes.csv")
cat("正在载入左表：", panel_path, "\n")
panel <- read.csv(panel_path, stringsAsFactors = FALSE)
cat("左表行数：", nrow(panel), "\n\n")

# --- 载入右表（政策时点） ---
policy_path <- here("1.rawdata", "policy_timing.csv")
cat("正在载入右表：", policy_path, "\n")
policy <- read.csv(policy_path, stringsAsFactors = FALSE)
cat("右表行数：", nrow(policy), "\n\n")

# --- 合并诊断（合并前） ---
cat("=== 合并诊断 ===\n")
cat("合并类型：  m:1\n")
cat("合并键：  region, year\n")
cat("左表键唯一？  ", !anyDuplicated(paste(panel$region, panel$year)), "\n")
cat("右表键唯一？ ", !anyDuplicated(paste(policy$region, policy$year)), "\n")
cat("左表 N：  ", nrow(panel), "\n")
cat("右表 N： ", nrow(policy), "\n\n")

# --- 执行合并 ---
merged <- merge(panel, policy, by = c("region", "year"), all.x = TRUE)

cat("合并后 N：   ", nrow(merged), "\n")
n_matched    <- sum(!is.na(merged$policy_active))
n_unmatched  <- sum(is.na(merged$policy_active))
cat("已匹配：        ", n_matched, "\n")
cat("左表未匹配： ", n_unmatched, "\n")
cat("匹配率：     ", round(n_matched / nrow(merged) * 100, 1), "%\n\n")

if (n_unmatched > 0) {
  cat("警告：发现左表未匹配的行——请在继续前检查。\n")
  print(merged[is.na(merged$policy_active), c("hhid", "region", "year")])
}

# --- 样本限制：删除 income_annual 缺失的观测 ---
n_before <- nrow(merged)
merged <- merged[!is.na(merged$income_annual), ]
n_dropped_income <- n_before - nrow(merged)
cat("限制 — 删除 income_annual 缺失：\n")
cat("  删除前：", n_before, "| 已删除：", n_dropped_income, "| 删除后：", nrow(merged), "\n\n")

# --- 派生变量 ---
merged$treated <- as.integer(merged$policy_active == 1)
merged$post    <- as.integer(!is.na(merged$treat_year) & merged$year >= merged$treat_year)
cat("派生：treated — 处理组观测数：", sum(merged$treated, na.rm = TRUE), "\n")
cat("派生：post    — 处理后观测数：   ", sum(merged$post, na.rm = TRUE), "\n\n")

# --- 最终摘要 ---
cat("=== 最终数据集 ===\n")
cat("行数：  ", nrow(merged), "\n")
cat("列数：", ncol(merged), "\n")
cat("地区：", paste(sort(unique(merged$region)), collapse = ", "), "\n")
cat("年份：  ", paste(sort(unique(merged$year)), collapse = ", "), "\n")

# --- 保存输出 ---
dir.create(here("3.outdata", "data"), showWarnings = FALSE, recursive = TRUE)
out_path <- here("3.outdata", "data", "panel_analysis.csv")
write.csv(merged, out_path, row.names = FALSE)
cat("\n已保存：", out_path, "\n")

cat("\n完成时间：", format(Sys.time()), "\n")
cat("退出：0（成功）\n")
sink()
