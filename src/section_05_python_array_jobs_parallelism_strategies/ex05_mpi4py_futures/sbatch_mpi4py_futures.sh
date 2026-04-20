#!/bin/bash
#SBATCH --job-name=mc_pi_futures
#SBATCH --output=mc_pi_futures_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=11
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

# 11 MPI ranks: 1 controller (rank 0) + 10 workers (ranks 1-10)
# Each worker runs one task at a time; tasks are distributed by the controller.

# Loading environments #################################################
module reset
module load PrgEnv-gnu

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

# shellcheck disable=SC2154
export LD_LIBRARY_PATH="${MPICH_DIR}/lib-abi-mpich:${LD_LIBRARY_PATH}"

# Run ##################################################################
N_TASKS=20
N_SAMPLES=1000000
SEED=20260421

echo "=== mpi4py.futures MPIPoolExecutor: 10 workers, ${N_TASKS} tasks ==="
srun --ntasks=11 \
    python -m mpi4py.futures \
    -m section_05_python_array_jobs_parallelism_strategies.ex05_mpi4py_futures.monte_carlo_pi_mpi4py_futures \
    -d 2 -n "${N_SAMPLES}" -s "${SEED}" --tasks "${N_TASKS}"
