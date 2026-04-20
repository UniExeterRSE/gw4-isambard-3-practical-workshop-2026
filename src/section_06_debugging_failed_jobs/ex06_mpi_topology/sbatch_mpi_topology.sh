#!/bin/bash
#SBATCH --job-name=mpi_topology
#SBATCH --output=mpi_topology_%j.out
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --time=00:02:00

# Exercise 6 — MPI Topology: Uneven Rank Distribution
#
# This script deliberately uses 6 MPI ranks across 4 nodes.
# 6 ÷ 4 = 1.5 → Slurm cannot distribute evenly:
#   2 nodes get 2 ranks each  →  2 × 96 = 192 threads on 144 cores  (oversubscription)
#   2 nodes get 1 rank each   →  1 × 96 =  96 threads on 144 cores  (48 cores idle)
#
# Wall time is dominated by the oversubscribed nodes, making overall performance
# worse than a configuration that divides evenly (e.g. nproc=4 or nproc=8).
#
# Note: --ntasks-per-node is intentionally omitted so Slurm's default round-robin
# distribution produces the uneven split.

nproc=6
TOTAL_WORKERS=$((4 * 144))          # 4 nodes × 144 cores per node = 576
nthreads=$((TOTAL_WORKERS / nproc)) # 576 / 6 = 96 — same formula as the correct sweep script
N=536870912                         # 2^29 — samples *per thread*

export OMP_NUM_THREADS="${nthreads}"
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset
module load PrgEnv-gnu

# Diagnostic: show which node each of the 6 ranks lands on.
# Repeated hostnames reveal the uneven distribution.
echo "=== Rank → node mapping ==="
srun -n "${nproc}" --cpus-per-task="${nthreads}" hostname

echo ""
echo "=== N_PROC=${nproc}, N_THREADS=${nthreads} ==="
srun -n "${nproc}" --cpus-per-task="${nthreads}" --cpu_bind=cores \
    monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
