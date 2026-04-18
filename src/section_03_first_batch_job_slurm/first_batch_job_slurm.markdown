## First Batch Job with Slurm {#first-batch-job-slurm .hero-slide}

::::::::: hero-grid
::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
First Batch Job with Slurm
:::

::: hero-subtitle
sbatch, squeue, sacct ---\
the submit-check-read-output loop
:::

::: next-steps-card
[Resources]{.card-title}

- [Slurm guide](https://docs.isambard.ac.uk/user-documentation/guides/slurm/)
- [Job scripts](https://docs.isambard.ac.uk/user-documentation/guides/slurm/#job-scripts)
- Helpers are in the room --- raise a hand
:::

::: presenter-line
Section 3 --- 25 min
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
:::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::::::

::: notes
- 25-minute active section: Present -\> Demo -\> Hands-on -\> Discussion
- Taught core: hello-world + multi-task. Interactive and matmul are stretch, reach for them only if the room is ahead
- Do NOT drift into partition changes or `--mail-type=END`; both are out of scope for the beginner path
- Biggest risk is spending too long on one walkthrough; keep momentum and redirect bespoke questions to Q&A or follow-up
:::

## Why batch? {#why-batch .shell-slide}

::: slide-subtitle
Compute nodes are shared --- the scheduler is how you ask for a slice
:::

:::: shell-grid
::: shell-text
- **Login node** --- where you type `ssh` into. Shared by everyone. No heavy compute here.
- **Compute nodes** --- what Slurm hands out when you submit a job. Your work runs here.
- **Slurm** --- the scheduler. You write a script that says *how much* and *for how long*, and it finds you a slot.

The loop we will practise: **submit → check → read output**. Repeat until you get what you want.
:::
::::

::: notes
- Big idea: no "run my program on the cluster" button; you write a tiny shell script and hand it to sbatch
- If anyone tries to run heavy work on the login node, redirect kindly --- this is why that is not OK
- No need to talk about partitions, QOS, or accounting groups here; defer to the docs
:::

## Anatomy of a batch script {#anatomy-of-a-batch-script .shell-slide}

::: slide-subtitle
Shebang + `#SBATCH` directives + normal shell commands
:::

:::: shell-grid
::: shell-text
``` bash
#!/bin/bash
#SBATCH --job-name=hello-world
#SBATCH --output=hello_world.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:02:00

echo "Job ID: ${SLURM_JOB_ID}"
echo "Host:   $(hostname)"
date
free -h
lscpu
env | grep '^SLURM_' | sort
```

- `#SBATCH` lines are comments to the shell, **directives** to Slurm
- Below the directives is just bash --- anything you can run interactively
:::
::::

::: notes
- Walk through the directives live: name, output, ntasks, cpus-per-task, time
- Flag that `--time` is a hard limit --- overshoot and Slurm kills the job (this comes back in debugging)
- The body is ordinary shell, which is why we use it to ask the node about itself on the first run
:::

## Submit, check, read {#submit-check-read .shell-slide}

::: slide-subtitle
Three commands you will use every day
:::

:::::: flow-row
::: flow-card
[sbatch]{.flow-title}

``` bash
sbatch hello_world.sh
```

Returns a **job ID**.
:::

::: flow-card
[squeue \--me]{.flow-title}

``` bash
squeue --me
```

States: `PD` (pending), `R` (running), `CG` (completing).
:::

::: flow-card
[read / cancel]{.flow-title}

``` bash
cat hello_world.out
scancel <jobid>
```

Output is just a file. Cancel any job you submitted by mistake.
:::
::::::

::: slide-note
`squeue --me` is the polite version of `squeue`. Do not `watch`-style hammer the scheduler --- it is shared.
:::

::: notes
- Demo live: sbatch the script, show squeue --me while it is PD/R, then cat the output
- Point out the output file is just a file --- any editor or pager works
- Mention scancel exists; show it if a job is still PD long enough to demonstrate
:::

## Hands-on: hello world {#hands-on-hello-world .shell-slide}

::: slide-subtitle
\~8 minutes --- helpers are circulating
:::

:::: shell-grid
::: shell-text
1.  Copy `hello_world.sh` from `/projects/workshop/` into your `$HOME`.

2.  Submit it:

    ``` bash
    sbatch hello_world.sh
    ```

3.  Watch it:

    ``` bash
    squeue --me
    ```

4.  Read the output once it finishes:

    ``` bash
    cat hello_world.out
    ```

**Stretch for fast finishers:** change the walltime, the job name, or the output filename. Add a short `sleep 30` to see
the job sit in `R` state in `squeue --me`.
:::
::::

::: notes
- Primary teaching goal: everyone gets one successful submission before anything else happens
- Helpers prioritise unblocking stragglers; do not get drawn into stretch discussion while anyone is stuck
- If the queue is slow, use the wait time to talk through the output they will see
:::

## Multi-task: ntasks + srun {#multi-task-ntasks-srun .shell-slide}

::: slide-subtitle
Same job, four tasks, one `srun` to launch them
:::

:::: shell-grid
::: shell-text
``` bash
#!/bin/bash
#SBATCH --job-name=multi-task
#SBATCH --output=multi_task.out
#SBATCH --ntasks=4
#SBATCH --time=00:02:00

srun bash -c 'echo "Task ${SLURM_PROCID} running on $(hostname)"'
```

- `--ntasks=4` --- Slurm allocates slots for four tasks
- `srun` --- launches the command across all allocated tasks
- `${SLURM_PROCID}` --- each task sees its own rank (0, 1, 2, 3)

After it runs:

``` bash
cat multi_task.out
sacct --format=JobID,JobName,State,Elapsed
```
:::
::::

::: notes
- Keep this short: the point is just "here is how you fan out to N tasks"
- No MPI here --- tasks are independent bash commands
- `sacct` is a first look; it comes back in the debugging section
:::

## Hands-on: multi-task + sacct {#hands-on-multi-task-sacct .shell-slide}

::: slide-subtitle
\~7 minutes --- change a knob and observe
:::

:::: shell-grid
::: shell-text
1.  Submit `multi_task.sh`.
2.  `cat multi_task.out` --- confirm one line per task.
3.  `sacct --format=JobID,JobName,State,Elapsed` --- see your recent jobs.

**Stretch:**

- Change `--ntasks=4` to another value and compare the output.
- Add `sleep 10` inside the `srun` command to make the job visible in `squeue --me` for longer.
- Try `sacct --format=JobID,JobName,State,ExitCode,MaxRSS` (more columns come back in debugging).
:::
::::

::: notes
- Remind: sacct reads from the accounting database, so it may lag a few seconds after the job completes
- Do not chase a full tour of sacct columns --- defer to Section 6
:::

## Stretch: interactive jobs {#stretch-interactive-jobs .shell-slide}

::: slide-subtitle
Fastest way to poke at something --- but quit as soon as you are done
:::

:::: shell-grid
::: shell-text
``` bash
srun --ntasks=1 --cpus-per-task=1 --time=00:10:00 --pty bash
```

Lands you on a compute node with a prompt. Run the same commands you would put in a batch script.

- Quick: "does this module load cleanly?", "does my script find its data?"
- Short-lived: `exit` when you are done --- do not idle

**Do not** use interactive jobs for long-running work. Batch survives laptop lids.
:::
::::

::: notes
- Only reach for this slide if the room is ahead
- Make it explicit: interactive jobs are a convenience tool, not the default workflow
- If someone's VS Code tunnel is already active, avoid suggesting they run compute work in the login node shell;
  redirect them to batch instead, because login nodes are not for compute
:::

## Stretch: run something non-trivial {#stretch-matmul .shell-slide}

::: slide-subtitle
Compile + submit + read --- same loop, bigger payload
:::

:::: shell-grid
::: shell-text
One C file, two builds: a hand-rolled triple loop and a call into BLAS `cblas_dgemm`. Both print wall time and GFLOPS.

``` bash
module load PrgEnv-gnu
make                   # cc -O3 -mcpu=neoverse-v2 ... (LibSci auto-linked)
./matmul_naive 1024
./matmul_dgemm 1024
```

Run both under Slurm with `make.sh` (1-minute walltime, 1 core).

    matmul routine=naive ikj triple loop (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=1.8321 gflops=1.17 checksum=1.234567e+08
    matmul routine=cblas_dgemm (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0421 gflops=51.02 checksum=1.234567e+08

Same machine, same `N`, same arithmetic. Notice the gap. We are **not** dissecting it today --- we will revisit *why*
(cache blocking, vectorisation, LibSci) later in the workshop.
:::
::::

::: notes
- Only reach for this if the room has comfortably finished multi-task
- Framing: "here is something non-trivial running end-to-end"; do not be tempted to start explaining LibSci threading
- The naive/BLAS gap is deliberate bait --- acknowledge it, then defer the why to the later scaling/precision section
- If someone asks "why is it so fast / slow?", note it and defer to the later section
:::

## Do not do these today {#do-not-do-these-today .shell-slide}

::: slide-subtitle
Out of scope for this section --- defer to docs or later sections
:::

::::: fit-panels
::: {.fit-panel .good}
[Stay in scope]{.fit-title}

- `sbatch`, `squeue --me`, `scancel`, `sacct`
- `--ntasks`, `--cpus-per-task`, `--time`, `--output`
- `srun` for fan-out, `srun --pty bash` for a quick shell
:::

::: {.fit-panel .bad}
[Out of scope]{.fit-title}

- Partitions / QOS / reservations
- `--mail-type=END` and email notifications
- MPI launches (Section 5 stretch)
- Container launches (follow-up only)
:::
:::::

::: slide-note
We cover debugging failed jobs properly in Section 6. If a job misbehaves, note it and bring it there.
:::

::: notes
- This slide is the guardrail: if a question pulls us out of scope, acknowledge and defer
- Partition defaults work for the workshop project; do not encourage attendees to change them
- Email notifications are a common ask --- answer briefly and move on
:::

## Discussion {#section-3-discussion .qa-slide}

::: qa-mark
Discussion
:::

::: qa-subtitle
Did your first job run? Anything unexpected in the output? Anything you want to try next?
:::
