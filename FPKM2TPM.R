# 提示：FPKM转TPM并不好，能不用尽量不用。
# GDC 提供 FPKM 表达值，用本脚本转换到 TPM
# 本脚本默认第一列为基因名第一行为样品名，并且输出到 csv 格式文件
# 本脚本在 R 3.6 测试通过

writeLines("\nRscript FPKM2TPM.R FPKM.csv TPM.csv\n")

argvs <- commandArgs(TRUE)
stopifnot(length(argvs) >= 2)
inPath <- file.path(argvs[1])
outPath <- file.path(argvs[2])
msg1 <- stringr::str_glue("\nFPKM 路径：{inPath}\n")
msg2 <- stringr::str_glue("输出 TPM: {outPath}\n")
writeLines(msg1)
writeLines(msg2)

fpkm <- read.csv(inPath, stringsAsFactors = FALSE, row.names = 1, check.names = FALSE)
# 计算每个样本 FPKM 总值
sumJ <- colSums(fpkm)
tpm <- t(t(fpkm) / sumJ) * 1000000
write.csv(tpm, file = outPath, quote = FALSE)

writeLines("\n完成\n")



