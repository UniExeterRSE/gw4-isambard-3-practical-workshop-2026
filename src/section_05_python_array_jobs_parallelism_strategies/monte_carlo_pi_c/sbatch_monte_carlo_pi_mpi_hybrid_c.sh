#!/bin/bash
#SBATCH --job-name=mc_pi
#SBATCH --output=mc_pi.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:01:00

N=536870912 # 2^29
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset
module load PrgEnv-gnu

PROCS=(1 2 3 4 6 8 9 12 16 18 24 36 48 72 144)
NPROCS=${#PROCS[@]}

for ((i = 0; i < NPROCS; i++)); do
    nproc=${PROCS[i]}
    nthreads=${PROCS[NPROCS - 1 - i]}
    echo "=== N_PROC=${nproc}, N_THREADS=${nthreads} ==="
    export OMP_NUM_THREADS="${nthreads}"
    srun -n "${nproc}" --cpus-per-task="${nthreads}" --cpu_bind=cores monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
done
