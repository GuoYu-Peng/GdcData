# 将合并好的 FPKM 矩阵进行 log2(FPKM + 1) 转换
# 要求第一列为基因名 gene_id
# 本脚本在 R 3.6 环境测试通过
# 依赖以下 R 包： 
# argparse, tidyverse


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))

infoText <- "将 FPKM 矩阵进行 log2(FPKM + 1) 转换"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--input", dest = "INPUT", help = "csv 格式的 FPKM 输入路径，要求第一列表头为 \"gene_id\"", 
                    required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath <- file.path(argvs$INPUT)
outPath <- file.path(argvs$OUTPUT)

fpkm <- read_csv(inPath)
geneId <- dplyr::select(fpkm, gene_id)
sampleFpkm <- dplyr::select(fpkm, - gene_id)
lSampleFpkm <- log2(sampleFpkm + 1)

lFpkm <- dplyr::bind_cols(geneId, lSampleFpkm)
write_csv(lFpkm, outPath)

writeLines("\n完成\n")