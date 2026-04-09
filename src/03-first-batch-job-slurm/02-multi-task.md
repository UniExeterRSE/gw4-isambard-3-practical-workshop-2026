# Multi-Task Slurm Job

Now modify the first example so Slurm launches multiple tasks.

## Starter script

See `multi_task.slurm`.

## Submit it

```bash
sbatch multi_task.slurm
```

## Observe the output

```bash
cat multi_task.out
```

You should see one line from each task.

## Inspect accounting data

```bash
sacct --format=JobID,JobName,State,Elapsed
```

## Things to try

- Change `--ntasks=4` to another value
- Change the job name
- Change the output filename
- Add a short `sleep` command to make queue and run states easier to observe
