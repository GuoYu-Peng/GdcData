# 将合并好的 FPKM 矩阵进行 log2(fpkm + 1) 转换
# 要求第一列为基因名 gene_id
# 本脚本在 R 3.6 环境测试通过
# 需要先安装R包 tidyverse

writeLines("Rscript Log2FPKM.R input.csv output.csv\n")

argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 2)

library(tidyverse, quietly = TRUE)

fpkm <- read_csv(argvs[1])
geneId <- dplyr::select(fpkm, gene_id)
sampleFpkm <- dplyr::select(fpkm, - gene_id)
lSampleFpkm <- log2(sampleFpkm + 1)

lFpkm <- dplyr::bind_cols(geneId, lSampleFpkm)
write_csv(lFpkm, path = argvs[2])

writeLines("完成")