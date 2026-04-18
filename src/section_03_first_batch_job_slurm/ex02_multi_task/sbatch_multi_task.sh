#!/bin/bash
#SBATCH --job-name=multi_task
#SBATCH --output=multi_task.out
#SBATCH --ntasks=4
#SBATCH --time=00:01:00

srun bash -c 'echo "Task ${SLURM_PROCID} running on $(hostname)"'
