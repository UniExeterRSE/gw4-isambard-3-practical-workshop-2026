# Python multiprocessing (Single Node)

Python’s `multiprocessing` module distributes work across processes on one node using `Pool.map`. Following NERSC
guidance for HPC use:

- **spawn** start method: avoids inheriting MPI/Numba/GPU state from the parent process.
- **`os.sched_getaffinity(0)`**: reads the CPUs in the Slurm cgroup — correct worker count without hardcoding.
- **`OMP_NUM_THREADS=1` / `NUMBA_NUM_THREADS=1`**: prevents nested threading when each worker process IS the unit of
  parallelism.

## Run the example

``` bash
sbatch sbatch_multiprocessing.sh
cat mc_pi_mp_<jobid>.out
```

The script allocates `--cpus-per-task=10`. The Python script reads `os.sched_getaffinity(0)` to discover those 10 CPUs
and spawns 10 workers.

## Key code pattern

``` python
import multiprocessing as mp
import os

mp.set_start_method("spawn")                    # safe default for HPC
n_workers = len(os.sched_getaffinity(0))        # CPUs granted by Slurm

os.environ["OMP_NUM_THREADS"] = "1"             # no nested threading
os.environ["NUMBA_NUM_THREADS"] = "1"

with mp.Pool(processes=n_workers) as pool:
    results = pool.map(_worker, task_args)
```

## Why spawn, not fork?

`fork` copies the parent’s full address space including open MPI communicators, Numba JIT caches, and CUDA contexts. On
HPC systems this causes hangs or corruption. `spawn` starts each worker fresh, importing only what it needs.

## Why sched_getaffinity, not cpu_count?

`os.cpu_count()` returns the total number of cores on the machine (e.g. 144 on a Grace node). `os.sched_getaffinity(0)`
returns only the CPUs your job was allocated. Using `cpu_count()` would spawn 144 workers and oversubscribe the node.

## Comparison with other strategies

|                  | multiprocessing    | mpi4py.futures    | GNU parallel         |
|------------------|--------------------|-------------------|----------------------|
| Multi-node       | No                 | Yes               | No                   |
| Start method     | spawn (safe)       | MPI bootstrap     | OS fork of shell     |
| Worker discovery | sched_getaffinity  | MPI rank count    | –jobs N (manual)     |
| Language         | Python only        | Python only       | Any                  |
| CPU binding      | No (OS scheduler)  | Slurm handles     | taskset              |
| Good for         | Single-node Python | Multi-node Python | Any language, 1 node |
