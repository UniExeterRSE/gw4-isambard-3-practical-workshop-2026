# A Command That Works Interactively But Not in a Batch Job

You run a command from the login node — it works fine. You put the same command in a batch script and submit it. The job
fails immediately with a command-not-found error.

## Submit it

``` bash
sbatch sbatch_wrong_env_pixi_missing.sh
```

## Monitor it

``` bash
squeue --me
```

Once the job ends, read the output:

``` bash
cat wrong_env_pixi_missing_<jobid>.out
```

## What do you see?

Read the error message in the `.out` (or `.err`) file.

- What is the exact error message?
- Which command does the shell say it cannot find?
- That same command works on the login node. Why might the batch environment be different?

## Investigate

1.  What is different between running a command interactively on the login node and running it inside `sbatch`?
2.  Does the compute node have access to the same software as the login node by default?
3.  What sets up the project environment when you `cd` into this directory on the login node?
4.  Does a Slurm batch job replicate that setup automatically?

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Look at `.envrc` in the project root. When does this file run? (See the direnv documentation.)
- Compare `sbatch_wrong_env_pixi_missing.sh` to
  `src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/sbatch_monte_carlo_pi_single.sh` — what
  line is present in the Section 5 script but absent here?
- What does `pixi shell-hook` do? What would happen if it is never called inside the batch script?
