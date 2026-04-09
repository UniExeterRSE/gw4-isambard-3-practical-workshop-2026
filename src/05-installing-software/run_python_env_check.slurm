#!/bin/bash
#SBATCH --job-name=python-env-check
#SBATCH --output=python_env_check.out
#SBATCH --ntasks=1
#SBATCH --time=00:05:00

# TODO: confirm the conda/mamba initialisation path with BriCS before delivery.
# CONDA_ROOT_PREFIX and MAMBA_ROOT_PREFIX are set by Miniforge/Mambaforge installations.
# One of the following should work depending on what the site provides:
#   source "${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh"
#   source "${MAMBA_ROOT_PREFIX}/etc/profile.d/conda.sh"

source "${CONDA_ROOT_PREFIX:-${MAMBA_ROOT_PREFIX}}/etc/profile.d/conda.sh"
conda activate isambard3-tutorial
python check_scipy.py
