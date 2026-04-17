# Interactive Job

An interactive job gives you a shell on a compute node. It is the fastest way to poke at things — try a command, see the
result, try another — without the submit → wait → read-output loop.

Use it sparingly: compute nodes are a shared resource. Quit the shell (`exit`) as soon as you are done.

## Start an interactive session

``` bash
srun --ntasks=1 --cpus-per-task=1 --time=00:10:00 --pty bash
```

What the flags mean:

- `--ntasks=1` — one task (one shell).
- `--cpus-per-task=1` — one core for that task.
- `--time=00:10:00` — ten-minute wall clock limit. Slurm ends the session if you forget.
- `--pty bash` — attach a pseudo-terminal and start `bash`.

You will wait briefly in the queue, then land on a compute node with a prompt.

## Try a few commands

``` bash
hostname
whoami
pwd
date
free -h
lscpu | head
nproc
echo "${SLURM_JOB_ID}"
```

Compare `hostname` here with the login node — you are on a different machine now.

## End the session

``` bash
exit
```

This releases the allocation immediately. Do not leave the shell sitting idle.

## Questions

1.  Which hostname did the compute node report?
2.  What does `echo "${SLURM_JOB_ID}"` print — and does it match what `squeue --me` showed while you were waiting?
3.  How is the output from `lscpu` different from the login node?

## When to use an interactive job

- Quick checks: “does this command exist on compute nodes?”, “does this module load cleanly?”.
- Poking at a failed job’s environment before writing a batch script.
- Short, interactive debugging.

Do **not** use interactive jobs for long-running work. That is what batch jobs are for — they survive you closing your
laptop, the scheduler can backfill them, and they produce a log you can read later.
