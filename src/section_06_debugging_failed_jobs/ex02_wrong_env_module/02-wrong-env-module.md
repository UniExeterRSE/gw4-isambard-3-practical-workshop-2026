# A Compiled Binary That Won’t Start

You compiled a program on the login node — it succeeded. You submit a batch job to run it on a compute node. The job
terminates almost immediately with a non-zero exit code.

## Prerequisite

You must have already built `monte_carlo_pi_mpi_hybrid` from the Section 5 exercise. If you have not done that yet, do
it now:

``` bash
cd src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/
bash make.sh
cd -
```

## Submit it

From the directory containing the binary (or after copying / symlinking it):

``` bash
sbatch sbatch_wrong_env_module.sh
```

The job requests only 3 MPI/thread configurations instead of the usual 15, so it should fail within seconds.

## Monitor it

``` bash
squeue --me
```

Once the job ends, read the output:

``` bash
cat wrong_env_module_<jobid>.out
```

## What do you see?

Read the last few lines of the `.out` file carefully.

- What kind of file does the error message mention? What is its extension?
- Does the error come from your program, or does it appear before your program even starts?
- At what stage of execution would the runtime need that type of file?

## Investigate

1.  The binary compiled successfully on the login node. What could be different about the environment on the compute
    node?
2.  Look at what `make.sh` does before calling `make`. What does the batch script do with modules — and what does it
    *not* do?
3.  `module reset` is called in the batch script. What state does that leave the environment in?
4.  The binary is dynamically linked. What has to be true at runtime for it to start successfully?

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Compare the module commands in `sbatch_wrong_env_module.sh` to those in `make.sh` — are they the same? What is present
  in one that is absent in the other?
- What does `module reset` do to environment variables like `LD_LIBRARY_PATH`?
- The pattern `module reset` → `module load <env>` appears in the working scripts from Section 5. Is there a step
  missing here?
- Cray PE documentation: what does loading `PrgEnv-gnu` add to the runtime environment?
