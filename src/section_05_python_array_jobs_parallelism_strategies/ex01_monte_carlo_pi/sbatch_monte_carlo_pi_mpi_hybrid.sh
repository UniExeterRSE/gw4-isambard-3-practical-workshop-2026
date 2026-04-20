#!/bin/bash
#SBATCH --job-name=mc_pi_py
#SBATCH --output=mc_pi_py_%j.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:01:00

N=536870912 # 2^29
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

# Loading environments #################################################
# Cray compiler environment
module reset
module load PrgEnv-gnu

# pixi hpc environment
# Advanced users: use `mamba env create -f environment_hpc.yml -n isambard3-workshop-hpc -y`
# once, then replace the eval line below with:
# mamba activate isambard3-workshop-hpc
# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

# bridging Cray's MPICH library to pixi's external MPICH library
# Cray MPICH provides this in lib-abi-mpich/
# shellcheck disable=SC2154
export LD_LIBRARY_PATH="${MPICH_DIR}/lib-abi-mpich:${LD_LIBRARY_PATH}"

# srun #################################################################

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
