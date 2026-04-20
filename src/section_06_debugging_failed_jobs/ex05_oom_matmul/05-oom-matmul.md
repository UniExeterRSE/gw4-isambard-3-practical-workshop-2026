# Exercise 5 — Out of Memory: Large Matrix on a Single CPU

## Prerequisite

This exercise uses the `matmul_naive` binary from Section 3. If you have not already compiled it, do so now:

``` bash
cd src/section_03_first_batch_job_slurm/ex04_matmul/
bash make.sh
cd -
```

Copy or symlink `matmul_naive` into this directory, or adjust the path in the batch script.

## The scenario

You want to run a large matrix multiply. You request just 1 CPU to keep things simple — after all, the naive
implementation is single-threaded. The matrix is `N = 32768`.

## Memory calculation

Work out how much memory the job needs before submitting:

    3 matrices of N×N doubles:
      N = 32768
      Memory = 3 × 32768² × 8 bytes
             = 3 × 1,073,741,824 × 8
             ≈ 24 GB
    Default Isambard 3 memory per CPU ≈ 3.3 GB
    → OOM!

Isambard 3 Grace nodes have 144 cores and 480 GB RAM, giving roughly 3.3 GB per core. A job that requests
`--cpus-per-task=1` (and no explicit `--mem`) receives only ~3.3 GB — nowhere near the 24 GB needed.

## Submit the job

``` bash
sbatch sbatch_oom_matmul.sh
```

## What do you see?

The job is killed almost immediately. Check its accounting record:

``` bash
sacct --format=JobID,State,ExitCode,MaxRSS -j <jobid>
```

Look for:

- **State**: `OUT_OF_MEMORY` (or `FAILED` on some systems)
- **ExitCode**: `137:0` — exit code 137 means the process was killed by signal 9 (SIGKILL), which is what the Linux OOM
  killer sends

The `MaxRSS` column shows the peak resident memory at the point the job was killed. Because the OOM kill happens early,
this value will be well below the 24 GB the job actually needs.

## Questions

1.  How much memory does the matrix operation need? Show the calculation.
2.  How much memory does Slurm allocate for a `--cpus-per-task=1` job on Isambard 3 (no `--mem` flag)?
3.  What does exit code 137 mean?

## How to fix — three options

### Option 1 — Request more memory explicitly (recommended)

Add `#SBATCH --mem=32G` and keep `--cpus-per-task=1`:

``` bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
```

**Tradeoff**: most precise. You get exactly the memory you need without reserving extra CPU cores. Use this when the
code is single-threaded and you just need a larger memory window.

### Option 2 — Request more CPUs (each brings ~3.3 GB)

Add `#SBATCH --cpus-per-task=12` (12 × 3.3 ≈ 40 GB) and update the thread count:

``` bash
#SBATCH --cpus-per-task=12
```

``` bash
export OMP_NUM_THREADS=12
```

**Tradeoff**: gives you more parallelism as well as more memory. Useful if the code is multi-threaded (e.g.
OpenMP-enabled matmul variants), but wastes CPU time if the code cannot use them.

### Option 3 — Use `--exclusive` to get the whole node

``` bash
#SBATCH --nodes=1
#SBATCH --exclusive
```

**Tradeoff**: simplest to reason about (480 GB available, all 144 cores), but wasteful if your job only uses a fraction
of the node. Avoid on shared queues unless the workload genuinely needs the full node.

## Key command to remember

``` bash
sacct --format=JobID,State,ExitCode,MaxRSS -j <jobid>
```

`MaxRSS` shows the peak resident memory and is your primary evidence for an OOM failure. Combine it with `State` and
`ExitCode` to distinguish OOM kills from other failures.
