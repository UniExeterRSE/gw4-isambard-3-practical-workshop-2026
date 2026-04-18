#!/bin/bash

#SBATCH --job-name=hello_world
#SBATCH --output=hello_world.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00

# above are special comments called "sbatch directives" that tell Slurm how to run the job
# it is equivalent to passing these options to the sbatch command, e.g.
# `sbatch --job-name=hello_world --output=hello_world.out ... sbatch_hello_world.sh`

echo "=== who and where ==="
echo "Job ID:               ${SLURM_JOB_ID}"
echo "Host:                 ${HOSTNAME}"
echo "User:                 ${USER}"
echo "PWD:                  ${PWD}"
echo "NPROC:                $(nproc)"
echo "SLURM_CPUS_ON_NODE:   ${SLURM_CPUS_ON_NODE}"
date

echo "=== memory (free -h) ==="
free -h

echo "=== CPU (lscpu) ==="
lscpu

# echo "=== Slurm environment ==="
env | sort > hello_world_${HOSTNAME}.env
