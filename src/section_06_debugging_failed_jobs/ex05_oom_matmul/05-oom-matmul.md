# A Job Killed Without an Error Message

A matrix multiply job exits with a non-zero code — but there’s no Python traceback, no explicit error, and the program
never prints its results.

## Prerequisite

This exercise uses the `matmul_naive` binary from Section 3. If you have not already compiled it, do so now:

``` bash
cd src/section_03_first_batch_job_slurm/ex04_matmul/
bash make.sh
cd -
```

Copy or symlink `matmul_naive` into this directory, or adjust the path in the batch script.

## Submit it

``` bash
sbatch sbatch_oom_matmul.sh
```

## Monitor it

``` bash
squeue --me
```

## What do you see?

Check the accounting record once the job ends:

``` bash
sacct --format=JobID,State,ExitCode,MaxRSS -j <jobid>
```

What does `State` show? What is `ExitCode`? Does `MaxRSS` look plausible for a job that was processing large matrices?

## Investigate

- `ExitCode` encodes a Unix signal. What signal does 137 correspond to, and what typically sends it?
- What does `MaxRSS` in `sacct` represent? How does it compare to what the job was allocated?
- What SBATCH options does this script use to request memory? What is the Isambard 3 default memory per CPU?
- How much memory does the matrix operation need? (Hint: 3 matrices of N×N doubles, N=32768, 8 bytes each.)

## Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Slurm documentation: what is `--mem-per-cpu` and what is its default on Isambard 3? What does a job get if no `--mem`
  or `--mem-per-cpu` flag is set?
- With `--ntasks=1 --cpus-per-task=1`, how many CPUs does this job get? Multiply that by the per-CPU default — is it
  enough?
- What SBATCH flag explicitly requests a given amount of total memory (not per-CPU)? Try adding it to the script with a
  value large enough to cover the matrices.
- An alternative: on Isambard 3 Grace nodes each additional CPU brings proportionally more memory. What
  `--cpus-per-task` value would give you enough total memory without adding an explicit `--mem` flag? Is the code able
  to use those extra CPUs?
