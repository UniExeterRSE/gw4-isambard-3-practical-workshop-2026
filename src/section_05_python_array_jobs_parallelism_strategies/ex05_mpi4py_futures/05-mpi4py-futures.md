# mpi4py.futures: Python Workflow Manager

`mpi4py.futures` provides a `concurrent.futures`-compatible interface for distributing work across MPI ranks. Rank 0
acts as the controller (submits tasks, collects results); ranks 1..N-1 are workers. With N MPI processes you have N-1
effective workers.

This is the “single script” pattern: pre (setup), map (dispatch tasks), and reduce (combine results) all live in one
Python file. No Slurm job chaining needed.

## Launch pattern

``` bash
mpiexec -n N python -m mpi4py.futures -m <module> [args...]
# or via srun in a batch script:
srun --ntasks=N python -m mpi4py.futures -m <module> [args...]
```

The `-m mpi4py.futures` prefix intercepts startup so that rank 0 runs the user module as controller and ranks 1..N-1
bootstrap as workers automatically.

## Run the example

``` bash
sbatch sbatch_mpi4py_futures.sh
cat mc_pi_futures_<jobid>.out
```

The script requests 11 MPI tasks (1 controller + 10 workers) and submits 20 MC tasks. Each worker runs one task at a
time; the executor queues the overflow.

## Key code pattern

``` python
from mpi4py.futures import MPIPoolExecutor

with MPIPoolExecutor() as executor:
    results = list(executor.map(_worker, task_args))
```

`MPIPoolExecutor()` without arguments uses all available worker ranks. The controller blocks on `map()` until all
futures complete, then reduces the results in the same process.

## Worker count

``` python
from mpi4py import MPI
n_workers = MPI.COMM_WORLD.Get_size() - 1
```

Always N-1 (rank 0 is reserved as controller). Size your `--ntasks` accordingly: `--ntasks = n_workers + 1`.

## Comparison with job arrays and GNU parallel

|                       | Job array             | GNU parallel         | mpi4py.futures    |
|-----------------------|-----------------------|----------------------|-------------------|
| Scheduler involvement | One job per task      | One job total        | One job total     |
| Multi-node            | Yes                   | No                   | Yes               |
| Language              | Any                   | Any                  | Python only       |
| Pre/run/reduce in one | No (3 scripts)        | No (3 scripts)       | Yes (one script)  |
| Overhead per task     | Scheduler overhead    | Process spawn        | MPI message (low) |
| Good for              | Large N, any language | Large N, single node | Python map-reduce |
