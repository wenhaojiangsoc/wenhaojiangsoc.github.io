#!/usr/bin/env bash
#SBATCH --job-name=boot
#SBATCH --partition=common
#SBATCH --array=1-100%20
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%A_%a.out

module load R-openblas/4.6.1
Rscript boot.R
