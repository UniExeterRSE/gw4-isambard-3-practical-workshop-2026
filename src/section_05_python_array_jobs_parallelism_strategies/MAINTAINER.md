# Section 5: Maintainer Notes

This document records the steps needed to verify that Section 5 is working correctly on GW4 Isambard 3 (Grace CPU
partition). All commands assume you are working inside the section directory unless otherwise noted.

``` sh
cd src/section_05_python_array_jobs_parallelism_strategies
```

## TL;DR — submit all jobs at once

Run from `src/section_05_python_array_jobs_parallelism_strategies/`:

``` sh
# ex01 — single job variants
(cd ex01_monte_carlo_pi && sbatch sbatch_monte_carlo_pi_single.sh)
(cd ex01_monte_carlo_pi && sbatch sbatch_monte_carlo_pi_mpi_hybrid.sh)

# ex02 — C MPI hybrid (build first)
(cd ex02_monte_carlo_pi_c && bash make.sh && sbatch sbatch_monte_carlo_pi_mpi_hybrid_c.sh)

# ex03 — job array pipeline (pre → array → post)
(cd ex03_job_array && bash run_array_pipeline.sh)

# ex04 — GNU parallel pipeline (pre → parallel → post)
(cd ex04_gnu_parallel && bash run_gnu_parallel_pipeline.sh)

# ex05 — mpi4py.futures
(cd ex05_mpi4py_futures && sbatch sbatch_mpi4py_futures.sh)

# ex06 — Python multiprocessing
(cd ex06_multiprocessing && sbatch sbatch_multiprocessing.sh)
```

Then monitor with `squeue --me` and check outputs as described in each section below.

## Prerequisites

The Pixi `hpc` environment must be installed and the `hpc` feature must resolve. The `default` environment works for
local testing (no MPI required).

``` sh
pixi install --environment hpc
pixi run format                 # must be idempotent — CI enforces this
pixi run docs                   # slide HTML must build cleanly
```

## ex01 — Monte Carlo Pi (Python, single job)

Run all Python variants in one job (pure Python, NumPy, Numba, Numba-parallel, MPI-hybrid):

``` sh
# Quick local smoke test (no Slurm needed):
pixi run monte-carlo-pi-summary -d 2 -n 100000 -t 4

# On a compute node:
cd ex01_monte_carlo_pi
sbatch sbatch_monte_carlo_pi_single.sh
```

Check `mc_pi_single_<JOBID>.out`: all variants should print a results table with `pi_hat` close to 3.14159. Elapsed
times should rank pure-python \>\> numpy \> numba ≈ numba-parallel.

MPI hybrid (Python, single node):

``` sh
sbatch sbatch_monte_carlo_pi_mpi_hybrid.sh
```

Check `mc_pi_py.out`: each `srun` block runs a different (ranks × threads) decomposition. All `pi_hat` values should
agree to ~5 significant figures.

## ex02 — Monte Carlo Pi (C, stretch)

Build first, then submit:

``` sh
cd ex02_monte_carlo_pi_c
bash make.sh                    # compiles monte_carlo_pi_mpi_hybrid
sbatch sbatch_monte_carlo_pi_mpi_hybrid_c.sh
```

Check the output file: the C binary should report the same `pi_hat` as the Python MPI-hybrid variant (same algorithm,
same default seed). Elapsed time should be significantly shorter.

## ex03 — Slurm job array pipeline

Submit pre → array → post chain from the login node:

``` sh
cd ex03_job_array
bash run_array_pipeline.sh
```

This runs:

``` sh
sbatch sbatch_pre_array.sh
sbatch --dependency=afterok:<PRE_ID> sbatch_monte_carlo_pi_array.sh
sbatch --dependency=afterok:<ARRAY_ID> sbatch_post_array.sh
```

Monitor progress:

``` sh
squeue --me
```

**Checking output:**

- `mc_pi_pre_array_<JOBID>.out` — should print `Results directory ready.`

- `mc_pi_array_<ARRAY_JOB_ID>_<TASK_ID>.out` (36 files, one per task) — each should contain a results table with
  `pi_hat` ≈ 3.14. The current configuration runs 36 array tasks with 4 threads each and `2^29` samples per thread, so
  expect 36 output files and runtimes that are long enough to measure rather than a few milliseconds.

