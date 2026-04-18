# Hello World Batch Job

First batch submission. The job proves you can submit and read output, and asks the compute node to tell you about
itself (`hostname`, `date`, `free -h`, `lscpu`, key `SLURM_*` env vars).

Open `sbatch_hello_world.sh` and read through it before submitting — the `#SBATCH` directives at the top are the same as
passing those flags directly to `sbatch`.

## Submit it

``` bash
sbatch sbatch_hello_world.sh
```

## Monitor it

``` bash
squeue --me
```

## Read the output

``` bash
cat hello_world.out
# or follow it live while the job runs
tail -F hello_world.out
```

## Cancel if needed

``` bash
scancel <jobid>
```

## Clean up

``` bash
make clean   # removes *.out, *.err, *.env
```

## Questions

1.  What job ID did Slurm assign?
2.  What hostname did the compute node report? How does it differ from the login node hostname?
3.  What does `lscpu` say about the CPU?
4.  Which `SLURM_*` variables look useful? (e.g. `SLURM_JOB_ID`, `SLURM_CPUS_ON_NODE`, `SLURM_SUBMIT_DIR`.)

## Things to try

- Compare the compute node with the login node by running the script directly on the login node:

  ``` sh
  ./sbatch_hello_world.sh > "hello_world_${HOSTNAME}.out"
  ```

  Then diff `hello_world*.out` and `hello_world*.env` (the script writes env automatically).

- Bump `--cpus-per-task=1` to `--cpus-per-task=4` and re-check `nproc` inside the job.

- Change the job name, the output filename, or the walltime.
