#!/bin/bash
#SBATCH --job-name=matmul
#SBATCH --output=matmul.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00

set -euo pipefail

module reset
module load gcc-native

make matmul

./matmul 1024
