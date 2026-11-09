#!/usr/bin/env bash
#SBATCH --job-name=combine
#SBATCH --partition=common
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x_%j.out

module load R-openblas/4.6.1
Rscript combine.R
