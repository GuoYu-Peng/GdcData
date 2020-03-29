# 如果同时下载了 FPKM 和 ReadCounts 可能会想2者选取同一批样本的数据
# 如果在 FPKM 整理好了 FileList.csv 用本脚本可以整理出 ReadCounts 相应样本的 FileList.csv
# 需要 tidyverse, 脚本在 R 3.6 环境测试通过

# InFileList.csv 是已有的 FileList 文件
writeLines("Rscript NeededFilename.R SampleSheet.tsv InFileList.csv OutFileList.csv\n\n")
argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 3)

library(tidyverse, quietly = TRUE)

fileList <- read_csv(argvs[2])
neededSample <- read_tsv(argvs[1]) %>% dplyr::select(`File Name`, `Case ID`, `Sample ID`, `Sample Type`) %>% dplyr::rename(filename=`File Name`, case_id = `Case ID`, sample_id = `Sample ID`, sample_type = `Sample Type`) %>% dplyr::filter(sample_id %in% fileList$sample_id) %>% dplyr::distinct(sample_id, .keep_all = TRUE)

sampleList1 <- fileList$sample_id
sampleList2 <- neededSample$sample_id
if (length(sampleList1) != length(sampleList2)) {
  dList <- setdiff(sampleList1, sampleList2)
  writeLines("下列样本不在 SampleSheet 里")
  print(dList)
}

dplyr::count(neededSample, sample_type)
write_csv(neededSample, path = argvs[3])
writeLines("完成")