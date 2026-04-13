# Section 6: Python Example + Array Jobs + Parallelism Strategies

This section covers a prepared Monte Carlo Pi example, ways to run repeated simulations, and a stretch path into MPI execution.

Files in this section:

- `02-monte-carlo-pi-parallel-strategies.md` - walkthrough for the split Monte Carlo Pi examples
- `monte_carlo_pi_pure_python.py` - pure Python baseline
- `monte_carlo_pi_numpy.py` - NumPy vectorised variant
- `monte_carlo_pi_numba.py` - Numba JIT variant
- `monte_carlo_pi_numba_parallel.py` - Numba `parallel=True` and `prange` variant
- `monte_carlo_pi_mpi_hybrid.py` - hybrid MPI + threaded Numba variant
- `monte_carlo_pi_parallel_strategies.py` - summary runner importing the non-MPI variants, with the hybrid result appended when launched under `mpiexec`
- `monte_carlo_pi_common.py` - shared maths, CLI parsing, and result formatting
- `pixi.toml` - local Python environment for `numpy`, `numba`, `mpi4py`, and `jupytext`
- `hybrid-MPI.md` - thread-related environment variables for hybrid runs
- `01-mpi-parallelism-stretch.md` - an optional stretch module demonstrating multi-node MPI parallelism using `osu-micro-benchmarks`.
- `mpi_osu.slurm` - a basic batch script for the multi-node job.
