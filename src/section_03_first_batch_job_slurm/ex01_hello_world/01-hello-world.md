# Hello World Batch Job

First batch submission. The job does two jobs at once: prove you can submit and read output, and ask the compute node to
tell you about itself (`hostname`, `date`, `free -h`, `lscpu`, `SLURM_*` env).

## Starter script

See `hello_world.sh`.

## Submit it

``` bash
sbatch hello_world.sh
```

## Monitor it

``` bash
squeue --me
```

## Read the output

``` bash
cat hello_world.out
```

## Cancel if needed

``` bash
scancel <jobid>
```

## Questions

1.  What job ID did Slurm assign?
2.  What hostname did the compute node report? How is that different from the login node?
3.  What does `lscpu` say about the CPU? (Expect `aarch64` and Neoverse-V2.)
4.  Which `SLURM_*` variables look useful? (e.g. `SLURM_JOB_ID`, `SLURM_CPUS_ON_NODE`, `SLURM_SUBMIT_DIR`.)

## Things to try

- Run the same commands (`hostname`, `date`, `free -h`, `lscpu`) on the login node and compare.
- Add `nproc` and compare it with `SLURM_CPUS_ON_NODE`.
- Bump `--cpus-per-task=1` to `--cpus-per-task=4` and re-check `nproc` inside the job.
- Change the job name, the output filename, or the walltime.
- Add a short `sleep` command to make queue and run states easier to observe in `squeue --me`.
