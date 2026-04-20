## Python Example + Array Jobs + Parallelism Strategies {#section-05 .hero-slide}

::::::::: hero-grid
::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Python Example + Array Jobs + Parallelism Strategies
:::

::: hero-subtitle
From a single job to hybrid MPI ---\
and what to do when the work is embarrassingly parallel
:::

::: next-steps-card
[Resources]{.card-title}

- [Slurm arrays](https://docs.isambard.ac.uk/user-documentation/guides/slurm/#job-arrays)
- [GNU parallel manual](https://www.gnu.org/software/parallel/man.html)
- Helpers are in the room --- raise a hand
:::

::: presenter-line
Section 5 --- 25 min
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
:::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::::::

::: notes
- 25-minute active section following the ex numbering: ex01 single job, ex01 MPI hybrid, ex02 C MPI, ex03 job arrays,
  ex04 GNU parallel
- Biggest risk: spending too long on MPI details; keep it high-level and move on --- MPI internals are out of scope
:::

## The example: Monte Carlo π {#monte-carlo-pi .shell-slide}

::: slide-subtitle
A parallelisable computation we can use to compare strategies
:::

:::: shell-grid
::: shell-text
Draw random points in a square. Count how many fall inside the quarter-circle.

$$\hat{\pi} = 4 \times \frac{\text{hits}}{N}$$

Why this example?

- Trivially parallelisable: each sample is independent
- Same code runs in pure Python, NumPy, Numba, MPI+Numba, and C+OpenMP
- Results are checkable --- we know the answer

The scripts are in `ex01_monte_carlo_pi/`. We use this one problem to illustrate every strategy in the section.
:::
::::

::: notes
- Spend 30 seconds max here; attendees do not need to understand the maths
- The point is: it is a stand-in for any computation you would parallelise
:::

## Single job {#single-job .shell-slide}

::: slide-subtitle
ex01 --- run all Python variants side by side
:::

:::: shell-grid
::: shell-text
From `ex01_monte_carlo_pi/`:

``` bash
sbatch sbatch_monte_carlo_pi_single.sh
squeue --me
cat mc_pi_single_<jobid>.out
```

The script runs `monte-carlo-pi-summary`: pure Python → NumPy → Numba → Numba-parallel, one table.

**Look for:** the `time[s]` column. Same total samples, different implementations. How much faster is Numba than pure
Python? Does `--cpus-per-task=4` help Numba-parallel?

**Open the script and try:** change `-n` (samples **per thread**) or `-t` (threads). Note: `-n` is per thread, so
increasing `-t` also increases total samples (weak scaling). To keep total samples fixed, scale `-n` down
proportionally.
:::
::::

::: notes
- Demo this live: sbatch, squeue, cat output
- First run includes Numba JIT compilation (\~30 s); cache=True means subsequent runs skip it
- The matmul analogy: this is the same "single-node timed job" pattern from Section 3 ex04
:::

## Hybrid MPI + Numba (single node) {#mpi-hybrid-single .shell-slide}

::: slide-subtitle
ex01 --- scale to all 144 cores on one Grace node
:::

:::: shell-grid
::: shell-text
``` bash
sbatch sbatch_monte_carlo_pi_mpi_hybrid.sh
cat mc_pi_py.out
```

The script sweeps every valid (nproc, nthreads) decomposition on 144 cores:

- **nproc=1, nthreads=144** --- one MPI rank, pure threading (shared memory only)
- **nproc=144, nthreads=1** --- 144 MPI ranks, no threading (pure MPI)
- Everything in between: hybrid

**Parallelism hierarchy:**

- Numba threads --- share memory within a rank (fast, no network)
- MPI --- explicit message passing between ranks (needed to go beyond one node)

Which decomposition is fastest? Open the output and look.
:::
::::

::: notes
- Keep this conceptual: the key message is "threads = shared memory within a node; MPI = explicit comm across nodes"
- Do NOT go into MPI API details; that is out of scope
- The sweep output shows that the answer is hardware-dependent; invite attendees to look at the cross-over point
:::

## Hybrid MPI + Numba (multi-node) {#mpi-hybrid-multinode .shell-slide}

::: slide-subtitle
ex01 --- weak scaling across 4 nodes (576 cores)
:::

:::: shell-grid
::: shell-text
``` bash
sbatch sbatch_monte_carlo_pi_mpi_hybrid_multinode.sh
cat mc_pi_py_mn.out
```

Weak scaling: resources grow 4× (144 → 576 cores), per-thread work stays constant.

**Ideal outcome:** wall-clock time stays the same as the single-node run --- you have 4× more work and 4× more hardware.

**Why MPI is needed beyond one node:** shared memory does not reach across a network interconnect. MPI is the standard
way to coordinate distributed-memory computation on an HPC cluster.

This is the **canonical HPC pattern** --- use it when your computation scales and the work justifies multi-node
resources.
:::
::::

::: notes
- This is stretch for most attendees; treat it as a live demo or point to the script
- The comment block at the top of the sbatch script explains the weak-scaling setup in detail
- Highlight: keeping -n (samples per thread) the same keeps per-thread work constant --- this is the weak-scaling design
  choice
:::

## MPI + OpenMP in C {#mpi-c .shell-slide}

::: slide-subtitle
ex02 --- the same hybrid pattern in a compiled language
:::

:::: shell-grid
::: shell-text
From `ex02_monte_carlo_pi_c/`:

``` bash
bash make.sh
sbatch sbatch_monte_carlo_pi_mpi_hybrid_c.sh        # single node
sbatch sbatch_monte_carlo_pi_mpi_hybrid_c_multinode.sh  # 4 nodes
```

The C version replaces Numba threads with OpenMP `#pragma omp parallel`. Everything else is the same:

- Same MPI reduction across ranks
- Same weak-scaling design (`-n` = samples per thread)
- Same decomposition sweep

**Compiled code is faster** (no JIT overhead, better compiler optimisations), but the programming model and parallelism
hierarchy are identical.

This is a stretch exercise --- come back to it if you finish early.
:::
::::

::: notes
- The point is that the hybrid MPI paradigm is language-agnostic; Python/Numba vs C/OpenMP is an implementation choice
- Build step: bash make.sh compiles with PrgEnv-gnu and -mcpu=neoverse-v2
- Do NOT spend time debugging compilation issues in the room; redirect to docs/support
:::

## A different problem: many independent tasks {#htc-intro .shell-slide}

::: slide-subtitle
When you have N tasks that don't need to talk to each other
:::

:::: shell-grid
::: shell-text
MPI is the right tool when tasks **communicate** during execution.

But many real workflows are different:

- Run the same analysis on 130 imaging cases
- Sweep 1000 parameter combinations
- Repeat a simulation 500 times with different seeds

Each task is **independent**. No communication needed. This is called **embarrassingly parallel**.

The pattern: **map → run → reduce**

1.  **Map** --- split work into N independent tasks
2.  **Run** --- execute all tasks (possibly in parallel)
3.  **Reduce** --- combine results into one answer

Using HPC this way is sometimes called **HTC** (High-Throughput Computing).
:::
::::

::: notes
- Mention the DCBS attendee case explicitly if it comes up: 130 multiplex imaging cases = textbook embarrassingly
  parallel problem
- The key distinction: MPI = communicating tasks; job arrays / GNU parallel = independent tasks
- We reuse the MC Pi example here only because the material is already prepared; conceptually the task is a blackbox
:::

## ex03: Slurm job array {#job-array .shell-slide}

::: slide-subtitle
One `sbatch` command, ten independent jobs
:::

:::: shell-grid
::: shell-text
From `ex03_job_array/`:

``` bash
bash run_array_pipeline.sh
```

What this does:

1.  **Pre** --- create `results/` directory
2.  **Main** --- `--array=1-10`: ten tasks, each with its own seed (`$SLURM_ARRAY_TASK_ID`)
3.  **Post** --- `reduce-mc-pi-results` combines all ten `results/mc_pi_<jobid>_<taskid>.txt` files

Monitor: `squeue --me` shows `<jobid>_1`, `<jobid>_2`, ... --- one entry per task.

**Throttling:** add `%M` to cap concurrency: `--array=1-1000%50`

Open `sbatch_monte_carlo_pi_array.sh` and change the array size or seed range.
:::
::::

::: notes
- Show the run_array_pipeline.sh source briefly: 3 sbatch lines with --parsable and --dependency=afterok
- Emphasise that --dependency=afterok on an array job ID waits for ALL tasks, not just the first
- ARRAY_JOB_ID is passed to the post job via --export so reduce-mc-pi-results can glob the right files
:::

## ex04: GNU parallel {#gnu-parallel .shell-slide}

::: slide-subtitle
All tasks on one node --- no per-task scheduler overhead
:::

:::: shell-grid
::: shell-text
From `ex04_gnu_parallel/`:

``` bash
bash run_gnu_parallel_pipeline.sh
```

What this does:

1.  **Pre** --- generate `tasks.txt` (one complete command per line, with `taskset` and `/usr/bin/time -v`)
2.  **Main** --- `parallel --jobs 10 < tasks.txt` on an exclusive node
3.  **Post** --- `reduce-mc-pi-results` combines `results/mc_pi_gnu_*.txt`

After the pre job: `cat tasks.txt` to see the commands. Each line pins its process to a disjoint core range using
`$PARALLEL_JOBSLOT` --- no oversubscription.

**Oversubscription check:** wall-clock time per task (from `/usr/bin/time -v`) should match the array job.

Open `generate_tasks.py` and tweak `N_TASKS`, `N_THREADS`, or `N_CONCURRENT`.
:::
::::

::: notes
- Show a tasks.txt line: taskset -c ... env NUMBA_NUM_THREADS=4 /usr/bin/time -v monte-carlo-pi-numba-parallel ...
- PARALLEL_JOBSLOT is the runtime slot number; the shell arithmetic in each line expands it to a core range
- 2\>&1 merges /usr/bin/time's stderr into stdout so one log captures everything
- If timings differ from the array job, ask why: NUMA effects, scheduler noise, cache pressure
:::

## ex05: mpi4py.futures {#mpi4py-futures .shell-slide}

::: slide-subtitle
Map-reduce in one Python script --- no job chaining needed
:::

:::: shell-grid
::: shell-text
From `ex05_mpi4py_futures/`:

``` bash
sbatch sbatch_mpi4py_futures.sh
cat mc_pi_futures_<jobid>.out
```

`MPIPoolExecutor` distributes tasks across MPI ranks:

- **Rank 0** --- controller: submits tasks, collects results, reduces
- **Ranks 1..N-1** --- workers: each runs one task at a time

With `--ntasks=11` you get **10 workers**. Pre, map, and reduce are all in the same Python script --- no Slurm job
chaining needed.

``` python
from mpi4py.futures import MPIPoolExecutor

with MPIPoolExecutor() as executor:
    results = list(executor.map(_worker, task_args))
```

Launch: `srun -n 11 python -m mpi4py.futures -m <module> [args]`
:::
::::

::: notes
- Key message: single script replaces the 3-script pipeline; controller = orchestrator
- With N MPI ranks: N-1 workers. Remind attendees to set --ntasks = n_workers + 1
- Unlike job arrays, tasks are not separate Slurm jobs --- less scheduler overhead, works well for short tasks
- Multi-node capable (unlike GNU parallel or multiprocessing)
- Do NOT go into MPI internals; the concurrent.futures API is the point
:::

## ex06: multiprocessing {#multiprocessing .shell-slide}

::: slide-subtitle
Single-node Pool.map --- spawn, sched_getaffinity, no nested threads
:::

:::: shell-grid
::: shell-text
From `ex06_multiprocessing/`:

``` bash
sbatch sbatch_multiprocessing.sh
cat mc_pi_mp_<jobid>.out
```

Three NERSC-recommended patterns for HPC:

``` python
import multiprocessing as mp, os

mp.set_start_method("spawn")            # safe: no fork of MPI/Numba state
n_workers = len(os.sched_getaffinity(0))  # CPUs in Slurm cgroup, not all cores
os.environ["OMP_NUM_THREADS"] = "1"    # prevent nested threading

with mp.Pool(processes=n_workers) as pool:
    results = pool.map(_worker, task_args)
```

**Why `sched_getaffinity`, not `cpu_count`?** `cpu_count()` returns all 144 cores on a Grace node;
`sched_getaffinity(0)` returns only the CPUs Slurm allocated (`--cpus-per-task`).

**Why spawn?** `fork` copies MPI communicators and Numba JIT caches --- causes hangs on HPC.
:::
::::

::: notes
- The three patterns (spawn, sched_getaffinity, OMP_NUM_THREADS=1) are the NERSC checklist; repeat them
- sched_getaffinity is Linux-only (works on Isambard 3); mention it won't work on macOS
- Single-node only: multiprocessing.Pool does not span nodes; for multi-node use mpi4py.futures
- Workers import the module fresh (spawn), so the worker function must be importable at module level
:::

## Workflow managers {#workflow-managers .shell-slide}

::: slide-subtitle
When pipelines get complex --- use a workflow manager
:::

:::: shell-grid
::: shell-text
Job arrays and GNU parallel work well for simple independent-task pipelines. For more complex workflows:

  Tool            Model                      Good for
  --------------- -------------------------- ---------------------------------------
  **Parsl**       Python-native, HPC-aware   Python workflows, dynamic graphs
  **Nextflow**    DSL, container-first       Bioinformatics, reproducibility
  **Snakemake**   Makefile-inspired          Data science, file-based dependencies
  **Dask**        Python, in-process         Array/dataframe workloads

Common features: dependency graphs, retry on failure, provenance tracking, cluster-aware submission.

These are **follow-up tools** --- start with job arrays and grow into a workflow manager when your pipeline outgrows
them.
:::
::::

::: notes
- Keep this as a pointer slide; don't go deep on any tool
- Parsl is Python-native and integrates with Slurm well; a natural next step for Python users on Isambard 3
- Nextflow and Snakemake are widely used in life sciences --- relevant given the DCBS/biosciences attendee profile
- Dask is for in-process parallelism on large arrays, not batch pipelines --- different use case
:::
