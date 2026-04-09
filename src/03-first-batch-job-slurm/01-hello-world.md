# Hello World Batch Job

Create and inspect a very small Slurm job first.

## Starter script

See `hello_world.slurm`.

## Submit it

```bash
sbatch hello_world.slurm
```

## Monitor it

```bash
squeue --me
```

## Read the output

```bash
cat hello_world.out
```

## Cancel if needed

```bash
scancel <jobid>
```

## Questions

1. What job ID did Slurm assign?
2. What host ran the job?
3. Where did standard output go?
