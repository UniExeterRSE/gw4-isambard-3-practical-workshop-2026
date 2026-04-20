#!/bin/bash
#SBATCH --job-name=mc_pi_gnu
#SBATCH --output=mc_pi_gnu_%j.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:05:00

# N_CONCURRENT * N_THREADS should equal the node's total core count for a full-node
# run with no oversubscription. N_THREADS must match the value in generate_tasks.py.
# Grace CPU node: 144 cores -> N_CONCURRENT=36, N_THREADS=4 fills the node exactly.
# For the 10-task workshop example both can be 10 (40 cores used out of 144).
N_CONCURRENT=10
N_THREADS=4

module reset

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

# tasks.txt was created by the pre job (sbatch_pre_gnu_parallel.sh)
parallel --jobs "${N_CONCURRENT}" < tasks.txt
