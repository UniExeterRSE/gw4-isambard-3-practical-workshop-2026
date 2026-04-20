#!/bin/bash
#SBATCH --job-name=mc_pi_single
#SBATCH --output=mc_pi_single_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

NUM_THREADS=4
export NUMBA_NUM_THREADS=${NUM_THREADS}

module reset

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

monte-carlo-pi-summary -d 2 -n 200000 -t ${NUM_THREADS}
