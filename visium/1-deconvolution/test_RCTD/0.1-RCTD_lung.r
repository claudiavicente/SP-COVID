setwd("/scratch_isilon/groups/singlecell/shared/projects/covid-pascual-reguant")
library(here)
library(glue)
library(tidyverse)
library(BiocParallel)
library(Seurat)
library(SingleCellExperiment)
library(SpatialExperiment)
library(HDF5Array)
library(scater)
library(scran)
library(spacexr)


se <- "~/SP-COVID/snRNAseq/0-annotation/out/se_annot_filtered.rds" %>%
    readRDS(.)
sce <- as.SingleCellExperiment(se)

spe <- loadHDF5SummarizedExperiment(dir = "~/SP-COVID/visium/0-processing/out/3-annot_lung_spe" %>%
    glue::glue() %>%
    here::here())
colnames(spe) <- paste(colData(spe)$cond_tissue, colnames(spe), sep = "_")
rowData(spe)$ensembl <- rownames(spe)
rownames(spe) <- rowData(spe)$gene_name
rownames(spe) <- make.unique(rownames(spe))

rctd <- createRctd(spe, sce, cell_type_col = "annotation")
res <- runRctd(rctd, rctd_mode = "full", max_cores = 18)

out_dir <- "~/SP-COVID/visium/1-deconvolution/out"
saveHDF5SummarizedExperiment(res, replace = TRUE, dir = "{out_dir}/rctd_lung_spe" %>% 
                             glue::glue())

sessionInfo()