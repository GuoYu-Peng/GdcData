# GDC CNV 文件下载说明
TCGA 的 CNV 使用 DNACopy, 需要做 CNV 分析时在 GDC 下载 seg 文件，而一般每个病人包含 4 个 seg 文件，2 个正常组织 2 个肿瘤组织。举例：  

```bash
File ID	File Name	Data Category	Data Type	Project ID	Case ID	Sample ID	Sample Type  
945786ae-2fcc-4c35-9f4e-a5af3c1c461c	HERMS_p_TCGAb_391_NSP_GenomeWideSNP_6_F06_1473594.nocnv_grch38.seg.v2.txt	Copy Number Variation	Masked Copy Number Segment	TCGA-BLCA	TCGA-2F-A9KO	TCGA-2F-A9KO-11A	Solid Tissue Normal
1f181c95-a848-492c-8887-1b44373f91e0	HERMS_p_TCGAb_391_NSP_GenomeWideSNP_6_F06_1473594.grch38.seg.v2.txt	Copy Number Variation	Copy Number Segment	TCGA-BLCA	TCGA-2F-A9KO	TCGA-2F-A9KO-11A	Solid Tissue Normal
a1f83e71-c5ab-4cb7-b841-40c7255a4f99	HERMS_p_TCGAb_391_NSP_GenomeWideSNP_6_F07_1473568.nocnv_grch38.seg.v2.txt	Copy Number Variation	Masked Copy Number Segment	TCGA-BLCA	TCGA-2F-A9KO	TCGA-2F-A9KO-01A	Primary Tumor
f38b2b41-83ca-406f-ad8c-f0776eb32617	HERMS_p_TCGAb_391_NSP_GenomeWideSNP_6_F07_1473568.grch38.seg.v2.txt	Copy Number Variation	Copy Number Segment	TCGA-BLCA	TCGA-2F-A9KO	TCGA-2F-A9KO-01A	Primary Tumor
```

其中 `*.nocnv_grch38.seg.v2.txt` 文件是移除了 Y 染色体区域和胚系(germline) CNV 的结果，如果要做 Somatic CNV 分析，就是取肿瘤组织的这个 seg 文件。原文描述：  
> Masked copy number segments are generated using the same method except that a filtering step is performed that removes the Y chromosome and probe sets that were previously indicated to be associated with frequent germline copy-number variation.
> 

## 参考资料
[Bioinformatics Pipeline: Copy Number Variation Analysis - GDC Docs](https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/CNV_Pipeline/)