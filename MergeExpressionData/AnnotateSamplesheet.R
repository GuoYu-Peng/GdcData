# 从 Biospecimen 的 sample.tsv 提取信息
# 对 SampleSheet 进行注释，添加 is_ffpe 信息
# 输出文件格式为 CSV
# 脚本在 R3.6 测试通过
# 需要依赖 tidyverse, argparse


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))

infoText <- "从 Biospecimen 的 sample.tsv 为 SampleSheet 添加注释信息，方便后续挑选样本进行合并表达数据"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--biospecimen", dest = "BIOSPECIMEN", help = "tsv 格式的 Biospecimen sample.tsv 文件", required = TRUE)
parser$add_argument("--sample-sheet", dest = "SAMPLESHEET", help = "tsv 格式的 SampleSheet 输入", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "注释后 SampleSheet 输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath1 <- file.path(argvs$SAMPLESHEET)
inPath2 <- file.path(argvs$BIOSPECIMEN)
outPath <- file.path(argvs$OUTPUT)


sampleSheet <- read_tsv(inPath1) %>% dplyr::select(`File ID`, `File Name`, `Case ID`, `Sample ID`, `Sample Type`) %>% 
  rename(file_id = `File ID`, file_name = `File Name`, case_id = `Case ID`, sample_id = `Sample ID`, sample_type = `Sample Type`) %>% 
  dplyr::select(case_id, sample_id, sample_type, file_id, file_name)
dplyr::glimpse(sampleSheet)
# 只选取 SampleSheet 有的 sample type
sampleAnno <- read_tsv(inPath2) %>% dplyr::select(sample_submitter_id, is_ffpe, sample_type) %>% 
  dplyr::filter(sample_type %in% unique(sampleSheet$sample_type)) %>% dplyr::select(sample_submitter_id, is_ffpe)
sampleSheet2 <- dplyr::left_join(sampleSheet, sampleAnno, by = c("sample_id" = "sample_submitter_id"))
write_csv(sampleSheet2, outPath)

writeLines("\n完成\n")