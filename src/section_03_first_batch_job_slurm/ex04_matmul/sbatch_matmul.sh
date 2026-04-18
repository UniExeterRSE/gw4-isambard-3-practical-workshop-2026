#!/bin/bash
#SBATCH --job-name=matmul
#SBATCH --output=matmul.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:02:00

NUM_THREADS=144
N=16384
export OMP_NUM_THREADS=${NUM_THREADS}
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

export NUMEXPR_NUM_THREADS=${NUM_THREADS}

export OPENBLAS_NUM_THREADS=${NUM_THREADS}

module reset
module load PrgEnv-gnu

echo "=== Running matmul_sgemm... ==="
command time -v ./matmul_sgemm "${N}"
echo "=== Running matmul_dgemm... ==="
command time -v ./matmul_dgemm "${N}"
echo "=== Running matmul_naive_flt... ==="
command time -v ./matmul_naive_flt "${N}"
echo "=== Running matmul_naive... ==="
command time -v ./matmul_naive "${N}"
