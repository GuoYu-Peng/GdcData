## GdcData
从 [GDC](https://portal.gdc.cancer.gov/) 下载和处理 TCGA 数据，脚本都很简单不专门写文档。有疑问先看脚本内注释信息，注释信息无法解答的就提 Issue 或者给我的公众号 `Hello BioInfo` 留言。   
### 脚本目录
**GdcApi.py**  
提供 GDC Menifest 文件利用 GDC API 大批量下载 GDC 文件。  
  
**MergeExpressionData**  
合并下载的文件。  
  
**Ensembl2Symbol.R**  
下载的表达值文件合并后基因ID默认为 Ensembl ID 用这个脚本添加 SYMBOL 和 ENTREZ ID 。  
  
**FPKM2TPM.R**  
将 FPKM 矩阵转换到 TPM 。  
**注意：** 不建议这么做！  
