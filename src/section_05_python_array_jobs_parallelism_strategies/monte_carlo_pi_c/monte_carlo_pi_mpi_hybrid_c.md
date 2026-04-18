# C MPI+OpenMP Monte Carlo Pi (stretch)

A C implementation of the same Monte Carlo Pi estimation shown in the Python examples, using MPI to distribute samples
across ranks and OpenMP to parallelise within each rank. The point is to see the same hybrid parallelism pattern in a
compiled language, and to compare the numbers with the Python/Numba variant.

We are **not** dissecting every line of the C code here. The focus is the same round trip as the matmul exercise — load
the programming environment, build with `make`, submit under Slurm, read output — applied to an MPI+OpenMP job.

## Files

- `monte_carlo_pi_mpi_hybrid.c` — the C source. Key design decisions:

  - **SoA memory layout**: coordinates stored as `coords[dim][chunk_size]` so the per-dimension accumulation is a
    stride-1 loop that auto-vectorises on SVE2.
  - **xoshiro256+ RNG**: seeded per rank via splitmix64; each OpenMP thread jumps 2^128 steps ahead for independent
    streams.
  - **d-sphere generalisation**: accepts a `-d` flag so you can test in dimensions other than 2 (the default).

- `makefile` — builds the binary with Cray’s `mpicc` wrapper. LibSci and MPICH are linked automatically under
  `PrgEnv-gnu`; `-lm` covers `pow` / `tgamma`.

- `make.sh` — loads `PrgEnv-gnu` and runs `make all`. Run this on a login node first.

- `sbatch_monte_carlo_pi_mpi_hybrid_c.sh` — Slurm job script: sweeps fifteen MPI-rank × OMP-thread combinations that all
  multiply to 144 (the full Grace CPU core count), using `command time -v` for timing.

## Build and submit

``` bash
bash make.sh
sbatch sbatch_monte_carlo_pi_mpi_hybrid_c.sh
```

Build on the login node with `make.sh`, then submit the job with `sbatch`.

## Read the output

``` bash
cat mc_pi.out
```

Each run prints a one-line result table followed by `time -v` accounting. Look for the `time[s]` column:

    d=2 N=200000000 num_threads=144 seed=20260421 mpi_ranks=1
    variant               hits      p_hat     p_true    sigma_p     pi_hat   sigma_pi   thr ranks    time[s]
    -----------------------------------------------------------------------------------------...
    c-mpi-omp     157082816   0.785414   0.785398   0.000013   3.141657   0.000052   144     1     0.1234

The wall time should be roughly the same across all fifteen configurations — the total work is fixed at 200 million
samples and 144 hardware threads are always busy. If one configuration is noticeably slower, that hints at MPI
communication overhead or NUMA effects from thread binding.

Compare the `time[s]` here against the Python/Numba hybrid result from `02-monte-carlo-pi-parallel-strategies.md` for
the same sample count: the C binary is typically 3–5× faster because there is no interpreter and the inner loop
vectorises cleanly with SVE2.
