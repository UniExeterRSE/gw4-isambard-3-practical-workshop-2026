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

OMP_NUM_THREADS=144 command time -v mpirun -n 1 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=72 command time -v mpirun -n 2 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=48 command time -v mpirun -n 3 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=36 command time -v mpirun -n 4 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=24 command time -v mpirun -n 6 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=18 command time -v mpirun -n 8 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=16 command time -v mpirun -n 9 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=12 command time -v mpirun -n 12 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=9 command time -v mpirun -n 16 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=8 command time -v mpirun -n 18 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=6 command time -v mpirun -n 24 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=4 command time -v mpirun -n 36 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=3 command time -v mpirun -n 48 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=2 command time -v mpirun -n 72 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
OMP_NUM_THREADS=1 command time -v mpirun -n 144 monte_carlo_pi_mpi_hybrid -d 2 -n ${N}
