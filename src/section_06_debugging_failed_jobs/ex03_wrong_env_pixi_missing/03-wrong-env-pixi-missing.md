# Exercise 3: Wrong Environment — Pixi Not Activated on Compute Node

## The scenario

You have been working on the login node, where direnv automatically activates the pixi environment when you `cd` into
the project directory. Your `monte-carlo-pi-summary` command works fine interactively. You write a batch script, submit
it — and the job fails.

## Submit it

``` bash
sbatch sbatch_wrong_env_pixi_missing.sh
```

## What do you see?

Read the output file once the job finishes:

``` bash
cat wrong_env_pixi_missing_<jobid>.out
```

Look for an error like:

    monte-carlo-pi-summary: command not found

## Questions

1.  The command works on the login node. Why doesn’t it work in the batch job?
2.  What is direnv doing when you `cd` into the project directory on the login node?
3.  Does the compute node run `.envrc`? Why or why not?
4.  What is `pixi shell-hook` doing, and why must it appear explicitly in the batch script?

## Key insight

direnv only runs `.envrc` on interactive shell sessions when you change directory. Slurm batch jobs start a
non-interactive bash shell on the compute node — no direnv, no `.envrc`, no pixi env. The environment from your login
session does **not** transfer to the compute node.

## How to fix

Add the pixi activation line to the batch script, **before** the Python command:

``` bash
# shellcheck disable=SC2312
eval "$(pixi shell-hook --environment hpc)"

monte-carlo-pi-summary -d 2 -n 200000 -t ${NUM_THREADS}
```

This is the pattern used in
`src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/sbatch_monte_carlo_pi_single.sh`.

## Notes

This is one of the most common mistakes HPC beginners make — assuming the interactive environment carries into batch
jobs. It never does. Always activate your environment explicitly inside the batch script.
