#!/bin/bash
#SBATCH --job-name=race_condition
#SBATCH --output=race_condition_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:01:00

export OMP_NUM_THREADS=8
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

module reset
module load PrgEnv-gnu

echo "=== Run 1 ==="
./race_condition

echo "=== Run 2 ==="
./race_condition

echo "=== Run 3 ==="
./race_condition
