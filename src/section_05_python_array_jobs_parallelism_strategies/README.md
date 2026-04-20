# Section 5: Python Example + Array Jobs + Parallelism Strategies

**Section type: Active.** Follows the ex numbering: single job → hybrid MPI (Python) → hybrid MPI (C) → job arrays → GNU
parallel.

## Exercises

- **ex01** `ex01_monte_carlo_pi/` → `01-monte-carlo-pi.md` — Python Monte Carlo Pi: pure Python, NumPy, Numba,
  Numba-parallel, and hybrid MPI + Numba variants; single-node and multi-node sbatch scripts
- **ex02** `ex02_monte_carlo_pi_c/` → `02-monte-carlo-pi-c.md` — C MPI+OpenMP stretch: same hybrid pattern in a compiled
  language; build with `bash make.sh`
- **ex03** `ex03_job_array/` → `03-job-array.md` — Slurm job array: embarrassingly parallel map-reduce pipeline with job
  chaining
- **ex04** `ex04_gnu_parallel/` → `04-gnu-parallel.md` — GNU parallel: single-node many-task pipeline with CPU binding
  and `/usr/bin/time -v` diagnostics
- **ex05** `ex05_mpi4py_futures/` → `05-mpi4py-futures.md` — mpi4py.futures: Python map-reduce in one script via
  `MPIPoolExecutor`; rank 0 = controller, ranks 1..N-1 = workers; multi-node capable
- **ex06** `ex06_multiprocessing/` → `06-multiprocessing.md` — Python multiprocessing: single-node Pool.map with spawn,
  `os.sched_getaffinity`, and `OMP_NUM_THREADS=1` following NERSC guidance

## Slide deck

`parallel_strategies.markdown` — reveal.js slide deck for the whole section; covers the problem, single job, hybrid MPI
(Python and C), HTC introduction, job arrays, GNU parallel, and a workflow-manager pointer slide.

## Files

### ex01 — Monte Carlo Pi (Python)

- `ex01_monte_carlo_pi/monte_carlo_pi_common.py` — shared maths, CLI, `save_raw_result`
- `ex01_monte_carlo_pi/monte_carlo_pi_pure_python.py` — pure Python baseline
- `ex01_monte_carlo_pi/monte_carlo_pi_numpy.py` — NumPy variant
- `ex01_monte_carlo_pi/monte_carlo_pi_numba.py` — Numba JIT variant
- `ex01_monte_carlo_pi/monte_carlo_pi_numba_parallel.py` — Numba `parallel=True`; supports `--save FILE`
- `ex01_monte_carlo_pi/monte_carlo_pi_mpi_hybrid.py` — hybrid MPI + Numba; `-n` = samples per thread
- `ex01_monte_carlo_pi/monte_carlo_pi_parallel_strategies.py` — summary runner for all variants
- `ex01_monte_carlo_pi/sbatch_monte_carlo_pi_single.sh` — single job, all variants
- `ex01_monte_carlo_pi/sbatch_monte_carlo_pi_mpi_hybrid.sh` — hybrid decomposition sweep, single node
- `ex01_monte_carlo_pi/sbatch_monte_carlo_pi_mpi_hybrid_multinode.sh` — weak scaling, 4 nodes

### ex02 — Monte Carlo Pi (C)

- `ex02_monte_carlo_pi_c/monte_carlo_pi_mpi_hybrid.c` — C source
- `ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c.sh` — single node
- `ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c_multinode.sh` — 4 nodes

### ex03 — Slurm job array

- `ex03_job_array/03-job-array.md` — walkthrough
- `ex03_job_array/reduce_results.py` — reduce step (entry point: `reduce-mc-pi-results`)
- `ex03_job_array/sbatch_pre_array.sh` — pre: create `results/`
- `ex03_job_array/sbatch_monte_carlo_pi_array.sh` — main: `--array=1-36%36`, 4 threads/task
- `ex03_job_array/sbatch_post_array.sh` — post: reduce
- `ex03_job_array/run_array_pipeline.sh` — pipeline runner (login node)

### ex04 — GNU parallel

- `ex04_gnu_parallel/04-gnu-parallel.md` — walkthrough
- `ex04_gnu_parallel/generate_tasks.py` — generates `tasks.txt` with CPU binding and `/usr/bin/time -v`
- `ex04_gnu_parallel/sbatch_pre_gnu_parallel.sh` — pre: generate `tasks.txt`
- `ex04_gnu_parallel/sbatch_gnu_parallel.sh` — main: `parallel --jobs N < tasks.txt` (exclusive node)
- `ex04_gnu_parallel/sbatch_post_gnu_parallel.sh` — post: reduce
- `ex04_gnu_parallel/run_gnu_parallel_pipeline.sh` — pipeline runner (login node)

### ex05 — mpi4py.futures

- `ex05_mpi4py_futures/05-mpi4py-futures.md` — walkthrough
- `ex05_mpi4py_futures/monte_carlo_pi_mpi4py_futures.py` — single script: controller dispatches tasks via
  `MPIPoolExecutor`, reduces results inline; launched with `python -m mpi4py.futures -m <module>`
- `ex05_mpi4py_futures/sbatch_mpi4py_futures.sh` — `--ntasks=36`, `--cpus-per-task=4`; 35 workers + 1 controller on one
  node

### ex06 — Python multiprocessing

- `ex06_multiprocessing/06-multiprocessing.md` — walkthrough
- `ex06_multiprocessing/monte_carlo_pi_multiprocessing.py` — `mp.set_start_method("spawn")`, `os.sched_getaffinity(0)`,
  `OMP_NUM_THREADS=1`, `Pool.map`
- `ex06_multiprocessing/sbatch_multiprocessing.sh` — `--cpus-per-task=144`; 36 worker processes with 4 threads each
