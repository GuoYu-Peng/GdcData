# 有些数据集会有 case 有多个 RNA 测序数据，这时候需要选择其中一个，本脚本就随机(伪)选取一个
# 输入 GDC 下载的 SampleSheet 文件
# 输出文件可以作为 MergeExpressionData.R 脚本的 FileList.csv 输入
# 需要 tidyverse 包，脚本在 R 3.6 环境测试通过

writeLines("Rscript SelectSampleRandomly.R SampleSheet.tsv FileList.csv\n")
argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 2)

library(tidyverse, quietly = TRUE)
allSample <- read_tsv(argvs[1]) %>% dplyr::select(`File Name`, `Case ID`, `Sample ID`, `Sample Type`) %>% dplyr::rename(filename=`File Name`, case_id = `Case ID`, sample_id = `Sample ID`, sample_type = `Sample Type`)

# 多个相同 case_id 时保留最上面那一个
sampleTypes <- allSample$sample_type %>% unique()
allSampleList <- list()
for (i in 1:length(sampleTypes)) {
  typeName <- sampleTypes[i]
  typeSample <- dplyr::filter(allSample, sample_type==typeName) %>% dplyr::distinct(case_id, .keep_all = TRUE)
  allSampleList[[i]] <- typeSample
}
neededSample <- dplyr::bind_rows(allSampleList)

oList <- allSample$sample_id
nList <- neededSample$sample_id

n <- length(unique(oList)) - length(unique(nList))
if (n > 0) {
  dList <- setdiff(oList, nList)
  text1 <- stringr::str_glue("移除的样本数目：{n}")
  writeLines(text1)
  writeLines("移除的样本：")
  print(dList)
}

caseNum <- neededSample$case_id %>% unique() %>% length()
caseNumText <- stringr::str_glue("Cases：{caseNum}")
writeLines(caseNumText)
dplyr::count(neededSample, sample_type)

write_csv(neededSample, path = argvs[2])
writeLines("完成")