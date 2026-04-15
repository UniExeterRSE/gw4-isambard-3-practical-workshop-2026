# Section 5: Python Example + Array Jobs + Parallelism Strategies

**Section type: Active.** The section has three parts (A, B, C), each following the Present → Demo → Hands-on →
Discussion rhythm. Part C (parallelism strategies comparison) is more conceptual and may be lighter on hands-on time.

This section covers a prepared Monte Carlo Pi example, ways to run repeated simulations, and a stretch path into MPI
execution.

Files in this section:

- `02-monte-carlo-pi-parallel-strategies.md` - walkthrough for the split Monte Carlo Pi examples
- `monte_carlo_pi_pure_python.py` - pure Python baseline
- `monte_carlo_pi_numpy.py` - NumPy vectorised variant
- `monte_carlo_pi_numba.py` - Numba JIT variant
- `monte_carlo_pi_numba_parallel.py` - Numba `parallel=True` and `prange` variant
- `monte_carlo_pi_mpi_hybrid.py` - hybrid MPI + threaded Numba variant
- `monte_carlo_pi_parallel_strategies.py` - summary runner importing the non-MPI variants, with the hybrid result
  appended when launched under `mpiexec`
- `monte_carlo_pi_common.py` - shared maths, CLI parsing, and result formatting
- `__init__.py` - makes the section importable as `section_05_python_array_jobs_parallelism_strategies`
- `../../pyproject.toml` - root Python package metadata plus Pixi workspace configuration
- `hybrid-MPI.md` - thread-related environment variables for hybrid runs
- `01-mpi-parallelism-stretch.md` - an optional stretch module demonstrating multi-node MPI parallelism using
  `osu-micro-benchmarks`.
- `mpi_osu.sh` - a basic batch script for the multi-node job.
