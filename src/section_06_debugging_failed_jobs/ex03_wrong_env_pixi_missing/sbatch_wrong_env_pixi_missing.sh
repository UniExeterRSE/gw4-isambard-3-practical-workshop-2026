#!/bin/bash
#SBATCH --job-name=wrong_env_pixi_missing
#SBATCH --output=wrong_env_pixi_missing_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

NUM_THREADS=4
export NUMBA_NUM_THREADS=${NUM_THREADS}

module reset

monte-carlo-pi-summary -d 2 -n 200000 -t ${NUM_THREADS}
