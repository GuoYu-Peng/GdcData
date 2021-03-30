# 如果同时下载了 FPKM 和 ReadCounts 可能会想2者选取同一批样本的数据
# 如果在 FPKM 整理好了 FileList.csv 用本脚本可以整理出 ReadCounts 相应样本的 FileList.csv
# 反之亦然
# 脚本在 R 3.6 环境测试通过
# 需要以下 R 包依赖：
# argparse, tidyverse


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))

infoText <- "当 TCGA 数据集有病例多个表达量文件时，只选取其中一个，另外是将 FFPE 样本移除"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--sample-sheet", dest = "SAMPLESHEET", help = "tsv 格式的 SampleSheet 输入", required = TRUE)
parser$add_argument("--input", dest = "INPUT", help = "csv 格式的 FileList 输入", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath1 <- file.path(argvs$SAMPLESHEET)
inPath2 <- file.path(argvs$INPUT)
outPath <- file.path(argvs$OUTPUT)

fileList <- read_csv(inPath2)
neededSample <- read_tsv(inPath1) %>% dplyr::select(`File ID`, `File Name`, `Case ID`, `Sample ID`, `Sample Type`) %>% 
  dplyr::rename(file_id = `File ID`, file_name=`File Name`, case_id = `Case ID`, sample_id = `Sample ID`, sample_type = `Sample Type`) %>% 
  dplyr::filter(sample_id %in% fileList$sample_id) %>% dplyr::distinct(sample_id, .keep_all = TRUE)

sampleList1 <- fileList$sample_id
sampleList2 <- neededSample$sample_id
if (length(sampleList1) != length(sampleList2)) {
  dList <- setdiff(sampleList1, sampleList2)
  writeLines("下列样本不在 SampleSheet 里\n")
  print(dList)
}

dplyr::count(neededSample, sample_type)
write_csv(neededSample, outPath)

writeLines("\n完成\n")