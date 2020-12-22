# 从 Biospecimen 的 sample.tsv 提取信息
# 对 SampleSheet 进行注释，添加 is_ffpe 信息
# 输出文件格式为 CSV
# 脚本在 R3.6 测试通过
# 需要依赖 tidyverse


writeLines("\nRscript AnnotateSamplesheet.R SampleSheet.tsv BiospecimenSample.tsv AnnotatedSampleSheet.csv\n")
argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 3)

inPath1 <- file.path(argvs[1])
inPath2 <- file.path(argvs[2])
outPath <- file.path(argvs[3])
msg1 <- stringr::str_glue("\nSampleSheet 路径：{inPath1}\n")
msg2 <- stringr::str_glue("Biospecimen Sample 路径：{inPath2}\n")
msg3 <- stringr::str_glue("输出路径：{outPath}\n\n")
writeLines(msg1)
writeLines(msg2)
writeLines(msg3)

library(tidyverse, verbose = FALSE, quietly = TRUE)

sampleSheet <- readr::read_tsv(inPath1) %>% dplyr::select(`File ID`, `File Name`, `Case ID`, `Sample ID`, `Sample Type`) %>% 
  dplyr::rename(file_id = `File ID`, file_name = `File Name`, case_id = `Case ID`, sample_id = `Sample ID`, sample_type = `Sample Type`) %>% 
  dplyr::select(case_id, sample_id, sample_type, file_id, file_name)
dplyr::glimpse(sampleSheet)
# 只选取 SampleSheet 有的 sample type
sampleAnno <- readr::read_tsv(inPath2) %>% dplyr::select(sample_submitter_id, is_ffpe, sample_type) %>% 
  dplyr::filter(sample_type %in% unique(sampleSheet$sample_type)) %>% dplyr::select(sample_submitter_id, is_ffpe)
sampleSheet2 <- dplyr::left_join(sampleSheet, sampleAnno, by = c("sample_id" = "sample_submitter_id"))
readr::write_csv(sampleSheet2, outPath)
writeLines("完成\n")