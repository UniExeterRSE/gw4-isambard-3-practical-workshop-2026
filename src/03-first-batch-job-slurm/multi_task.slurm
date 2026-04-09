#!/bin/bash
#SBATCH --job-name=multi-task
#SBATCH --output=multi_task.out
#SBATCH --ntasks=4
#SBATCH --time=00:02:00

srun bash -c 'echo "Task $SLURM_PROCID running on $(hostname)"'
