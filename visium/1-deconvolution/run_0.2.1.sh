#!/bin/bash
#SBATCH --job-name=0.2.1
#SBATCH --output=0.2.1_%j.log
#SBATCH --error=0.2.1_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G

source ~/.bashrc
conda activate COVID

Rscript 0.2.1-SPOTlight_ln_reference.r
exit 0
