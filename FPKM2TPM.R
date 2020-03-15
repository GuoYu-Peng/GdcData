# 提示：FPKM转TPM并不好，能不用尽量不用。
# GDC 提供 FPKM 表达值，用本脚本转换到 TPM
# 本脚本默认第一列为基因名第一行为样品名，并且输出到 csv 格式文件
# 本脚本在 R 3.6 测试通过

writeLines("Rscript FPKM2TPM.R FPKM.csv TPM.csv\n\n")

argvs <- commandArgs(TRUE)
stopifnot(length(argvs) >= 2)

# fpkm <- read.tsv(argvs[1], stringsAsFactors = FALSE, row.names = 1)
fpkm <- read.csv(argvs[1], stringsAsFactors = FALSE, row.names = 1, check.names = FALSE)

# 计算每个样本 FPKM 总值
sumJ <- colSums(fpkm)
tpm <- t(t(fpkm) / sumJ) * 1000000
write.csv(tpm, file = argvs[2], quote = FALSE)
print("完成")



