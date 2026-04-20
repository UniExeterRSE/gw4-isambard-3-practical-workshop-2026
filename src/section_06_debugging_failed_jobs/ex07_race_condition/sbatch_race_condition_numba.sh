#!/bin/bash
#SBATCH --job-name=race_numba
#SBATCH --output=race_condition_numba_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:02:00

export NUMBA_NUM_THREADS=8

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

python race_condition_numba.py
