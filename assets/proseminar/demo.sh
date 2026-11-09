#!/usr/bin/env bash
#SBATCH --job-name=demo
#SBATCH --partition=common
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out

module load R-openblas/4.6.1
Rscript demo.R
