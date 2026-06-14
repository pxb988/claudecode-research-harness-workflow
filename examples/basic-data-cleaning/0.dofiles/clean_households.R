# 研究：基础数据清洗示例
# 任务：数据清洗 — households.csv
# 日期：2026-05-29
# 分析师：Claude Code
# 描述：重编码缺失值、施加样本限制、生成派生变量。
# 清洗方案：4.reports/data_cleaning_plan.md
# _fixture: synthetic — randomly generated demo data, not real survey microdata.

library(here)

# --- 打开日志 ---
log_file <- here("0.dofiles", "logs", paste0("clean_", format(Sys.Date(), "%Y%m%d"), ".log"))
dir.create(here("0.dofiles", "logs"), showWarnings = FALSE, recursive = TRUE)
sink(log_file, append = FALSE, split = TRUE)

cat("=== 数据清洗日志 ===\n")
cat("研究：    基础数据清洗示例\n")
cat("任务：    clean_households\n")
cat("开始时间：", format(Sys.time()), "\n\n")

# --- 载入原始数据 ---
raw_path <- here("1.rawdata", "households.csv")
cat("正在载入：", raw_path, "\n")
df <- read.csv(raw_path, stringsAsFactors = FALSE)
cat("已载入：", nrow(df), "行，", ncol(df), "列\n\n")

# --- 重编码缺失值 ---
# income_annual：-9 是历史遗留的缺失值编码
n_income_neg9 <- sum(df$income_annual == -9, na.rm = TRUE)
df$income_annual[df$income_annual == -9] <- NA
cat("已将 income_annual 的 -9 重编码为 NA，共", n_income_neg9, "条观测\n")

# hhid：空白/空字符串 -> NA
n_hhid_blank <- sum(is.na(df$hhid) | df$hhid == "", na.rm = TRUE)
df$hhid[df$hhid == ""] <- NA
cat("发现", n_hhid_blank, "条 hhid 缺失的观测\n\n")

# --- 样本限制 1：删除 hhid 缺失的观测 ---
n_before <- nrow(df)
df <- df[!is.na(df$hhid), ]
n_dropped_id <- n_before - nrow(df)
cat("限制 1 — 删除 hhid 缺失：\n")
cat("  删除前：", n_before, "| 已删除：", n_dropped_id, "| 删除后：", nrow(df), "\n\n")

# --- 样本限制 2：仅保留 A、B、C 地区 ---
n_before <- nrow(df)
df <- df[df$region %in% c("A", "B", "C"), ]
n_dropped_region <- n_before - nrow(df)
cat("限制 2 — 仅保留 A、B、C 地区（删除 D）：\n")
cat("  删除前：", n_before, "| 已删除：", n_dropped_region, "| 删除后：", nrow(df), "\n\n")

# --- 派生变量：hh_size_flag ---
df$hh_size_flag <- as.integer(df$hh_size > 15)
n_flagged <- sum(df$hh_size_flag)
cat("派生变量 hh_size_flag（hh_size > 15）：", n_flagged, "户被标记\n")

# --- 派生变量：income_missing ---
df$income_missing <- as.integer(is.na(df$income_annual))
n_income_missing <- sum(df$income_missing)
cat("派生变量 income_missing：", n_income_missing, "条收入缺失的观测\n\n")

# --- 最终检查 ---
cat("=== 最终数据集摘要 ===\n")
cat("行数：  ", nrow(df), "\n")
cat("列数：", ncol(df), "\n")
cat("地区：", paste(sort(unique(df$region)), collapse = ", "), "\n")
cat("收入缺失：", sum(is.na(df$income_annual)), "\n")
cat("家庭规模被标记：", sum(df$hh_size_flag), "\n\n")

if (anyDuplicated(df$hhid)) {
  cat("错误：发现重复的 hhid 值——清洗失败。\n")
  sink()
  quit(status = 1)
}
cat("ID 检查：无重复 hhid 值 — PASS\n\n")

# --- 保存输出 ---
dir.create(here("3.outdata", "data"), showWarnings = FALSE, recursive = TRUE)
out_path <- here("3.outdata", "data", "households_clean.csv")
write.csv(df, out_path, row.names = FALSE)
cat("已保存：", out_path, "\n")

cat("\n完成时间：", format(Sys.time()), "\n")
cat("退出：0（成功）\n")
sink()
