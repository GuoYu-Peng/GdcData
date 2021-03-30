# 在 GDC 下载的 TCGA 表达文件基因名采用的是 ensembl ID，后续分析可能需要用SYMBOL，使用本脚添加 ENTREZ ID 和 SYMBOL
# 默认输入文件第一列是基因名，且列名为 gene_id
# 脚本需要有网络连接才能运行，脚本在 R 3.6 环境测试通过
# 无网络连接可以用 Ensembl2SymbolLocal.R 
# 需要以下 R 包依赖：
# argparse, tidyverse, biomaRt


suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(biomaRt))

infoText <- "将表达矩阵的 Ensembl 基因 ID 转换为 SYMBOL, 需要有网络连接"
parser <- ArgumentParser(description = infoText, add_help = TRUE)
parser$add_argument("--input", dest = "INPUT", help = "csv 格式的表达输入文件", required = TRUE)
parser$add_argument("--output", dest = "OUTPUT", help = "输出路径", required = TRUE)

argvs <- parser$parse_args()
inPath <- file.path(argvs$INPUT)
outPath <- file.path(argvs$OUTPUT)

# GDC下载的表达文件 ensembl gene ID 是包含版本号的，将版本号信息移除
geneExpr <- read_csv(inPath) %>% 
  separate(col = gene_id, into = c("ensembl_gene_id", "Gversion"), sep="\\.", remove=TRUE, extra="merge", fill="right") %>% 
  dplyr::select(- Gversion)

ensembl <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
# 排列时让 NA 处于下游
geneMap <- getBM(attributes = c("ensembl_gene_id", "entrezgene_id", "hgnc_symbol"), filters = "ensembl_gene_id", values = geneExpr$ensembl_gene_id, mart = ensembl) %>% 
  dplyr::filter(!(is.na(entrezgene_id) & is.na(hgnc_symbol))) %>% dplyr::arrange(entrezgene_id, desc(hgnc_symbol)) %>% 
  dplyr::distinct(ensembl_gene_id, .keep_all = TRUE)
dplyr::glimpse(geneMap)

geneExpr2 <- dplyr::left_join(geneExpr, geneMap, by = "ensembl_gene_id") %>% dplyr::select(ensembl_gene_id, entrezgene_id, hgnc_symbol, everything())
dplyr::glimpse(geneExpr2)
write_csv(geneExpr2, outPath)

writeLines("\n完成\n")