# 批量合并下载的 mRNA 表达文件，无论下载的是 read counts 还是 FPKM。
# sample_id 列表示样品名，将出现在合并后表格的表头；filename 表示文件名，将和文件目录组成绝对路径。
# 提醒一下 GDC 下载后文件是 .gz 压缩文件，并不需要解压到 txt 或者 tsv 。可以直接用这个脚本合并。
# 为了保证合并无误使用了 inner_join 因此最后基因id将是所有样本的交集
# 本脚本在 R 3.6 环境测试通过
# 需要以下 R 包依赖
# argparse, tidyverse


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))

infoText <- "将 TCGA 下载的表达文件合并成一个文件"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--file-list", dest = "FILELIST", help = "csv 格式的文件列表输入", required = TRUE)
parser$add_argument("--file-dir", dest = "FILEDIR", help = "表达文件所在目录", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "输出路径", required = TRUE)

argvs <- parser$parse_args()
listPath <- file.path(argvs$FILELIST)
fileDir <- file.path(argvs$FILEDIR)
outPath <- file.path(argvs$OUTPUT)


fileTable <- read_csv(listPath) %>% dplyr::select(sample_id, file_id, file_name)
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
fileA <- read_tsv(filePathA, col_names = colNameA)

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
write_csv(fileA, outPath)

writeLines("\n完成\n")