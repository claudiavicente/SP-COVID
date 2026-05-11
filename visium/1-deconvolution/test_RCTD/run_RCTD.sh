#!/bin/bash
#SBATCH --job-name=RCTD_deconv_lung
#SBATCH --output=RCTD_deconv_lung_%j.log
#SBATCH --error=RCTD_deconv_lung_%j.err
#SBATCH --ntasks=20
#SBATCH --mem=100G

source ~/.bashrc
conda activate COVID

Rscript 0.1-RCTD_lung.r
