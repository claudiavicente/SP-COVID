# PAPER TITLE

This repository contains the analysis code for the study:

> **PAPER TITLE**  
> Clàudia Vicente-Comorera, Anna Pascual-Reguant   
> *Spatial Genomics Team, CNAG*
> 
> This repository serves as the codebase for my Master's thesis in **Bioinformatics for Health Sciences** at the **Universitat Pompeu Fabra (UPF)**, supervised by Anna Pascual Reguant.

## Overview

This study integrates Spatial Transcriptomics, single-nucleus RNA sequencing, and spatial T cell receptor sequencing from patient-matched lung and draining lymph node tissue to characterize the spatial organization of adaptive immune responses across acute, chronic, and prolonged COVID-19 disease stages, benchmarked against bacterial pneumonia controls.

Analyses include quality control and processing of snRNA-seq and ST data, cell-type annotation, spatial domain identification, cell-type deconvolution (`SPOTlight`), compositional analysis (`sccomp`), spatially resolved cell-cell communication inference (`LIANA+`/NMF), and exploratory spatial TCR clonotype analysis.

## Repository structure

```
 # snRNA-seq QC, processing, and cell-type annotation
├── snRNAseq/
│   └── 0-annotation/              
│       ├── 0.1-create_previous_lvl3.ipynb
│       ├── 0.2-annotation_inspection_lung.ipynb
│       └── 1-annotation_consolidation_lung.ipynb
│
# Visium QC, processing, and spatial domain annotation
└── visium/
    ├── 0-processing/               
    │   ├── 0-create_spatialexperiment.ipynb
    │   ├── 1-QC.ipynb
    │   ├── 2.1-processing_lung.ipynb
    │   ├── 2.2-processing_ln.ipynb
    │   ├── 3.1-annotation_lung.ipynb
    │   └── 3.2-annotation_ln.ipynb
    │
    # SPOTlight cell-type deconvolution
    ├── 1-deconvolution/            
    │   ├── 0.1-SPOTlight_lung.ipynb
    │   ├── 0.2.1-SPOTlight_ln_reference.r
    │   ├── 0.2.2-SPOTlight_ln.ipynb
    │   ├── 1.1-SPOTlight_analysis_lung.ipynb
    │   └── 1.2-SPOTlight_analysis_ln.ipynb           
    └── 2-analysis/
        │
        # Cell-cell communication (LIANA+ / NMF / GSEA)
        ├── CCC/                    
        │   ├── 0-export_data.ipynb
        │   └── 1-CCC.ipynb
        │
        # Compositional analysis (sccomp)
        ├── COMP/                   
        │   └── 0-compositional_lung.ipynb
        │
        # SARS-CoV-2 read mapping and expression analysis
        ├── COVID/                  
        │   └── 0-covid_expression.ipynb
        │
        # Spatial TCR clonotype exploration
        └── TCR/                    
            ├── 0-TCR_exploration.ipynb
            └── 1-TCR_spatial.ipynb
```

> **Note:** `out/` and `data/` directories are not tracked.

## Data availability

| Modality | Accession / source |
|---|---|
| Spatial Transcriptomics (Visium) | GEO: GSE190732 |
| snRNA-seq (Chromium) | GEO: GSM5958253–GSM5958260 |
| Spatial TCR-seq (circVDJ-seq) | *To be deposited upon publication of the original study* |
| Tonsil atlas reference (dLN deconvolution) | [Crowell *et al.* 2026](https://doi.org/10.1002/eji.70121) |

## Software

Full package versions and session information are listed within each notebook.
