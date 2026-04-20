#!/bin/bash
#SBATCH --job-name=mc_pi_mp
#SBATCH --output=mc_pi_mp_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

# 10 CPUs allocated; the script reads os.sched_getaffinity(0) to discover them,
# spawns 10 worker processes (one per CPU), and submits 20 tasks.

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

# Prevent nested threading: each worker runs single-threaded Numba.
export OMP_NUM_THREADS=1
export NUMBA_NUM_THREADS=1

N_SAMPLES=1000000
N_TASKS=20
SEED=20260421

echo "=== multiprocessing: $(python -c 'import os; print(len(os.sched_getaffinity(0)))') workers, ${N_TASKS} tasks ==="
python -m section_05_python_array_jobs_parallelism_strategies.ex06_multiprocessing.monte_carlo_pi_multiprocessing \
    -d 2 -n "${N_SAMPLES}" -s "${SEED}" --tasks "${N_TASKS}"
