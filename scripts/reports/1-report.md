---
title: "Project report 1"
author: "Clàudia Vicente"
date: "09 October, 2025"
output:
  html_document:
    number_sections: true
    toc: true
    toc_depth: 3
    toc_float: true
    fig_caption: true
    keep_md: true
    df_print: paged
editor_options: 
  markdown: 
    wrap: sentence
  chunk_output_type: inline
---



# Introduction

This report contain the overview and exploration of the dataset and the analysis that have been previously performed for the project.

# Libraries


``` r
library(Seurat)
library(tidyverse)
library(dplyr)
library(glue)
library(kableExtra)
library(ggplot2)
library(DataExplorer)
library(summarytools)
```

# Parameters


``` r
set.seed(123)
```

# snRNA-seq

First, we are going to take a look at the snRNA-seq data after the pre-processing.

## Load data


``` r
se <- "data/snRNAseq/lung_autopsy_all.rds" %>%
  here::here() %>%
  readRDS(.)
meta <- se@meta.data
```

## Data overview & exploration

The data consists of 8 samples from different donors from lung autopsies, consisting of 6 COVID-19 cases stratified in different stages and 2 controls. The data dimensions are 35625 cells by 38720 genes.
In the table below \@ref(tab:exp), we can see a summary of the experimental design and the number of cells per donor and condition:


``` r
tab <- meta %>%
  group_by(donor, condition) %>%
  summarise(n_cells = n()) %>%
  ungroup() %>%
  arrange(condition, donor)

tab <- rbind(tab, c("Total", "", sum(tab$n_cells)))
colnames(tab) <- c("Donor", "Stage", "Nº cells")
tab$`Nº cells` <- as.numeric(tab$`Nº cells`)

s_cols <- setNames(
  c("#1CB55C", "#168D48", "#4AE38A", "#0D542B")[1:length(unique(tab$Stage[tab$Stage != ""]))],
  unique(tab$Stage[tab$Stage != ""])
)
c_cols <- rep("", nrow(tab))
c_cols[1:8] <- spec_color(tab$`Nº cells`[1:8], end = 0.8, option = "A", direction = 1, begin = 0.3)

knitr::kable(tab, caption = "Table 1. Summary of the experimental design and number of cells per donor and condition.", 
             booktabs = TRUE, escape = FALSE) %>%
  kable_styling(latex_options = c("hold_position"), 
                bootstrap_options = c("striped", "hover"), 
                full_width = TRUE, 
                position = "center") %>%
  column_spec(1, color = "#404040", bold = TRUE) %>%
  column_spec(2, color = ifelse(tab$Stage == "", "white", s_cols[tab$Stage])) %>%
  column_spec(3, color = c_cols) %>%
  row_spec(nrow(tab), color = "black", bold = TRUE)
```

<table class="table table-striped table-hover" style="color: black; margin-left: auto; margin-right: auto;">
<caption>Table 1. Summary of the experimental design and number of cells per donor and condition.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Donor </th>
   <th style="text-align:left;"> Stage </th>
   <th style="text-align:right;"> Nº cells </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> O325 </td>
   <td style="text-align:left;color: rgba(28, 181, 92, 255) !important;"> akut </td>
   <td style="text-align:right;color: rgba(163, 48, 126, 255) !important;"> 3781 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> T128 </td>
   <td style="text-align:left;color: rgba(28, 181, 92, 255) !important;"> akut </td>
   <td style="text-align:right;color: rgba(100, 26, 128, 255) !important;"> 1753 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> A333 </td>
   <td style="text-align:left;color: rgba(22, 141, 72, 255) !important;"> chronic </td>
   <td style="text-align:right;color: rgba(228, 79, 100, 255) !important;"> 5940 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> A344 </td>
   <td style="text-align:left;color: rgba(22, 141, 72, 255) !important;"> chronic </td>
   <td style="text-align:right;color: rgba(125, 35, 130, 255) !important;"> 2561 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> 17B </td>
   <td style="text-align:left;color: rgba(74, 227, 138, 255) !important;"> control </td>
   <td style="text-align:right;color: rgba(117, 33, 129, 255) !important;"> 2319 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> BB73 </td>
   <td style="text-align:left;color: rgba(74, 227, 138, 255) !important;"> control </td>
   <td style="text-align:right;color: rgba(249, 121, 93, 255) !important;"> 7234 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> A592 </td>
   <td style="text-align:left;color: rgba(13, 84, 43, 255) !important;"> prolonged </td>
   <td style="text-align:right;color: rgba(162, 48, 126, 255) !important;"> 3756 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;"> T188 </td>
   <td style="text-align:left;color: rgba(13, 84, 43, 255) !important;"> prolonged </td>
   <td style="text-align:right;color: rgba(254, 159, 109, 255) !important;"> 8281 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: rgba(64, 64, 64, 255) !important;font-weight: bold;color: black !important;"> Total </td>
   <td style="text-align:left;color: white !important;font-weight: bold;color: black !important;">  </td>
   <td style="text-align:right;color:  !important;font-weight: bold;color: black !important;"> 35625 </td>
  </tr>
