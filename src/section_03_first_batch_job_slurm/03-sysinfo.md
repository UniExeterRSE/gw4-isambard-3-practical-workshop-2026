# Single-Core System Info Job

A slightly more useful single-core job: ask a compute node to tell you about itself.

This is a good second submission because it still fits in one core and a couple of minutes, but the output is
interesting — you can compare what Slurm reports on a compute node with what you see on the login node.

## Starter script

See `sysinfo.sh`. It runs `date`, `hostname`, `free -h`, `lscpu`, and prints the `SLURM_*` environment variables so you
can see what the scheduler hands to your job.

## Submit it

``` bash
sbatch sysinfo.sh
```

## Read the output

``` bash
cat sysinfo.out
```

## Compare with the login node

Run the same commands interactively on the login node:

``` bash
date
hostname
free -h
lscpu
```

## Questions

1.  Which hostname did the compute node report? How is it different from the login node?
2.  How much memory does `free -h` show on the compute node?
3.  What does `lscpu` say about the CPU architecture and model? (You should see `aarch64` and Neoverse-V2.)
4.  Which `SLURM_*` variables look useful? (e.g. `SLURM_JOB_ID`, `SLURM_CPUS_ON_NODE`, `SLURM_SUBMIT_DIR`.)

## Things to try

- Add `nproc` and compare it with `SLURM_CPUS_ON_NODE`.
- Change `--cpus-per-task=1` to `--cpus-per-task=4` and re-check `nproc` inside the job.
- Add `cat /proc/cpuinfo | head -40` to see per-core detail.
