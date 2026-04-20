#!/bin/bash
#SBATCH --job-name=mc_pi_futures
#SBATCH --output=mc_pi_futures_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=36
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

set -euo pipefail

# 36 MPI ranks x 4 CPUs = 144 cores on one Grace node.
# Rank 0 is the controller, so 35 worker ranks execute the 36 tasks.
N_TASKS=36
N_SAMPLES_PER_THREAD=$((2 ** 29))
N_THREADS=4
SEED=20260421

# Loading environments #################################################
module reset
module load PrgEnv-gnu

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

# shellcheck disable=SC2154
export LD_LIBRARY_PATH="${MPICH_DIR}/lib-abi-mpich:${LD_LIBRARY_PATH}"
export NUMBA_NUM_THREADS="${N_THREADS}"
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

# Run ##################################################################
echo "=== mpi4py.futures MPIPoolExecutor: 35 workers, ${N_TASKS} tasks, ${N_THREADS} threads/task ==="
srun --ntasks=36 --cpus-per-task=4 --cpu_bind=cores \
    python -m mpi4py.futures \
    -m section_05_python_array_jobs_parallelism_strategies.ex05_mpi4py_futures.monte_carlo_pi_mpi4py_futures \
    -d 2 -n "${N_SAMPLES_PER_THREAD}" -t "${N_THREADS}" -s "${SEED}" --tasks "${N_TASKS}"
