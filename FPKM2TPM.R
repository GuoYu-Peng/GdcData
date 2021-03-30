# 提示：FPKM转TPM并不好，能不用尽量不用
# GDC 提供 FPKM 表达值，用本脚本转换到 TPM
# 本脚本默认第一列为基因名第一行为样品名，并且输出到 csv 格式文件
# 本脚本在 R 3.6 测试通过
# 依赖以下 R 包：
# argparse

suppressPackageStartupMessages(library(argparse))

infoText <- "将 TCGA 下载的 FPKM 转换为 TPM"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--input", dest = "INPUT", help = "csv 格式的 FPKM 输入路径，要求第一列为样品名", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "TPM 输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath <- file.path(argvs$INPUT)
outPath <- file.path(argvs$OUTPUT)

fpkm <- read.csv(inPath, stringsAsFactors = FALSE, row.names = 1, check.names = FALSE)
# 计算每个样本 FPKM 总值
sumJ <- colSums(fpkm)
tpm <- t(t(fpkm) / sumJ) * 1000000
write.csv(tpm, file = outPath, quote = FALSE)

writeLines("\n完成\n")

