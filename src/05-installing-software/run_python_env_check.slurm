#!/bin/bash
#SBATCH --job-name=python-env-check
#SBATCH --output=python_env_check.out
#SBATCH --ntasks=1
#SBATCH --time=00:05:00

# Replace the activation step below with the site-preferred approach used in delivery.
# For example, that may involve loading a module that provides conda or mamba first.

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate isambard3-tutorial
python check_scipy.py
