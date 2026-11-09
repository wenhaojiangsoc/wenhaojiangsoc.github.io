#!/usr/bin/env bash
#SBATCH --job-name=mnist
#SBATCH --partition=gpu-common
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%j.out

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate torch
python mnist.py
