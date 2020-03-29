# 批量合并下载的mRNA表达文件，无论下载的是 read counts 还是 FPKM。
# 首先要把所有的下载文件放在一个目录(文件目录)下，然后提供需合并文件列表，要求包含2列
# sample_id 列表示样品名，将出现在合并后表格的表头；filename 表示文件名，将和文件目录组成绝对路径。提醒一下 GDC 下载后文件是 .gz 压缩文件，并不需要解压到 txt 或者 tsv 。可以直接用这个脚本合并。
# 为了保证合并无误使用了 inner_join 因此最后基因id将是所有样本的交集
# 本脚本在 R 3.6 环境测试通过
# 需要先安装R包 tidyverse

writeLines("Rscript MergeExpressionData.R FileList.csv FileDir Output.csv\n\n")

argvs <- commandArgs(TRUE)
stopifnot(length(argvs) >= 3)
fileDir <- argvs[2]
library(tidyverse, quietly = TRUE)

# 要求信息表里必须包含 sample_id 和 filename 2列
# fileTable <- read_tsv(argvs[1]) %>% dplyr::select(sample_id, filename)
fileTable <- read_csv(argvs[1]) %>% dplyr::select(sample_id, filename)
head(fileTable, n = 3)

sampleList <- fileTable$sample_id
fileList <- fileTable$filename
sampleNum <- length(sampleList)

sampleA <- sampleList[1]
filenameA <- fileList[1]
filePathA <- stringr::str_glue("{fileDir}/{filenameA}")  
# fileA <- read_csv(filePathA)
fileA <- read_tsv(filePathA)
colnames(fileA) <- c("gene_id", sampleA)

for (n in 2:sampleNum) {
  sampleN <- sampleList[n]
  filenameN <- fileList[n]
  filePathN <- stringr::str_glue("{fileDir}/{filenameN}") 
  # fileN <- read_csv(filePathN)
  fileN <- read_tsv(filePathN)
  colnames(fileN) <- c("gene_id", sampleN)
  fileA <- dplyr::inner_join(fileA, fileN, by = "gene_id")
}

head(fileA, n = 3)
dim(fileA)

write_csv(fileA, path = argvs[3])
# write_tsv(fileA, path = argvs[3])
writeLines("完成")