- `mc_pi_post_array_<JOBID>.out` — the reducer prints per-task hits and a combined estimate. The reduced `pi_hat` should
  be more accurate than any individual task (law of large numbers). Example expected output:

      Per-task results:
        results/mc_pi_<ID>_1.txt: hits=…  n=…  pi_hat=3.14…
        …
      Reduced total: hits=…  n=…
        pi_hat = 3.14159…  (true pi = 3.14159265)
        error  = <1e-3

## ex04 — GNU parallel pipeline

``` sh
cd ex04_gnu_parallel
bash run_gnu_parallel_pipeline.sh
```

This runs:

``` sh
sbatch sbatch_pre_gnu_parallel.sh
sbatch --dependency=afterok:<PRE_ID> sbatch_gnu_parallel.sh
sbatch --dependency=afterok:<MAIN_ID> sbatch_post_gnu_parallel.sh
```

**Checking output:**

- `mc_pi_pre_gnu_<JOBID>.out` — should report `Generated 36 tasks in tasks.txt`, then print both the first task template
  and a concrete `Slot 1 preview:` line (`taskset -c 0-3 …`) for sanity-checking CPU binding.
- `mc_pi_gnu_<JOBID>.out` — GNU parallel interleaves output from all 36 tasks. Look for 36 separate `/usr/bin/time -v`
  blocks; each should contain `Elapsed (wall clock) time` and the pi estimate line. No task should time out or print a
  traceback.
- `mc_pi_post_gnu_<JOBID>.out` — same format as ex03 post; combined `pi_hat` should match ex03 closely (same 36 seeds,
  same sample count per task).

Wall-clock time for the GNU parallel job should be comparable to the array job (both run 36 tasks simultaneously with 4
threads each).

## ex05 — mpi4py.futures

``` sh
cd ex05_mpi4py_futures
sbatch sbatch_mpi4py_futures.sh
```

**Checking output (`mc_pi_futures_<JOBID>.out`):**

    === mpi4py.futures MPIPoolExecutor: 35 workers, 36 tasks, 4 threads/task ===
    Controller: 35 workers, 36 tasks, 536,870,912 samples/thread, 4 threads/task
    total_n=77,309,411,328  hits=…
    pi_estimate=3.14159…  error=<1e-3  time=…s

Because rank 0 is the controller, 35 workers execute the 36 tasks. Wall-clock time should therefore be only slightly
longer than the per-task time, not 36×.

## ex06 — Python multiprocessing

``` sh
cd ex06_multiprocessing
sbatch sbatch_multiprocessing.sh
```

**Checking output (`mc_pi_mp_<JOBID>.out`):**

    === multiprocessing: 36 workers, 36 tasks, 4 threads/worker ===
    Workers: 36  Tasks: 36  Samples/thread: 536,870,912  Threads/worker: 4
    total_n=77,309,411,328  hits=…
    pi_estimate=3.14159…  error=<1e-3  time=…s

Verify that `Workers: 36` appears (confirming `os.sched_getaffinity` read the 144-core allocation and split it into 36
disjoint 4-core worker slots correctly). If it prints a different count, the affinity mask is not being interpreted as
expected.

## Common failure modes

| Symptom | Likely cause |
|----|----|
| `pixi shell-hook: environment hpc not found` | Run `pixi install --environment hpc` first |
| Array post job starts before array tasks finish | Check `--dependency=afterok:<ARRAY_JOB_ID>` syntax — the full array ID (no `:`) is required |
| `reduce-mc-pi-results: command not found` | Package not installed in hpc env; run `pixi install --environment hpc` |
| mpi4py import error in workers | `LD_LIBRARY_PATH` not set; check `sbatch_mpi4py_futures.sh` `MPICH_DIR` block |
| `RuntimeError: … at least 2 MPI processes` | `--ntasks=36` not reaching srun; check PrgEnv-gnu is loaded |
| `sched_getaffinity` returns 1 worker | Job was not submitted via sbatch; `--cpus-per-task` not inherited |
