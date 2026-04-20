#!/bin/bash
#SBATCH --job-name=mc_pi_post_gnu
#SBATCH --output=mc_pi_post_gnu_%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:02:00

# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

reduce-mc-pi-results results/mc_pi_gnu_*.txt
