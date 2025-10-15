library(glue)
library(here)
library(dplyr)


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

