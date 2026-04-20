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
- 25-minute active section: Present → Demo ex01 → Demo ex03 → Hands-on (all four, self-paced) → Discussion
- Flow: talk through anatomy + submit/check/read (\~4 min), demo ex01 live, show interactive with ex03 demo, then
  release to hands-on block; attendees start at ex01 and move forward at their own pace
- Do NOT drift into partition changes or `--mail-type=END`; both are out of scope for the beginner path
- Biggest risk is spending too long on one demo; keep momentum and redirect bespoke questions to Q&A or follow-up
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
#SBATCH --job-name=hello_world
#SBATCH --output=hello_world.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00

echo "Job ID: ${SLURM_JOB_ID}"
echo "Host:   $(hostname)"
date
free -h
lscpu
env | sort > hello_world_${HOSTNAME}.env
```

- `#SBATCH` lines are comments to the shell, **directives** to Slurm
- Below the directives is just bash --- anything you can run interactively
- Think **reproducibility**: the script documents exactly how the job was set up --- do not rely on modules you loaded
  earlier or files you happened to have in `$PWD`; put everything the job needs inside the script
:::
::::

::: notes
- Walk through the directives live: name, output, ntasks, cpus-per-task, time
- Flag that `--time` is a hard limit --- overshoot and Slurm kills the job (this comes back in debugging)
- The body is ordinary shell, which is why we use it to ask the node about itself on the first run
- DEMO: switch to terminal; `cd ex01_hello_world`; open `sbatch_hello_world.sh` briefly; `sbatch sbatch_hello_world.sh`;
  show `squeue --me` while it runs; `cat hello_world.out`
:::

## Submit, check, read {#submit-check-read .shell-slide}

::: slide-subtitle
Three commands you will use every day
:::

:::::: flow-row
::: flow-card
[sbatch]{.flow-title}

``` bash
sbatch sbatch_hello_world.sh
```

Returns a **job ID**.
:::

::: flow-card
[squeue \--me]{.flow-title}

``` bash
squeue --me
watch -n 15 squeue --me
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
`watch -n 15 squeue --me` polls every 15 seconds --- do not go lower. The scheduler is shared.
:::

::: notes
- Point out the output file is just a file --- any editor or pager works
- Mention scancel exists; show it if a job is still PD long enough to demonstrate
:::

## Interactive jobs {#interactive-jobs .shell-slide}

::: slide-subtitle
A shell on a compute node --- fastest way to poke at something
:::

:::: shell-grid
::: shell-text
``` bash
srun --ntasks=1 --cpus-per-task=1 --time=00:10:00 --pty bash
```

Lands you on a compute node with a prompt. Run the same commands you would put in a batch script.

- Quick checks: "does this module load cleanly?", "does my script find its data?"
- Short-lived: `exit` when you are done --- do not idle
- Some workflows **genuinely need** interactivity: steering a solver, inspecting intermediate results, manually nudging
  a parameter to escape a local minimum. If your science requires a human in the loop, this is the tool.

The point is not "never use interactive jobs" --- it is **use resources responsibly**. Idle allocations block others.
Batch is better when there is no human in the loop.
:::
::::

::: notes
- DEMO: run the srun command live; show hostname changing; run a couple of commands; exit immediately
- `srun` appears here and in ex02 (multi-task) --- same command, different context; the .md files explain both
- Make it explicit: interactive jobs are a convenience tool, not the default workflow
- If someone's VS Code tunnel is already active, avoid suggesting they run compute work in the login node shell;
  redirect them to batch instead, because login nodes are not for compute
:::

## Workshop reservation {#workshop-reservation .shell-slide}

::: slide-subtitle
We have a reservation for today --- add these flags to `sbatch` and `srun` commands that should use the reservation
:::

:::: shell-grid
::: shell-text
Inspect the reservation and QOS before you use them:

``` bash
scontrol show res exeter-workshop-260421
sacctmgr show qos brics.e6c_qos
```

**On the command line:**

``` bash
sbatch --reservation=exeter-workshop-260421 --qos=brics.e6c_qos sbatch_hello_world.sh
```

**Or inside your batch script** (add these two `#SBATCH` lines):

``` bash
#SBATCH --reservation=exeter-workshop-260421
#SBATCH --qos=brics.e6c_qos
```

Gotchas:

- Reservation alone --- works fine
- Reservation **and** QOS --- works fine
- QOS **without** reservation --- `sbatch: error: Batch job submission failed: Invalid qos specification`
- More than 2 nodes --- `QOSMaxNodePerUserLimit` (the reservation caps per-user node count)
:::
::::

::: notes
- Show `scontrol show res` output briefly so attendees can see start/end time and node list
- The QOS error without a reservation is the most common trip-up; pre-empt it here
- The 2-node cap is deliberate so one person cannot monopolise the reservation
:::

## Hands-on {#hands-on .shell-slide}

::: slide-subtitle
\~15 minutes --- work in order, skip an exercise if it feels too easy
:::

:::: shell-grid
::: shell-text
- **ex01** `ex01_hello_world/` → `01-hello-world.md` --- first sbatch submission
- **ex02** `ex02_multi_task/` → `02-multi-task.md` --- ntasks + srun + sacct
- **ex03** `ex03_interactive/` → `03-interactive.md` --- interactive shell
- **ex04** `ex04_matmul/` → `04-matmul.md` --- compile + run (build first: `bash make.sh`)

Each `.md` has the commands to run, questions to think about, and things to try if you finish early.
:::
::::

::: notes
- Helpers: circulate and unblock; do not get drawn into ex04 discussion while anyone is stuck on ex01
- If the queue is slow, the wait is a good moment to walk through what the output will look like
- sacct may lag a few seconds after a job completes --- normal
- ex04 needs a build step before sbatch: `bash make.sh` inside ex04_matmul/; mention this if people reach it
- Two gaps in ex04 are deliberate bait: BLAS vs naive, and single vs double --- acknowledge, defer the why to later
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
