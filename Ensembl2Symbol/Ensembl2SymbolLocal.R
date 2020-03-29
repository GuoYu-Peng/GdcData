# biomaRt 需要连接 ensembl 服务器，而这很容易不成功，可以把 BioMart feature 信息下载到本地，就可以本地进行基因ID转换了
# 下载网址是 http://useast.ensembl.org/biomart/martview/4fcd88c826b00285038814f41d823029 记得External References 那里要
# 选择 HGNC symbol 和 NCBI gene ID 2项
# 默认输入文件第一列是基因名，且列名为 gene_id
# 脚本在 R 3.6 环境测试通过，需要 tidyverse 包

writeLines("Rscript Ensembl2SymbolLocal.R BioMart.tsv Input.csv Output.csv\n\n")
argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 3)
library(tidyverse, quietly = TRUE)

geneMap <- read_tsv(argvs[1]) %>% dplyr::select(`Gene stable ID`, `HGNC symbol`, `NCBI gene ID`) %>% dplyr::rename(ensembl_gene_id = `Gene stable ID`, hgnc_symbol = `HGNC symbol`, entrezgene_id = `NCBI gene ID`) %>% dplyr::filter(!((is.na(hgnc_symbol) || hgnc_symbol=="") & is.na(entrezgene_id))) %>% dplyr::distinct(ensembl_gene_id, .keep_all = TRUE)

inputTable <- read_csv(argvs[2]) %>% tidyr::separate(col = gene_id, into = c("ensembl_gene_id", "Gversion"), sep="\\.", remove=TRUE, extra="merge", fill="right") %>% dplyr::select(- Gversion)
outputTable <- dplyr::left_join(inputTable, geneMap, by = "ensembl_gene_id") %>% dplyr::select(ensembl_gene_id, hgnc_symbol, entrezgene_id, everything())
write_csv(outputTable, path = argvs[3])

writeLines("完成")

