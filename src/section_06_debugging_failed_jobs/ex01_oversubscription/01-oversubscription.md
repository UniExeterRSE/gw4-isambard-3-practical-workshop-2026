# Unexpected Performance in a Hybrid Sweep

A sweep job runs 15 MPI×thread configurations. The job completes without errors, but the wall-clock times across
configurations don’t match what you’d expect from a well-tuned parallel job.

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

Look at the `time[s]` column as the output scrolls by:

- Is the `time[s]` column roughly flat across all fifteen configurations?
- Does the time change noticeably as you move toward configurations with more threads per rank?
- Is the all-MPI configuration (144 ranks, 1 thread each) unusually fast compared with configurations that use fewer,
  larger ranks?

## Investigate

1.  Do timings improve, stay flat, or degrade as the thread count per rank increases?
2.  Each configuration multiplies MPI ranks × threads to 144. Does the time you observe match what you’d expect if all
    144 physical cores were equally utilised in every configuration?
3.  What does the absolute wall-clock time tell you about how much of the node’s capacity is actually being used in the
    slow configurations?
4.  If a task is allocated fewer CPU slots than it spawns threads, where do those threads run?

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Compare this script line-by-line to the working version at
  `src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c.sh`
  — focus on the `srun` invocation inside the loop. What flag is present in the reference script but absent here?
- Slurm documentation: when `--cpus-per-task` is absent from `srun`, what is the default number of CPUs allocated to
  each task?
- If Slurm allocates N CPUs to a task and OpenMP sets `OMP_NUM_THREADS=M` where M \> N, what happens to the extra
  threads?
- Re-read the `--cpu_bind=cores` flag. What does it pin threads to, and relative to what allocation?
