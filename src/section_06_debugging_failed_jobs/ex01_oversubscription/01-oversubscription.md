# Oversubscription — Missing `--cpus-per-task`

A hybrid MPI+OpenMP job has a subtle bug: the `srun` call inside the sweep loop is missing `--cpus-per-task`. The job
submits and runs without error, but the performance numbers look wrong. Your task is to spot the bug, understand why it
hurts, and fix it.

## Prerequisite

You need the `monte_carlo_pi_mpi_hybrid` binary on your `PATH`. If you have not built it yet, go to
`src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/` and run:

``` bash
bash make.sh
```

That compiles the C MPI+OpenMP source under `PrgEnv-gnu` and places the binary in the same directory. Make sure that
directory is on your `PATH`, or copy the binary into this exercise directory before submitting.

## Submit the job

From inside this directory:

``` bash
cd src/section_06_debugging_failed_jobs/ex01_oversubscription
sbatch sbatch_oversubscription.sh
```

Or give the full path from anywhere:

``` bash
sbatch src/section_06_debugging_failed_jobs/ex01_oversubscription/sbatch_oversubscription.sh
```

## Monitor the job

Check whether it is queued or running:

``` bash
squeue --me
```

Once it starts, follow the output live:

``` bash
tail -F oversubscription_<jobid>.out
```

Replace `<jobid>` with the number printed by `sbatch`. Press `Ctrl-C` to stop following.

## What do you see?

The script sweeps fifteen MPI-rank × OMP-thread combinations that all multiply to 144 (the full Grace CPU core count).
In a correctly configured run the wall-clock time should be roughly constant across all fifteen rows — every physical
core is doing the same amount of work regardless of how it is divided between ranks and threads.

Look at the `time[s]` column as the output scrolls by:

- Do the timings stay flat across configurations?
- Does performance *degrade* as you move toward configurations with more threads per rank (e.g. 1 rank × 144 threads)?
- Is the all-MPI configuration (144 ranks, 1 thread each) unexpectedly fast compared with configurations that use fewer,
  larger ranks?

Non-monotonic or strongly degrading timings in the many-threads-per-rank configurations are the symptom of
oversubscription.

## Questions

1.  **How many CPUs does Slurm allocate to each task by default?**

    Open `sbatch_oversubscription.sh` and look at the `srun` line inside the loop. The working script in
    `src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c.sh`
    passes `--cpus-per-task="${nthreads}"` to `srun`. This script does not. When `--cpus-per-task` is absent, Slurm
    allocates **1 CPU per task** by default. How does that interact with a configuration like 1 rank × 144 threads?

2.  **What does `OMP_NUM_THREADS=144` tell OpenMP to do? Where do those threads actually run?**

    `OMP_NUM_THREADS` is still exported before each `srun` call, so OpenMP tries to launch as many threads as the
    variable says. Because Slurm has allocated only 1 CPU-slot to that task, all 144 threads are fighting over one
    hardware core. What do you expect that to do to performance?

3.  **What is oversubscription, and why does it hurt?**

    Oversubscription occurs when more threads (or processes) are runnable than there are physical CPU cores available to
    run them. The OS scheduler must time-slice them onto the available core(s), causing context-switch overhead and
    preventing the CPU from running at full throughput. In HPC workloads — especially tight numerical loops — this
    almost always causes a large slowdown rather than the parallelism benefit you were hoping for.

## How to fix it

Add `--cpus-per-task="${nthreads}"` back to the `srun` call in the loop:

``` bash
srun -n "${nproc}" --cpus-per-task="${nthreads}" --cpu_bind=cores monte_carlo_pi_mpi_hybrid -d 2 -n "${N}"
```

This tells Slurm to reserve `nthreads` CPU-slots for each MPI rank, so when OpenMP spawns that many threads they each
land on a distinct physical core. The corrected script is at:

    src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c.sh

Submit that version and compare the timings. The fifteen configurations should now produce similar wall-clock times.

## A note on `--exclusive` and CPU binding

The job requests `#SBATCH --exclusive`, which means the entire node is reserved for this job — no other jobs share the
144 physical Grace cores. However, `--exclusive` alone does not tell Slurm how to divide those cores among tasks.
`--cpu_bind=cores` controls *how* each task is pinned to cores, but the binding is relative to the CPU-slot allocation
that `--cpus-per-task` defines. Without `--cpus-per-task`, every task’s allocation is 1 core, so `--cpu_bind=cores` pins
all threads of a task to that single core — exactly the oversubscription scenario described above.
