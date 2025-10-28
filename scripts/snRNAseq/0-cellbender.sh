#!/bin/bash
#SBATCH --job-name=cellbender
#SBATCH --error=./%x.%A_%a.err
#SBATCH --output=./%x.%A_%a.out
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=64G

# General script for running cellbender for all the files

source /home/groups/singlecell/cvicente/miniconda3/etc/profile.d/conda.sh
conda activate cellbender

INPUT_FILE="/scratch_isilon/groups/singlecell/shared/projects/covid-pascual-reguant/data/snRNAseq/[GSM*.h5]" # e.g. file name

base=$(basename "$INPUT_FILE" .h5)

cellbender remove-background \
  --input "$INPUT_FILE" \
  --output "${base}.h5" \
  --cpu-threads 4
