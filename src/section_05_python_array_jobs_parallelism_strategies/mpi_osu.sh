#!/bin/bash
#SBATCH --job-name=test_osu
#SBATCH --output=test_osu.out
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:05:00

# Load the module to make the osu tests available
module load brics/osu-micro-benchmarks

# Run the osu test across the allocations
srun osu_bw
