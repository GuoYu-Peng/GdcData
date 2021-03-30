# 有些数据集会有部分 sample 有多个 RNA 测序数据
# 比如说 TCGA-BLCA 的 TCGA-BL-A0C8-01A, TCGA-BL-A13I-01A, TCGA-BL-A13J-01A
# 这时候需要选择其中一个，本脚本就随机(伪)选取一个
# 同时脚本会将 FFPE 样本移除
# GDC 下载的 SampleSheet.tsv, sample.tsv 先用 AnnotateSamplesheet.R 合并
# 然后输出的文件作为本脚本的输入文件
# 输出文件可以作为 MergeExpressionData.R 脚本的 FileList.csv 输入
# 需要 tidyverse 包，脚本在 R 3.6 环境测试通过
# 需要以下 R 包依赖
# argparse, tidyverse


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))

infoText <- "当 TCGA 数据集有病例多个表达量文件时，只选取其中一个，另外是将 FFPE 样本移除"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--sample-sheet", dest = "SAMPLESHEET", help = "csv 格式的 SampleSheet 输入，是 AnnotateSamplesheet.R 脚本的输出", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath <- file.path(argvs$SAMPLESHEET)
outPath <- file.path(argvs$OUTPUT)

# 先移除 FFPE 样本数据
allSample <- read_csv(inPath) %>% dplyr::filter(!is_ffpe)
# 相同的 sample_id 选择上面那个
neededSample <- dplyr::distinct(allSample, sample_id, .keep_all = TRUE)
statSample <- dplyr::count(allSample, sample_id) %>% dplyr::filter(n >= 2)
dupNum <- nrow(statSample)
if (dupNum > 0) {
  dupSample <- statSample$sample_id %>% unique()
  writeLines("有重复的样本: \n")
  print(dupSample)
}

caseNum <- neededSample$case_id %>% unique() %>% length()
caseNumText <- stringr::str_glue("选取的病例数：{caseNum}")
writeLines(caseNumText)
dplyr::count(neededSample, sample_type)
dplyr::count(neededSample, case_id) %>% dplyr::filter(n >= 2)
write_csv(neededSample, outPath)

writeLines("\n完成\n")