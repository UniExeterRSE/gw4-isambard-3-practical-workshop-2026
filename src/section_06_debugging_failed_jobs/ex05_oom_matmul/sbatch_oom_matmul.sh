#!/bin/bash
#SBATCH --job-name=oom_matmul
#SBATCH --output=oom_matmul_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

N=32768
export OMP_NUM_THREADS=1

module reset
module load PrgEnv-gnu

echo "=== Running matmul_naive (N=${N}) ==="
command time -v ./matmul_naive "${N}"
