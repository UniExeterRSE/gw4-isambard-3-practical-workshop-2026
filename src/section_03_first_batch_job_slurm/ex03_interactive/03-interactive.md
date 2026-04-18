# Interactive Job (stretch)

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

Run any of the commands from `sbatch_hello_world.sh` (`hostname`, `date`, `free -h`, `lscpu`, `echo "${SLURM_JOB_ID}"`)
— this time you can eyeball the output directly instead of reading it from a log.

## End the session

``` bash
exit
```

This releases the allocation immediately. Do not leave the shell sitting idle.

## When to use an interactive job

- Quick checks: “does this command exist on compute nodes?”, “does this module load cleanly?”.
- Poking at a failed job’s environment before writing a batch script.
- Short, interactive debugging.
- Computation that requires interactivity. E.g. human feedback to “unstuck” an inverse problems from local minima.

Do **not** use interactive jobs for long-running work. That is what batch jobs are for — they survive you closing your
laptop, the scheduler can backfill them, and they produce a log you can read later.

## Questions

1.  How does the hostname of the compute node compare to the login node?
2.  Is `SLURM_JOB_ID` set inside the interactive shell? What about `SLURM_CPUS_ON_NODE`?
3.  What happens to the allocation if you close your terminal without running `exit`?

## Things to try

- Request more resources and check that the shell reflects them:

  ``` bash
  srun --ntasks=1 --cpus-per-task=4 --time=00:10:00 --pty bash
  nproc
  echo "${SLURM_CPUS_ON_NODE}"
  ```

- Run `squeue --me` from the login node (in a second terminal) while the interactive session is live — confirm the job
  appears in the queue.