</tbody>
</table>

In the **pre-processing**, the cells with more than 10% of of mitochondrial genes, more than 5,000 genes and doublets were removed. Then, the data was normalized using `NormalizeData()` function with a scale factor of 10,000 and the *LogNormalize* method. The 2,000 most variable features were identified using the `FindVariableFeatures()` function with the *vst* method, and cell cycle scores were calculated using the `CellCycleScoring()` function. Batch effect was then removed with `IntegrateData()` function using the donor as batch variable.
After scaling the data with the `ScaleData()` function, a PCA was performed using the `RunPCA()` function and the first 20 PCs were used to find neighbors with the `FindNeighbors()` function and to compute UMAP coordinates with the `RunUMAP()` function. Finally, clustering was performed using the `FindClusters()` function with the default parameters and the dataset by [Travaglini et al.](https://doi.org/10.1101/742320) was used to score cell types:


``` r
DimPlot(se, group.by='predicted.id', label=TRUE, repel=TRUE) + NoLegend()
```

<img src="1-report_files/figure-html/unnamed-chunk-4-1.svg" width="100%" style="display: block; margin: auto;" />

### Metadata descriptive analysis

Most of the metadata variables are part of the cell annotation prediction, but we also have variables of interest such as the percentage of mitochondrial, ribosomal and SARS-CoV-2 genes, or the predicted cell-type, cell cycle phase, ... Below we can see a summary and some plots of the metadata variables.


``` r
plot_intro(meta)
```

<img src="1-report_files/figure-html/unnamed-chunk-5-1.svg" width="100%" style="display: block; margin: auto;" />

``` r
head(meta)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["orig.ident"],"name":[1],"type":["chr"],"align":["left"]},{"label":["nCount_RNA"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["nFeature_RNA"],"name":[3],"type":["int"],"align":["right"]},{"label":["scrublet_score"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["scrublet_prediction"],"name":[5],"type":["chr"],"align":["left"]},{"label":["donor"],"name":[6],"type":["chr"],"align":["left"]},{"label":["condition"],"name":[7],"type":["chr"],"align":["left"]},{"label":["origin"],"name":[8],"type":["chr"],"align":["left"]},{"label":["pct.mito"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["pct.ribo"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pct.MALAT1"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["pct.SCoV2"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["S.Score"],"name":[13],"type":["dbl"],"align":["right"]},{"label":["G2M.Score"],"name":[14],"type":["dbl"],"align":["right"]},{"label":["Phase"],"name":[15],"type":["chr"],"align":["left"]},{"label":["integrated_snn_res.0.8"],"name":[16],"type":["fct"],"align":["left"]},{"label":["seurat_clusters"],"name":[17],"type":["fct"],"align":["left"]},{"label":["predicted.id"],"name":[18],"type":["chr"],"align":["left"]},{"label":["prediction.score.Capillary.Aerocyte"],"name":[19],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Capillary"],"name":[20],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Capillary.Intermediate.1"],"name":[21],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Capillary.Intermediate.2"],"name":[22],"type":["dbl"],"align":["right"]},{"label":["prediction.score.IGSF21..Dendritic"],"name":[23],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Myeloid.Dendritic.Type.1"],"name":[24],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Plasmacytoid.Dendritic"],"name":[25],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Myeloid.Dendritic.Type.2"],"name":[26],"type":["dbl"],"align":["right"]},{"label":["prediction.score.B"],"name":[27],"type":["dbl"],"align":["right"]},{"label":["prediction.score.EREG..Dendritic"],"name":[28],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Macrophage"],"name":[29],"type":["dbl"],"align":["right"]},{"label":["prediction.score.CD8..Naive.T"],"name":[30],"type":["dbl"],"align":["right"]},{"label":["prediction.score.CD4..Naive.T"],"name":[31],"type":["dbl"],"align":["right"]},{"label":["prediction.score.CD4..Memory.Effector.T"],"name":[32],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Vein"],"name":[33],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Artery"],"name":[34],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Pericyte"],"name":[35],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Vascular.Smooth.Muscle"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Club"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Mucous"],"name":[38],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Alveolar.Epithelial.Type.2"],"name":[39],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Basal"],"name":[40],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Lymphatic"],"name":[41],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Proliferating.Macrophage"],"name":[42],"type":["dbl"],"align":["right"]},{"label":["prediction.score.CD8..Memory.Effector.T"],"name":[43],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Proliferating.NK.T"],"name":[44],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Natural.Killer.T"],"name":[45],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Natural.Killer"],"name":[46],"type":["dbl"],"align":["right"]},{"label":["prediction.score.OLR1..Classical.Monocyte"],"name":[47],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Basophil.Mast.1"],"name":[48],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Classical.Monocyte"],"name":[49],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Intermediate.Monocyte"],"name":[50],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Nonclassical.Monocyte"],"name":[51],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Airway.Smooth.Muscle"],"name":[52],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Ciliated"],"name":[53],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Alveolar.Fibroblast"],"name":[54],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Myofibroblast"],"name":[55],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Adventitial.Fibroblast"],"name":[56],"type":["dbl"],"align":["right"]},{"label":["prediction.score.Alveolar.Epithelial.Type.1"],"name":[57],"type":["dbl"],"align":["right"]},{"label":["prediction.score.max"],"name":[58],"type":["dbl"],"align":["right"]},{"label":["DF.classifications"],"name":[59],"type":["chr"],"align":["left"]}],"data":[{"1":"A333-chronic","2":"15851","3":"4958","4":"0.06144578","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"0.0000000","10":"0.2712763","11":"8.100435","12":"0","13":"-0.0474473340","14":"-0.0276820418","15":"G1","16":"13","17":"13","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.001034876","36":"0","37":"0.1180805","38":"0","39":"0.00000000","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.8808847","58":"0.8808847","59":"Singlet","_rn_":"A333-chronic_CAGCCAGGTCCTCCTA-1"},{"1":"A333-chronic","2":"15486","3":"4943","4":"0.06778567","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"0.6263722","10":"0.2970425","11":"11.080976","12":"0","13":"-0.0595163866","14":"0.0006781348","15":"G2M","16":"3","17":"3","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.000000000","36":"0","37":"0.3799965","38":"0","39":"0.04663658","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.5733669","58":"0.5733669","59":"Singlet","_rn_":"A333-chronic_GAAACCTCAGCAAGAC-1"},{"1":"A333-chronic","2":"15173","3":"4806","4":"0.05767013","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"0.3295327","10":"0.2043103","11":"8.343769","12":"0","13":"-0.0262166437","14":"-0.0177147979","15":"G1","16":"13","17":"13","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.001099190","36":"0","37":"0.1101134","38":"0","39":"0.00000000","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.8887874","58":"0.8887874","59":"Singlet","_rn_":"A333-chronic_TCAGCAACAAAGACGC-1"},{"1":"A333-chronic","2":"14350","3":"4671","4":"0.08682171","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"0.0000000","10":"0.3554007","11":"8.508711","12":"0","13":"-0.0020833286","14":"-0.0503248428","15":"G1","16":"13","17":"13","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.004388537","36":"0","37":"0.1408659","38":"0","39":"0.00000000","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.8547456","58":"0.8547456","59":"Singlet","_rn_":"A333-chronic_TCAATCTTCCTTGAAG-1"},{"1":"A333-chronic","2":"13114","3":"4735","4":"0.05767013","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"2.7985359","10":"0.3736465","11":"7.709318","12":"0","13":"-0.0006087559","14":"-0.0484786616","15":"G1","16":"3","17":"3","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.000000000","36":"0","37":"0.1480457","38":"0","39":"0.03340865","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.8185456","58":"0.8185456","59":"Singlet","_rn_":"A333-chronic_TATGTTCCATCATCCC-1"},{"1":"A333-chronic","2":"13066","3":"4495","4":"0.04666332","5":"singlet","6":"A333","7":"chronic","8":"autopsy","9":"0.9184142","10":"0.1071483","11":"11.709781","12":"0","13":"-0.0074831596","14":"0.0116782168","15":"G2M","16":"13","17":"13","18":"Alveolar Epithelial Type 1","19":"0","20":"0","21":"0","22":"0","23":"0","24":"0","25":"0","26":"0","27":"0","28":"0","29":"0","30":"0","31":"0","32":"0","33":"0","34":"0","35":"0.001056148","36":"0","37":"0.1265300","38":"0","39":"0.00000000","40":"0","41":"0","42":"0","43":"0","44":"0","45":"0","46":"0","47":"0","48":"0","49":"0","50":"0","51":"0","52":"0","53":"0","54":"0","55":"0","56":"0","57":"0.8724138","58":"0.8724138","59":"Singlet","_rn_":"A333-chronic_ACTATCTTCATCGACA-1"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

``` r
categorical <- c("predicted.id", "Phase", "condition", "origin", "donor")
continuous <- c("prediction.score.max", "pct.mito", "pct.ribo", "pct.SCoV2",
  "nCount_RNA", "nFeature_RNA", "scrublet_score")
```

#### Continuous variables


``` r
descr(meta[,continuous])
```

```
## Descriptive Statistics  
## meta  
## N: 35625  
## 
##                     nCount_RNA   nFeature_RNA   pct.mito   pct.ribo   pct.SCoV2
## ----------------- ------------ -------------- ---------- ---------- -----------
##              Mean      1990.13        1164.35       1.64       0.55        0.05
##           Std.Dev      1649.50         660.52       2.26       0.83        1.03
##               Min       556.00         500.00       0.00       0.00        0.00
##                Q1       952.00         690.00       0.00       0.09        0.00
##            Median      1411.00         950.00       0.62       0.30        0.00
##                Q3      2379.00        1425.00       2.33       0.69        0.00
##               Max     16181.00        4981.00      10.00      16.77       60.12
##               MAD       836.19         465.54       0.91       0.38        0.00
##               IQR      1427.00         735.00       2.33       0.60        0.00
##                CV         0.83           0.57       1.38       1.50       20.12
##          Skewness         2.69           1.77       1.72       4.52       34.90
##       SE.Skewness         0.01           0.01       0.01       0.01        0.01
##          Kurtosis        10.07           3.76       2.30      36.04     1470.99
##           N.Valid     35625.00       35625.00   35625.00   35625.00    35625.00
##                 N     35625.00       35625.00   35625.00   35625.00    35625.00
##         Pct.Valid       100.00         100.00     100.00     100.00      100.00
## 
## Table: Table continues below
## 
##  
## 
##                     prediction.score.max   scrublet_score
## ----------------- ---------------------- ----------------
##              Mean                   0.78             0.06
##           Std.Dev                   0.21             0.04
##               Min                   0.14             0.00
##                Q1                   0.62             0.04
##            Median                   0.85             0.05
##                Q3                   0.97             0.08
##               Max                   1.00             0.55
##               MAD                   0.21             0.03
##               IQR                   0.35             0.04
##                CV                   0.27             0.68
##          Skewness                  -0.80             2.61
##       SE.Skewness                   0.01             0.01
##          Kurtosis                  -0.46            12.88
##           N.Valid               35625.00         35625.00
##                 N               35625.00         35625.00
##         Pct.Valid                 100.00           100.00
```

``` r
plot_histogram(meta[,continuous], geom_histogram_args = list("fill" = "#a6cee3", "color" = "#1f78b4"), ggtheme = theme_minimal())
```

<img src="1-report_files/figure-html/unnamed-chunk-6-1.svg" width="100%" style="display: block; margin: auto;" />

``` r
FeaturePlot(
    se,
    features = continuous)
```

<img src="1-report_files/figure-html/unnamed-chunk-6-2.svg" width="100%" style="display: block; margin: auto;" />

#### Categorical variables


``` r
update_geom_defaults("bar", list(fill = "#a6cee3", color = "#1f78b4"))
plot_bar(meta[,categorical], ggtheme = theme_minimal())
```

<img src="1-report_files/figure-html/unnamed-chunk-7-1.svg" width="100%" style="display: block; margin: auto;" />

``` r
DimPlot(
    se,
    group.by = categorical,
    label = FALSE) & NoLegend()
```

<img src="1-report_files/figure-html/unnamed-chunk-7-2.svg" width="100%" style="display: block; margin: auto;" />


### SARS-CoV-2 positive cells
do descriptive analysis of scov2 by condition and cell type



``` r
#FeaturePlot(
#    se,
#    features = "pct.SCoV2", cells.highlight = WhichCells(se, expression = pct.SCoV2 > 0),
#    cols = c("lightgrey", "red"),
#    pt.size = 0.5) +
#    labs(title = "SARS-CoV-2 positive cells")
```


``` r
lapply(unique(se$condition), function(i) {
    VlnPlot(
        se[, se$condition == i],
        features = "pct.SCoV2",
        group.by = "predicted.id") +
        NoLegend() +
        labs(title = glue("{i} - pct.SCoV2"))
})
```

```
## [[1]]
```

<img src="1-report_files/figure-html/unnamed-chunk-9-1.svg" width="100%" style="display: block; margin: auto;" />

```
## 
## [[2]]
```

<img src="1-report_files/figure-html/unnamed-chunk-9-2.svg" width="100%" style="display: block; margin: auto;" />

```
## 
## [[3]]
```

<img src="1-report_files/figure-html/unnamed-chunk-9-3.svg" width="100%" style="display: block; margin: auto;" />

```
## 
## [[4]]
```

<img src="1-report_files/figure-html/unnamed-chunk-9-4.svg" width="100%" style="display: block; margin: auto;" />

## Annotation







































