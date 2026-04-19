#!/bin/bash
#SBATCH --job-name=mc_pi_py
#SBATCH --output=mc_pi_py.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:01:00

N=536870912 # 2^29
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset
module load PrgEnv-gnu

# TODO: Pixi may not be on PATH after module reset, so add its install prefix first.
export PATH="${HOME}/.local/opt/Linux-aarch64/system/bin:${PATH:-}"
# Activate the pixi hpc environment (mpi4py linked against MPICH, not OpenMPI).
eval "$(pixi shell-hook --environment hpc)"

# mpi4py (MPICH build) links against libmpi.so.12. Cray MPICH provides this in lib-abi-mpich/
# TODO: Prepend it so the dynamic linker finds it before pixi's empty mpich stub.
export LD_LIBRARY_PATH="${MPICH_DIR:-/opt/cray/pe/mpich/default/ofi/gnu/12.3}/lib-abi-mpich:${LD_LIBRARY_PATH:-}"

PROCS=(1 2 3 4 6 8 9 12 16 18 24 36 48 72 144)
NPROCS=${#PROCS[@]}

for ((i = 0; i < NPROCS; i++)); do
    nproc=${PROCS[i]}
    nthreads=${PROCS[NPROCS - 1 - i]}
    echo "=== N_PROC=${nproc}, N_THREADS=${nthreads} ==="
    export NUMBA_NUM_THREADS="${nthreads}"
    srun -n "${nproc}" --cpus-per-task="${nthreads}" --cpu_bind=cores \
        monte-carlo-pi-mpi-hybrid -d 2 -n "${N}" --num-threads "${nthreads}"
done
