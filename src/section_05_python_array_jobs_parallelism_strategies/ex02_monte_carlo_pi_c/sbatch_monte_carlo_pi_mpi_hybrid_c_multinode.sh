#!/bin/bash
#SBATCH --job-name=mc_pi_mn
#SBATCH --output=mc_pi_mn_%j.out
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --time=00:02:00

# Weak-scaling companion to sbatch_monte_carlo_pi_mpi_hybrid_c.sh (single node).
#
# The single-node script is a hybrid decomposition sweep: total resources are
# fixed (always 144 workers on one node) and N is fixed — only the MPI/thread
# split varies.  That is neither strong nor weak scaling; it finds the best
# decomposition for a given node count.
#
# This script repeats that decomposition sweep on 4 nodes and is the weak-
# scaling (Gustafson's law) counterpart: resources grow 4× (144 → 576 workers)
# while per-thread work is kept constant, so total samples also grow 4×.
# Under ideal weak scaling the wall-clock time stays constant as you add nodes.
#
#   The -n argument is samples *per thread* (the code multiplies by ranks×threads
#   internally), so keeping N the same keeps per-thread work — and therefore
#   wall-clock time — identical.  Total samples grow 4× (144 → 576 workers).
#
#   Single node:  144 workers,  N = 2^29 per thread  →  144 × 2^29 total samples
#   Four nodes:   576 workers,  N = 2^29 per thread  →  576 × 2^29 total samples
#
# Parallelism hierarchy:
#   MPI (distributed memory, across nodes via network interconnect)
#     └── OpenMP threads (shared memory, within one node)
#
# As nproc grows from 4→576 and nthreads shrinks from 144→1 the balance shifts
# from "few fat ranks, lots of threads" toward "many thin ranks, no threading".
# The cross-over point reveals the relative cost of MPI communication versus
# OpenMP thread synchronisation on this hardware.

N=536870912                # 2^29 — same as single-node script; -n is samples *per thread*
TOTAL_WORKERS=$((4 * 144)) # 4 nodes × 144 cores per node = 576
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset
module load PrgEnv-gnu

# srun #################################################################
# All entries must be:
#   (a) exact divisors of 576  →  nthreads = TOTAL_WORKERS / nproc is a whole number
#   (b) multiples of 4 (number of nodes)  →  ranks distribute evenly, one node never
#       gets more ranks × threads than it has cores (avoids oversubscription).
# Range: nproc=4 (1 rank/node, pure threading) to nproc=576 (1 thread/rank, pure MPI).
NPROCS_LIST=(4 8 12 16 24 32 36 48 72 96 144 192 288 576)

for nproc in "${NPROCS_LIST[@]}"; do
    nthreads=$((TOTAL_WORKERS / nproc))
    ntasks_per_node=$((nproc / 4))
    echo "=== N_PROC=${nproc}, N_THREADS=${nthreads} ==="
    export OMP_NUM_THREADS="${nthreads}"
    srun -n "${nproc}" --ntasks-per-node="${ntasks_per_node}" \
        --cpus-per-task="${nthreads}" --cpu_bind=cores \
        monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
done
