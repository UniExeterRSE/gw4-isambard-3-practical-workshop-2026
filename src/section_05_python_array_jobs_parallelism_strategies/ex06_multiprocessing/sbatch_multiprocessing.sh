#!/bin/bash
#SBATCH --job-name=mc_pi_mp
#SBATCH --output=mc_pi_mp_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=144
#SBATCH --time=00:05:00

set -euo pipefail

# Match the other map-reduce examples: 36 worker processes x 4 threads = 144 cores.
N_WORKERS=36
N_THREADS=4
N_TASKS=36
N_SAMPLES_PER_THREAD=$((2 ** 29))
SEED=20260421

module reset

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

export OMP_NUM_THREADS="${N_THREADS}"
export NUMBA_NUM_THREADS="${N_THREADS}"
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

echo "=== multiprocessing: ${N_WORKERS} workers, ${N_TASKS} tasks, ${N_THREADS} threads/worker ==="
python -m section_05_python_array_jobs_parallelism_strategies.ex06_multiprocessing.monte_carlo_pi_multiprocessing \
    -d 2 -n "${N_SAMPLES_PER_THREAD}" -t "${N_THREADS}" -s "${SEED}" --workers "${N_WORKERS}" --tasks "${N_TASKS}"
