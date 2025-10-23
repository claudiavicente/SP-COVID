library(glue)
library(here)
library(tidyverse)


## Data
dt <- "data"
sn_dt <- glue("{dt}/snRNAseq")
st_dt <- glue("{dt}/visium")
tcr_dt <- glue("{dt}/tcr")



## Outputs
out <- "output"
plots <- glue("{out}/plots")
html <- glue("{out}/html")

## Reports
rep_plots <- glue("{plots}/reports/")
rep_html <- glue("{html}/reports")
## sn
sn_plots <- glue("{plots}/snRNAseq/")
sn_html <- glue("{html}/snRNAseq")
## visium
st_plots <- glue("{plots}/visium/")
st_html <- glue("{html}/visium")
## maybe integration directory in the future



## Output data
sn_odt <- glue("{out}/{dt}/snRNAseq")
st_odt <- glue("{out}/{dt}/visium")
tcr_odt <- glue("{out}/{dt}/tcr")
## maybe integration directory in the future




## Read metadata
load_sample_metadata <- function() {
  sample_metadata <- glue::glue("{st_dt}/sample-metadata.csv") %>%
    here::here() %>%
    readr::read_csv() %>%
    mutate(
      tissue = if_else(tissue == "lymph_node", "lymph-node", tissue),
      donor_tissue = glue::glue("{donor_id}-{tissue}"),
      study_id_tissue = glue::glue("{study_id}-{tissue}")
    )
  
  return(sample_metadata)
}

