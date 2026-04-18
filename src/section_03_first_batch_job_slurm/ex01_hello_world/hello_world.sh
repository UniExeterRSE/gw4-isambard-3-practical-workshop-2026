#!/bin/bash
#SBATCH --job-name=hello-world
#SBATCH --output=hello_world.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:02:00

echo "=== who and where ==="
echo "Job ID: ${SLURM_JOB_ID}"
echo "Host:   $(hostname)"
echo "User:   $(whoami)"
echo "PWD:    $(pwd)"
date

echo "=== memory (free -h) ==="
free -h

echo "=== CPU (lscpu) ==="
lscpu

echo "=== Slurm environment ==="
env | grep '^SLURM_' | sort
