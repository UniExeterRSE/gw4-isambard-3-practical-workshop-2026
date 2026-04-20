# GNU Parallel (Single Node)

GNU parallel runs many tasks simultaneously on one node, filling its cores without submitting separate Slurm jobs for
each task. This is useful when tasks are short and scheduler overhead matters.

## CPU binding and oversubscription

Each command in `tasks.txt` pins itself to a disjoint set of cores via `$PARALLEL_JOBSLOT` — an environment variable GNU
parallel exports to every spawned process. With `N_CONCURRENT=36` and `N_THREADS=4` per task, slot `k` gets cores
`(k-1)*4` to `k*4-1`, so all 144 of the node’s cores are used with no overlap.

The example runs `36` tasks with `2^29` samples per thread, matching the array job’s task shape while avoiding per-task
scheduler overhead.

`/usr/bin/time -v` wraps every command so wall-clock time and peak memory appear in the log. `2>&1` merges that
diagnostic stderr into stdout so one log captures everything.

**Oversubscription check:** compare wall-clock time per task (from `/usr/bin/time -v` output) with the per-task time
from the equivalent job array run. Similar timings confirm no oversubscription.

## Pipeline

    sbatch_pre_gnu_parallel.sh  →  sbatch_gnu_parallel.sh  →  sbatch_post_gnu_parallel.sh

Run the whole pipeline:

``` bash
bash run_gnu_parallel_pipeline.sh
```

Or step by step:

``` bash
PRE=$(sbatch --parsable sbatch_pre_gnu_parallel.sh)
MAIN=$(sbatch --parsable --dependency=afterok:${PRE} sbatch_gnu_parallel.sh)
sbatch --dependency=afterok:${MAIN} sbatch_post_gnu_parallel.sh
```

## Inspect the task list

After the pre job completes, look at what will be submitted:

``` bash
cat tasks.txt
```

Each line is a complete shell command with `taskset`, `env`, `/usr/bin/time -v`, and the actual program call.

Open `generate_tasks.py` to see how the commands are constructed and tweak `--tasks`, `--threads`, or
`--samples-per-thread`.

## Reduce manually

``` bash
reduce-mc-pi-results results/mc_pi_gnu_*.txt
```

## Comparison with job arrays

|                       | Slurm job array           | GNU parallel                      |
|-----------------------|---------------------------|-----------------------------------|
| Scheduler involvement | One job per task          | One job total                     |
| Spans multiple nodes  | Yes                       | No                                |
| Good for              | Moderate N, longer tasks  | Large N, short tasks              |
| Throttling            | `--array=1-N%M`           | `--jobs M`                        |
| CPU binding           | Slurm handles allocation  | `taskset` via `$PARALLEL_JOBSLOT` |
| Per-task timing       | `sacct --format=…Elapsed` | `/usr/bin/time -v` in output      |
