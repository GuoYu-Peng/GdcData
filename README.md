# GdcData
从 [GDC](https://portal.gdc.cancer.gov/) 下载和处理 TCGA 数据，脚本都很简单不专门写文档。
有疑问先看脚本内注释信息，注释信息无法解答的就提 Issue 或者给我的公众号 `BeeBee生信` 留言。   
## 脚本目录
**GdcApi.py**  
提供 GDC Manifest 文件利用 GDC API 批量下载 GDC 文件。  
  
**MergeExpressionData**  
合并下载的表达文件。  
  
**Ensembl2Symbol**  
下载的表达值文件合并后基因ID默认为 Ensembl ID 用 BioMart 添加 SYMBOL 和 ENTREZ ID 。  
分为在线版和本地版，本地版需要下载 BioMart 数据库信息。  
  
**FPKM2TPM.R**  
将 FPKM 矩阵转换到 TPM 。  
**注意：** 不建议这么做！  
  
**Log2FPKM.R**  
进行 `log2(FPKM + 1)` 转换。  

