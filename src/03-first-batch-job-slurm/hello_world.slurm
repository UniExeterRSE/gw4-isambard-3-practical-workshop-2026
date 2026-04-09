#!/bin/bash
#SBATCH --job-name=hello-world
#SBATCH --output=hello_world.out
#SBATCH --ntasks=1
#SBATCH --time=00:02:00

echo "Hello from Isambard 3"
echo "Job ID: $SLURM_JOB_ID"
echo "Host: $(hostname)"
echo "Working directory: $(pwd)"
