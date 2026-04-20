#!/bin/bash
#SBATCH --job-name=mc_pi_pre_gnu
#SBATCH --output=mc_pi_pre_gnu_%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:01:00

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

mkdir -p results
python -m section_05_python_array_jobs_parallelism_strategies.ex04_gnu_parallel.generate_tasks > tasks.txt
echo "Generated $(wc -l < tasks.txt) tasks in tasks.txt"
