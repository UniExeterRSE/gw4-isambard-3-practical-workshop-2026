#!/bin/bash
#SBATCH --job-name=mc_pi_array
#SBATCH --output=mc_pi_array_%A_%a.out
#SBATCH --array=1-36%36
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

set -euo pipefail

# Match the other map-reduce examples: 36 task slots x 4 threads = 144 cores.
N_SAMPLES_PER_THREAD=$((2 ** 29))
NUM_THREADS=4
export NUMBA_NUM_THREADS=${NUM_THREADS}
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

monte-carlo-pi-numba-parallel \
    -d 2 \
    -n ${N_SAMPLES_PER_THREAD} \
    -t ${NUM_THREADS} \
    -s ${SLURM_ARRAY_TASK_ID} \
    --save results/mc_pi_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.txt
