#!/bin/bash
#SBATCH --job-name=matmul
#SBATCH --output=matmul.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00

set -euo pipefail

module reset
module load PrgEnv-gnu

make all

./matmul_naive 1024
./matmul_naive_flt 1024
./matmul_dgemm 1024
./matmul_sgemm 1024
