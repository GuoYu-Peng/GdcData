# 在 GDC 下载的 TCGA 表达文件基因名采用的是 ensembl ID，后续分析可能需要用SYMBOL，使用本脚添加 ENTREZ ID 和 SYMBOL
# 默认输入文件第一列是基因名，且列名为 gene_id
# 脚本需要有网络连接才能运行，脚本在 R 3.6 环境测试通过，需要下列 R 包
# 无网络连接可以用 Ensembl2SymbolLocal.R 
# - tydyverse
# - biomaRt

writeLines("\nRscript Ensembl2Symbol.R input.csv output.csv\n")

argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 2)
inPath <- file.path(argvs[1])
outPath <- file.path(argvs[2])
msg1 <- stringr::str_glue("\n输入：{inPath}\n")
msg2 <- stringr::str_glue("输出：{outPath\n}")
writeLines(msg1)
writeLines(msg2)

library(tidyverse, quietly = TRUE, verbose = FALSE)
library(biomaRt, quietly = TRUE, verbose = FALSE)

# GDC下载的表达文件 ensembl gene ID 是包含版本号的，将版本号信息移除
geneExpr <- readr::read_csv(inPath) %>% tidyr::separate(col = gene_id, into = c("ensembl_gene_id", "Gversion"), sep="\\.", remove=TRUE, extra="merge", fill="right") %>% dplyr::select(- Gversion)

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