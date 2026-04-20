## Debugging Failed Jobs {#debugging-failed-jobs .hero-slide}

::::::::: hero-grid
::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Debugging Failed Jobs
:::

::: hero-subtitle
Read the error, form a hypothesis, fix it ---\
hands-on practice with broken Slurm scripts
:::

::: next-steps-card
[Resources]{.card-title}

- [Slurm guide](https://docs.isambard.ac.uk/user-documentation/guides/slurm/)
- [`sacct` docs](https://slurm.schedmd.com/sacct.html)
- Helpers are in the room --- raise a hand
:::

::: presenter-line
Section 6 --- 20 min
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
:::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
:::::::::

::: notes
- 20-minute active section: brief intro (2 min), then hands-on. Attendees self-select exercises.
- Pick at most 2--3 exercises to demo; let the room drive
- Do not go through all 7 exercises live; that is what the hands-on time is for
:::

------------------------------------------------------------------------------------------------------------------------

## Exercise menu {#exercise-menu .shell-slide}

::: slide-subtitle
Pick what is most relevant to your work --- you do not need to do all of them
:::

:::: shell-grid
::: shell-text
  Exercise   Topic
  ---------- -----------------------------------------------------------------
  **ex01**   Oversubscription --- srun uses more CPUs than allocated
  **ex02**   Wrong env (module) --- `module load PrgEnv-gnu` missing
  **ex03**   Wrong env (pixi missing) --- pixi not activated on compute node
  **ex04**   Wrong env (pixi wrong) --- wrong pixi env (`default` vs `hpc`)
  **ex05**   OOM --- huge matrix, only 1 CPU, job killed by OOM killer
  **ex06**   MPI topology --- uneven rank distribution across nodes
  **ex07**   Race condition --- missing OpenMP reduction clause (C + Numba)

Each exercise directory has a broken script and a walkthrough `.md`. Start with the one closest to your own work.
:::
::::

::: notes
- Emphasise choice: "pick what interests you most, not all seven"
- Helpers should know which exercises map to which attendee profiles (biosciences → ex03/ex04; HPC-focused → ex06/ex07)
- The table is on the slide so attendees can orient before they open their terminals
:::

------------------------------------------------------------------------------------------------------------------------

## Before you look at the hints... {#productive-struggle .shell-slide}

::: slide-subtitle
The struggle is the learning
:::

::::: fit-panels
::: {.fit-panel .good}
[Do this first]{.fit-title}

- Read the error message carefully
- Form a hypothesis about what is wrong
- Try one fix and observe what changes
- Hints are at the bottom of each exercise `.md`
:::

::: {.fit-panel .bad}
[Resist the urge to]{.fit-title}

- Immediately scroll to the hint
- Paste the error straight into an LLM
- Ask a helper before you have a hypothesis
:::
:::::

::: slide-note
LLMs and helpers are fine --- but only after you have spent a few minutes thinking. The mental model you build by
struggling is the point.
:::

::: notes
Emphasise this before the hands-on block. The goal is not to get to the right answer fastest --- it's to build the
mental model of debugging. Peeking at the answer skips that.
:::

------------------------------------------------------------------------------------------------------------------------

## When a job fails {#debugging-flowchart .shell-slide}

::: slide-subtitle
Four steps, in order --- do not skip to step 4
:::

::::::: flow-row
::: flow-card
[1. Read output]{.flow-title}

``` bash
cat job.out
cat job.err
```

The error message is almost always here. Look at the last few lines.
:::

::: flow-card
[2. sacct]{.flow-title}

``` bash
sacct --format=JobID,State,\
ExitCode,MaxRSS -j <jobid>
```

State, exit code, and peak memory --- the scheduler's view.
:::

::: flow-card
[3. squeue state]{.flow-title}

`PD` pending\
`R` running\
`CG` completing

``` bash
squeue --start --me
```
:::

::: flow-card
[4. Hypothesis]{.flow-title}

Write down what you think is wrong **before** editing the script.

Blind edits waste time.
:::
:::::::

::: notes
- Stress that step 4 is a habit, not optional: if you cannot state a hypothesis, go back to steps 1--3
- sacct may lag a few seconds after job completion --- wait a moment before running it
- squeue --start is useful when a job is stuck in PD for more than a few minutes
:::

------------------------------------------------------------------------------------------------------------------------

## Environment issues {#env-issues .shell-slide}

::: slide-subtitle
ex01--ex04 --- four different ways the environment can be wrong
:::

:::: shell-grid
::: shell-text
**ex01 Oversubscription**

`srun` launches N threads but `--cpus-per-task` is not set (defaults to 1). All threads compete for one CPU.

**ex02 Module missing**

Compiled binary needs `PrgEnv-gnu`; the script forgot `module load PrgEnv-gnu`. Job fails with a linker or
shared-library error.

**ex03 Pixi not activated**

Compute node starts a fresh shell. Without `pixi run` or `eval "$(pixi shell-hook)"`, the Python and packages from the
pixi environment are not on `PATH`.

**ex04 Wrong pixi environment**

The script activates the `default` environment; MPI-enabled code needs the `hpc` environment (Cray MPICH build).
:::
::::

::: notes
- ex01 is the most common mistake for new HPC users; oversubscription is silent --- the job runs but is very slow
- ex02 is specific to Cray PE systems; attendees from other HPC centres may not have seen it before
- ex03 and ex04 are pixi-specific but analogous to conda activate failures attendees may already know
:::

------------------------------------------------------------------------------------------------------------------------

## Resource issues {#resource-issues .shell-slide}

::: slide-subtitle
ex05--ex06 --- memory and topology
:::

:::: shell-grid
::: shell-text
**ex05 Out of memory**

A large matrix is allocated, but the job only requests 1 CPU and the default memory. The OOM killer terminates the
process. `sacct` shows `State=OUT_OF_MEMORY` or `ExitCode=137`.

**ex06 MPI topology**

Ranks are spread unevenly across nodes --- e.g. 3 ranks on node A, 1 on node B. Collective operations stall or produce
incorrect timings because the load is not balanced.
:::
::::

::: notes
- For ex05: MaxRSS in sacct is the peak resident set size; compare it to the allocation to see how close you were
- ExitCode=137 is SIGKILL (128+9); the OOM killer sends SIGKILL, not SIGTERM
- For ex06: mention that srun --distribution=block can help, but the root fix is always matching ntasks to topology
:::

------------------------------------------------------------------------------------------------------------------------

## Correctness issues {#correctness-issues .shell-slide}

::: slide-subtitle
ex07 --- the job finishes but gives the wrong answer
:::

:::: shell-grid
::: shell-text
**ex07 Race condition**

An OpenMP parallel loop accumulates into a shared variable without a `reduction` clause. Multiple threads write to the
same memory simultaneously --- the result is non-deterministic and usually wrong.

The C version and the Numba `@numba.njit(parallel=True)` variant both have this bug.

The job exits 0 and produces output --- but the output is wrong. This is the hardest category to catch.
:::
::::

::: notes
- Emphasise: exit code 0 does not mean correctness; it only means the process ended normally
- For the Numba variant, Numba's auto-parallelisation can introduce the race; the fix is an explicit reduction
- A useful diagnostic: run the broken version multiple times and compare outputs --- non-determinism reveals the race
:::

------------------------------------------------------------------------------------------------------------------------

## Scheduler etiquette {#etiquette .shell-slide}

::: slide-subtitle
The scheduler is shared --- poll responsibly
:::

::::: fit-panels
::: {.fit-panel .good}
[Do this]{.fit-title}

- `squeue --me` --- run manually when you need it
- `watch -n 15 squeue --me` --- minimum 15-second interval
- `squeue --start --me` --- check ETA for pending jobs once
- `scancel <jobid>` --- cancel jobs you no longer need
:::

::: {.fit-panel .bad}
[Do not do this]{.fit-title}

- `watch -n 1 squeue` --- hammers the scheduler
- Looping `squeue` in a shell script without `sleep`
- Leaving idle interactive allocations running
- Submitting dozens of test jobs to check a small fix
:::
:::::

::: slide-note
A good rule: if you would not open-close a door 60 times a minute, do not poll the scheduler that fast either.
:::

::: notes
- This comes up every workshop; mention it before the hands-on block so people internalise it
- watch -n 15 is fine; watch -n 1 or lower is not
- If someone's job is stuck in PD, one squeue --start is all they need; no need to keep polling
:::

------------------------------------------------------------------------------------------------------------------------

## Discussion {#section-6-discussion .qa-slide}

::: qa-mark
Discussion
:::

::: qa-subtitle
Which exercise matched a problem you have seen before? Anything you want to dig into further?
:::
