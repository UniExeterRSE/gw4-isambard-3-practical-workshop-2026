#!/bin/bash
#SBATCH --job-name=sysinfo
#SBATCH --output=sysinfo.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:02:00

echo "=== date ==="
date

echo "=== hostname ==="
hostname

echo "=== whoami ==="
whoami

echo "=== working directory ==="
pwd

echo "=== env (Slurm variables only) ==="
env | grep '^SLURM_' | sort

echo "=== free -h ==="
free -h

echo "=== lscpu ==="
lscpu

echo "=== uname -a ==="
uname -a
