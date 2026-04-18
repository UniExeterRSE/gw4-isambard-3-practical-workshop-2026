# Multi-Task Slurm Job

A single Slurm job that launches **multiple tasks** — each task runs the same executable simultaneously across cores or
nodes. This is the SPMD (Single Program, Multiple Data) model that underlies most parallel HPC workloads.

Open `sbatch_multi_task.sh` and note the `--ntasks` directive before submitting.

## Submit it

``` bash
sbatch sbatch_multi_task.sh
```

## Monitor it

``` bash
squeue --me
```

## Read the output

``` bash
cat multi_task.out
# or follow it live while the job runs
tail -F multi_task.out
```

You should see one line per task, each reporting a different `SLURM_PROCID`.

## Cancel if needed

``` bash
scancel <jobid>
```

## Questions

1.  How many lines appear in the output, and why?
2.  Are the lines always printed in order (task 0, 1, 2, 3)? Why or why not?
3.  What is `SLURM_PROCID`? How does it differ from `SLURM_JOB_ID`?

## Things to try

- Change `--ntasks` to 8 and resubmit. Does the output scale as expected?

- Try `#SBATCH --exclusive` and see what happens. What `--ntasks` should you set it to?
