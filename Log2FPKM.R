# 将合并好的 FPKM 矩阵进行 log2(fpkm + 1) 转换
# 要求第一列为基因名 gene_id
# 本脚本在 R 3.6 环境测试通过
# 需要先安装R包 tidyverse

writeLines("\nRscript Log2FPKM.R input.csv output.csv\n")

argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 2)
inPath <- file.path(argvs[1])
outPath <- file.path(argvs[2])
msg1 <- stringr::str_glue("\n输入路径：{inPath}\n")
msg2 <- stringr::str_glue("输出路径：{outPath}\n")
writeLines(msg1)
writeLines(msg2)

library(tidyverse, quietly = TRUE, verbose = FALSE)

fpkm <- read_csv(inPath)
geneId <- dplyr::select(fpkm, gene_id)
sampleFpkm <- dplyr::select(fpkm, - gene_id)
lSampleFpkm <- log2(sampleFpkm + 1)

lFpkm <- dplyr::bind_cols(geneId, lSampleFpkm)
write_csv(lFpkm, outPath)

writeLines("\n完成\n")