# Python multiprocessing (Single Node)

Python’s `multiprocessing` module distributes work across processes on one node using `Pool.map`. Following NERSC
guidance for HPC use:

- **spawn** start method: avoids inheriting MPI/Numba/GPU state from the parent process.
- **`os.sched_getaffinity(0)`**: reads the CPUs in the Slurm cgroup — correct worker count without hardcoding.
- **Per-worker CPU slots**: split the Slurm affinity mask into disjoint 4-core chunks so each worker can run a 4-thread
  Numba task without overlap.

## Run the example

``` bash
sbatch sbatch_multiprocessing.sh
cat mc_pi_mp_<jobid>.out
```

The script allocates a full Grace node (`--cpus-per-task=144`), then starts `36` worker processes with `4` threads each.
Every worker gets its own 4-core affinity slot, matching the job-array and GNU parallel task shape.

## Key code pattern

``` python
import multiprocessing as mp
import os

ctx = mp.get_context("spawn")                   # safe default for HPC
available = sorted(os.sched_getaffinity(0))     # CPUs granted by Slurm
n_workers = len(available) // 4                 # 36 workers on a 144-core node

with ctx.Pool(processes=n_workers, initializer=_init_worker, ...) as pool:
    results = pool.map(_worker, task_args)
```

## Why spawn, not fork?

`fork` copies the parent’s full address space including open MPI communicators, Numba JIT caches, and CUDA contexts. On
HPC systems this causes hangs or corruption. `spawn` starts each worker fresh, importing only what it needs.

## Why sched_getaffinity, not cpu_count?

`os.cpu_count()` returns the total number of cores on the machine (e.g. 144 on a Grace node). `os.sched_getaffinity(0)`
returns only the CPUs your job was allocated. We then divide that mask into `4`-core slots so the worker count matches
the chosen threads-per-task.

## Comparison with other strategies

|                  | multiprocessing    | mpi4py.futures    | GNU parallel         |
|------------------|--------------------|-------------------|----------------------|
| Multi-node       | No                 | Yes               | No                   |
| Start method     | spawn (safe)       | MPI bootstrap     | OS fork of shell     |
| Worker discovery | sched_getaffinity  | MPI rank count    | –jobs N (manual)     |
| Language         | Python only        | Python only       | Any                  |
| CPU binding      | Per-worker slots   | Slurm handles     | taskset              |
| Good for         | Single-node Python | Multi-node Python | Any language, 1 node |
