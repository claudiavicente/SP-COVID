## Reference normalization

setwd("/scratch_isilon/groups/singlecell/shared/projects/covid-pascual-reguant")

library(here)
library(glue)
library(tidyverse)
library(BiocParallel)
library(HDF5Array)
library(SingleCellExperiment)
library(scater)
library(scran)

dir <- "~/SP-COVID/visium/1-deconvolution/data/spatial_tonsil_atlas"
files <- c("A1.rds", "A2.rds", "C1.rds")

ref_ls <- lapply(files, function(i) {
    ref <- glue::glue("{dir}/{i}") %>%
        readRDS(file = .)
    ref$section_id <- tools::file_path_sans_ext(i)
    ref
})
ref <- do.call(cbind, ref_ls)
ref <- ref[, !is.na(ref$lv1) & ref$lv1 != "epi"]

spe <- loadHDF5SummarizedExperiment(
  dir = "~/SP-COVID/visium/0-processing/out/3-annot_ln_spe" %>%
    glue::glue() %>%
    here::here()
)

rowData(spe)$ensembl <- rownames(spe)
rownames(spe) <- rowData(spe)$gene_name
common_genes <- intersect(rownames(ref), rowData(spe)$gene_name)
ref <- ref[common_genes, ]

ref <- ref[, colSums(counts(ref)) > 0]
ref <- computeLibraryFactors(ref)
ref <- logNormCounts(ref, BPPARAM = MulticoreParam(workers = 18))

saveHDF5SummarizedExperiment(
    x = ref, replace = TRUE,
    dir = glue::glue("{dir}/tonsil_atlas_normalized")
)

sessionInfo()
