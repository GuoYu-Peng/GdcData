# 批量合并下载的mRNA表达文件，无论下载的是 read counts 还是 FPKM。
# sample_id 列表示样品名，将出现在合并后表格的表头；filename 表示文件名，将和文件目录组成绝对路径。
# 提醒一下 GDC 下载后文件是 .gz 压缩文件，并不需要解压到 txt 或者 tsv 。可以直接用这个脚本合并。
# 为了保证合并无误使用了 inner_join 因此最后基因id将是所有样本的交集
# 本脚本在 R 3.6 环境测试通过
# 需要先安装R包 tidyverse

writeLines("\nRscript MergeExpressionData.R FileList.csv FileDir Output.csv\n\n")

argvs <- commandArgs(TRUE)
stopifnot(length(argvs) >= 3)
listPath <- file.path(argvs[1])
fileDir <- file.path(argvs[2])
outPath <- file.path(argvs[3])
msg1 <- stringr::str_glue("FileList 路径：{listPath}\n")
msg2 <- stringr::str_glue("数据目录：{fileDir}\n")
msg3 <- stringr::str_glue("数据输出：{outPath}\n")
writeLines(msg1)
writeLines(msg2)
writeLines(msg3)

library(tidyverse, quietly = TRUE, verbose = FALSE)

fileTable <- readr::read_csv(listPath) %>% dplyr::select(sample_id, file_id, file_name)
dplyr::glimpse(fileTable)

sampleList <- fileTable$sample_id
idList <- fileTable$file_id
fileList <- fileTable$file_name
sampleNum <- length(sampleList)

sampleA <- sampleList[1]
fileIdA <- idList[1]
filenameA <- fileList[1]
filePathA <- file.path(fileDir, fileIdA, filenameA)
colNameA <- c("gene_id", sampleA)
# 源文件不包含表头，添加表头防止将第一行数据读为表头
fileA <- readr::read_tsv(filePathA, col_names = colNameA)

for (n in 2:sampleNum) {
  sampleN <- sampleList[n]
  fileIdN <- idList[n]
  filenameN <- fileList[n]
  filePathN <- file.path(fileDir, fileIdN, filenameN)
  colNameN <- c("gene_id", sampleN)
  fileN <- readr::read_tsv(filePathN, col_names = colNameN)
  colnames(fileN) <- c("gene_id", sampleN)
  # 保证基因 ID 的一致性
  fileA <- dplyr::inner_join(fileA, fileN, by = "gene_id")
}

dplyr::glimpse(fileA)
readr::write_csv(fileA, outPath)
writeLines("\n完成\n")