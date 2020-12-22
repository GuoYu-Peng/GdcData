# biomaRt 需要连接 ensembl 服务器，而这很容易不成功，可以把 BioMart feature 信息下载到本地，就可以本地进行基因ID转换了
# 下载网址是 http://useast.ensembl.org/biomart/martview/4fcd88c826b00285038814f41d823029 记得External References 那里要
# 选择 HGNC symbol 和 NCBI gene ID 2项
# 默认输入文件第一列是基因名，且列名为 gene_id
# 脚本在 R 3.6 环境测试通过，需要 tidyverse 包

writeLines("\nRscript Ensembl2SymbolLocal.R BioMart.tsv Input.csv Output.csv\n")
argvs <- commandArgs(trailingOnly = TRUE)
stopifnot(length(argvs) >= 3)
inPath1 <- file.path(argvs[1])
inPath2 <- file.path(argvs[2])
outPath <- file.path(argvs[3])
msg1 <- stringr::str_glue("\nBioMart 路径：{inPath1}\n")
msg2 <- stringr::str_glue("输入文件：{inPath2}\n")
msg3 <- stringr::str_glue("输出文件：{outPath}\n")
writeLines(msg1)
writeLines(msg2)
writeLines(msg3)

library(tidyverse, quietly = TRUE, verbose = FALSE)

# 先移除 entrezID 和 symbol 都为 NA 数据
# 排序让 NA 处于下游
geneMap <- read_csv(inPath1) %>% dplyr::select(`Gene stable ID`, `HGNC symbol`, `NCBI gene (formerly Entrezgene) ID`) %>% 
  dplyr::rename(ensembl_gene_id = `Gene stable ID`, hgnc_symbol = `HGNC symbol`, entrezgene_id = `NCBI gene (formerly Entrezgene) ID`) %>% 
  dplyr::filter(!(is.na(hgnc_symbol) & is.na(entrezgene_id))) %>% dplyr::arrange(entrezgene_id, desc(hgnc_symbol)) %>% 
  dplyr::distinct(ensembl_gene_id, .keep_all = TRUE)
dplyr::glimpse(geneMap)

inputTable <- read_csv(inPath2) %>% tidyr::separate(col = gene_id, into = c("ensembl_gene_id", "Gversion"), sep="\\.", remove=TRUE, extra="merge", fill="right") %>% dplyr::select(- Gversion)
outputTable <- dplyr::left_join(inputTable, geneMap, by = "ensembl_gene_id") %>% dplyr::select(ensembl_gene_id, entrezgene_id, hgnc_symbol, everything())
write_csv(outputTable, outPath)

writeLines("\n完成\n")

