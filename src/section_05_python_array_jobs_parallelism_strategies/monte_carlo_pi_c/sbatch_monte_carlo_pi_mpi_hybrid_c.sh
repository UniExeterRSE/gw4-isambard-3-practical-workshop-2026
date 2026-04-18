#!/bin/bash
#SBATCH --job-name=mc_pi
#SBATCH --output=mc_pi.out
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:02:00

N=200000000
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export OMP_DYNAMIC=FALSE

module reset
module load PrgEnv-gnu

echo '=== N_PROC=1, N_THREADS=144 ==='
OMP_NUM_THREADS=144 command time -v mpirun -n 1 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=2, N_THREADS=72 ==='
OMP_NUM_THREADS=72 command time -v mpirun -n 2 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=3, N_THREADS=48 ==='
OMP_NUM_THREADS=48 command time -v mpirun -n 3 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=4, N_THREADS=36 ==='
OMP_NUM_THREADS=36 command time -v mpirun -n 4 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=6, N_THREADS=24 ==='
OMP_NUM_THREADS=24 command time -v mpirun -n 6 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=8, N_THREADS=18 ==='
OMP_NUM_THREADS=18 command time -v mpirun -n 8 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=9, N_THREADS=16 ==='
OMP_NUM_THREADS=16 command time -v mpirun -n 9 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=12, N_THREADS=12 ==='
OMP_NUM_THREADS=12 command time -v mpirun -n 12 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=16, N_THREADS=9 ==='
OMP_NUM_THREADS=9 command time -v mpirun -n 16 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=18, N_THREADS=8 ==='
OMP_NUM_THREADS=8 command time -v mpirun -n 18 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=24, N_THREADS=6 ==='
OMP_NUM_THREADS=6 command time -v mpirun -n 24 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=36, N_THREADS=4 ==='
OMP_NUM_THREADS=4 command time -v mpirun -n 36 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=48, N_THREADS=3 ==='
OMP_NUM_THREADS=3 command time -v mpirun -n 48 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=72, N_THREADS=2 ==='
OMP_NUM_THREADS=2 command time -v mpirun -n 72 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
echo '=== N_PROC=144, N_THREADS=1 ==='
OMP_NUM_THREADS=1 command time -v mpirun -n 144 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
