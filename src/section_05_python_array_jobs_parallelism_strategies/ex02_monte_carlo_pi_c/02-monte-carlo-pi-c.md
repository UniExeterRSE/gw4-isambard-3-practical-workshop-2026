# C MPI+OpenMP Monte Carlo Pi (stretch)

A C implementation of the same Monte Carlo Pi estimation shown in the Python examples, using MPI to distribute samples
across ranks and OpenMP to parallelise within each rank. The point is to see the same hybrid parallelism pattern in a
compiled language, and to compare the numbers with the Python/Numba variant.

We are **not** dissecting every line of the C code here. The focus is the same round trip as the matmul exercise — load
the programming environment, build with `make`, submit under Slurm, read output — applied to an MPI+OpenMP job.

## Files

- `monte_carlo_pi_mpi_hybrid.c` — the C source. Key design decisions:

  - **Fused kernel**: each sample lives in registers; no intermediate buffer, no memory traffic beyond the 256-bit RNG
    state and a scalar `rsq`.
  - **Per-thread work CLI**: `-n` is samples *per OpenMP thread*. Total samples = MPI ranks × OMP threads × `-n`. The
    thread count is read from `OMP_NUM_THREADS` via `omp_get_max_threads()`, so the driver does not need to repeat it.
  - **d-sphere generalisation**: accepts a `-d` flag so you can test in dimensions other than 2 (the default).

- `rng.h`, `rng.c` — xoshiro256+ PRNG in its own translation unit, so the main file is not cluttered with bit mixing.
  `rng.h` exposes only `Rng`, `rng_init(rng, seed, stream)`, and `rng_uniform` (the hot-loop entry point is a
  `static inline`). Each (rank, thread) pair calls `rng_init` with a unique `stream` index, which advances the generator
  by `stream × 2^128` steps — guaranteeing non-overlapping streams.

- `makefile` — builds the binary with Cray’s `mpicc` wrapper. LibSci and MPICH are linked automatically under
  `PrgEnv-gnu`; `-lm` covers `pow` / `tgamma`. `rng.c` is compiled as a separate object and linked in.

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
cat mc_pi_<jobid>.out
```

Each run prints a one-line result table followed by `time -v` accounting. Look for the `time[s]` column:

    d=2 N=288000000 num_threads=144 seed=20260421 mpi_ranks=1
    variant               hits      p_hat     p_true    sigma_p     pi_hat   sigma_pi   thr ranks    time[s]
    -----------------------------------------------------------------------------------------...
    c-mpi-omp     226194852   0.785400   0.785398   0.000011   3.141601   0.000043   144     1     0.0123

The wall time should be roughly the same across all fifteen configurations — per-thread work is fixed at 2 million
samples (288 million in total, since ranks × threads = 144 across the sweep) and every Grace core is busy. If one
configuration is noticeably slower, that hints at MPI startup overhead (many small ranks) or NUMA effects from thread
binding.

Compare the `time[s]` here against the Python/Numba hybrid result from `../ex01_monte_carlo_pi/01-monte-carlo-pi.md` for
a similar sample count. Both use the same CLI convention: `-n` is samples per thread, so
`total = MPI ranks × OMP/Numba threads × n`. The C binary is typically 3–5× faster because there is no interpreter and
the fused inner loop keeps every sample in a register — the entire hot path is one xoshiro state update followed by a
couple of FMAs.
