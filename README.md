# Isambard 3 Practical Workshop

- **Date:** Tuesday 21 April 2026, 10:00am–12:30pm
- **Location:** Artificial Intelligence (AI) Arena, SWIoT, Exeter
- **Capacity:** 40 attendees
- **Audience:** New and intermediate HPC users wanting practical guidance on GW4 Isambard 3

This workshop follows the HPC Showcase on 20 April.

## Purpose of this document

This README is a planning blueprint for developing the workshop materials, slides, exercises, and communications.

Core design principles:

- Keep the core path accessible to genuine beginners.
- Preserve stretch goals for faster and more experienced attendees.
- Prioritise login, Slurm, debugging, and practical software setup over broad coverage.
- Avoid going deep on participants' own custom software stacks during the session.
- Treat anything outside the prepared exercises as follow-up support rather than in-room troubleshooting.

## Schedule

| #   | Section                                              | Duration | Time        |
| --- | ---------------------------------------------------- | -------- | ----------- |
| 1   | Welcome + Start Login + System Overview (overlapped) | 30 min   | 10:00–10:30 |
| 2   | Login Checkpoint + First Commands                    | 10 min   | 10:30–10:40 |
| 3   | First Batch Job (Slurm)                              | 25 min   | 10:40–11:05 |
| 4   | Break                                                | 10 min   | 11:05–11:15 |
| 5   | Installing Software                                  | 15 min   | 11:15–11:30 |
| 6   | Python Example + Array Jobs + Parallelism Strategies | 25 min   | 11:30–11:55 |
| 7   | Debugging Failed Jobs                                | 20 min   | 11:55–12:15 |
| 8   | Tips, Help, Wrap-Up, Q&A & Feedback                  | 15 min   | 12:15–12:30 |

## Section Details

### 1. Welcome + Start Login + System Overview (30 min)

Login and the overview run in parallel: attendees begin the Clifton login process (`clifton auth`, then `ssh`) while the presenter gives a lightweight system overview and helpers circulate.

Keep the system overview deliberately light:

- what Isambard 3 is
- where it sits in the UK HPC landscape
- Grace CPU nodes / Arm/aarch64 at a high level
- Slurm as the scheduler
- the main storage areas they will use in the workshop

Do **not** spend long here on architecture-specific software discussion. Keep that for the software section when it is directly relevant.

Slides should stay low-demand: large diagrams, minimal text, clear signposting.

### 2. Login Checkpoint + First Commands (10 min)

Quick checkpoint that everyone is in. Helpers mop up stragglers.

Then a short guided orientation:

- `whoami`
- `hostname`
- `pwd`
- `module avail | head`
- `module list`
- `module reset`
- `echo $HOME`
- `echo $PROJECTDIR`
- `echo $SCRATCHDIR`

Key teaching point here is not just naming directories, but _what goes where_:

- `$HOME` for config, scripts, and small outputs
- `$PROJECTDIR` for shared project material
- `$SCRATCHDIR` for working data and temporary job data

Also remind attendees:

- storage is working storage, not archival
- scratch is temporary
- filling `$HOME` can cause avoidable problems

### 3. First Batch Job — Slurm (25 min)

Two iterations:

1. **Hello World**
   - walk through a job script line by line
   - submit with `sbatch`
   - monitor with `squeue --me`
   - inspect the output file
   - show `scancel`

2. **Multi-task**
   - modify to `--ntasks=4`
   - add `srun`
   - resubmit
   - compare output
   - introduce `sacct`

Stretch goals for fast finishers:

- change walltime
- change job name / output filename
- change `--ntasks`
- add a small `sleep` so they can observe queue/running states more clearly

Do **not** include partition changes in the beginner path.

Do **not** include `--mail-type=END` as a stretch goal.

### 4. Break (10 min)

Short break.

### 5. Installing Software (15 min)

Keep this section tightly scoped.

#### Core story

1. **Modules first**
   - `module spider`
   - `module load`
   - `module list`
   - `module reset`

2. **Conda / mamba / pixi path**
   - create an isolated environment
   - keep environments separate from `base`
   - install into user/project/scratch-owned locations as appropriate

3. **When it fails**
   - do not turn the workshop into open-ended custom environment debugging
   - tell attendees that if their own stack does not fit the prepared path, they should follow up through the docs/support route after the workshop

4. **Containers**
   - mention them briefly as a follow-up route
   - do not teach them hands-on in this workshop

This section should help attendees understand the decision order:

- first try modules
- if not available, use the prepared user-managed environment route
- if that becomes bespoke and messy, take it offline and point them to support/docs

### 6. Python Example + Array Jobs + Parallelism Strategies (25 min)

**Part A — Single job (~8 min)**

Use the prepared Monte Carlo Pi example from `/projects/workshop/`.

Attendees write a small job script that loads Python and runs the example.

Goals:

- load the right software
- submit a job
- inspect output
- confirm they can run a realistic but simple script

**Part B — Array jobs (~7 min)**

Add `--array=1-10` and read `$SLURM_ARRAY_TASK_ID` as the seed.

Goals:

- understand how arrays fan out
- inspect per-task outputs
- see how arrays help with repeated independent tasks

**Part C — Three ways to run many serial jobs (~10 min)**

Compare approaches conceptually:

| Approach                   | How                       | Good for                            | Watch out                                                            |
| -------------------------- | ------------------------- | ----------------------------------- | -------------------------------------------------------------------- |
| GNU Parallel (single node) | One-node launcher pattern | Hundreds of short tasks on one node | Bound to one node; confirm module availability in prep               |
| Slurm job arrays           | `--array=1-N`             | Moderate independent tasks          | Large arrays can place extra strain on the scheduler; use throttling |
| MPI parallelism            | `mpi4py` / compiled MPI   | Multi-node communicating tasks      | Requires MPI-aware code                                              |

This part should remain comparative and practical rather than deep.

### 7. Debugging Failed Jobs (20 min)

This should stay hands-on and explicitly problem-solving focused.

#### Broken scripts exercise (~12 min)

Prepared broken examples:

1. Wrong module name → inspect `.err`
2. Walltime too short → inspect `sacct`, see `TIMEOUT`
3. Write to non-existent directory → inspect exit code / error output

Participants submit, diagnose, fix, and resubmit.

#### Debugging flowchart (~8 min)

Walk through these:

- `squeue` states: `PD`, `R`, `CG`
- `squeue --start`
- `sacct --format=JobID,State,ExitCode,MaxRSS`
- `.out` and `.err` first
- module/path errors
- time limit exceeded
- memory issues
- wrong path / missing directory

Add a brief etiquette note:

- do not aggressively poll `squeue`/`sinfo`
- avoid `watch`-style hammering of scheduler commands

### 8. Tips, Help, Wrap-Up, Q&A & Feedback (15 min)

Use this as a flexible closing block.

Suggested contents:

- file transfer one-liners: `scp`, `rsync`
- where to look next in the docs
- support route
- workshop Slack / channel for community follow-up
- feedback QR code
- open Q&A

Important distinction to make clear:

- Slack/community follow-up can be useful for workshop continuity
- official BriCS support issues should go through the helpdesk

## Pre-Workshop Email

Send on Thursday before the event.

Ask attendees to:

- set their UNIX short name via the portal
- check they have an SSH key pair (or generate one)
- optionally install Clifton ahead of time
- bring a laptop that can open a terminal and a web browser

Keep this optional/preparatory rather than a hard gate.

## Workshop Material Design Notes

### Prepared materials to create

- slide deck
- first Slurm job script
- multi-task Slurm job script
- Monte Carlo Pi Python script
- array job variant
- three broken debugging scripts
- software setup mini-walkthrough
- file transfer slide
- wrap-up slide with links and QR codes

## TODOs

- [ ] Pre-workshop email draft
- [ ] Slide deck outline
- [ ] Broken job scripts for debugging exercise (3 scripts)
- [ ] First Slurm job script
- [ ] Multi-task Slurm job script
- [ ] Monte Carlo Pi Python script
- [ ] Array job version of the Python example
- [ ] GNU Parallel example or confirm whether to keep it conceptual only
- [ ] Stretch goals for each hands-on section
- [ ] Slack channel (GW4 Isambard) + group + QR code / join link
- [ ] Confirm module names used in exercises
- [ ] Confirm project ID format shown in examples
- [ ] Confirm path for workshop materials
- [ ] Account provisioning plan (majority of registrants do not yet have access)
- [ ] Final room/helper plan for login support

## Notes

- **No JupyterHub on Isambard 3** — keep portal/JupyterHub content out of scope for this session.
- **Do not plan around persistent login sessions** — long-running work should live in Slurm jobs, not on login nodes.
- **Audience skews intermediate** — keep the core route beginner-safe, but preserve stretch goals.
- **Debugging is high demand** — this is why it has a dedicated section and should not be squeezed.
- **System architecture is also high demand** — include it, but keep it lightweight and relevant.
- **Biomedical sciences are well represented** — use examples like image processing, parameter sweeps, and many-small-job workflows where useful.
- **Fallback for anyone who cannot log in:** follow along on the projector.
- **Slack is for workshop continuity; official BriCS support is via helpdesk.**

## Out of Scope for this workshop

These may be mentioned briefly, but are not teaching goals for this session:

- deep container workflows
- bespoke package compilation/debugging for attendees' own research stacks
- interactive notebooks / JupyterHub workflows
- advanced multi-node MPI implementation details
- long discussion of architecture-specific optimisation

## Instructor Guidance

When in doubt, optimise for momentum.

- If many people are behind, keep the room together and trim optional depth.
- If the room is moving fast, use stretch goals rather than introducing new topics.
- If someone's personal environment issue becomes bespoke, stop early and redirect to docs/support after the session.
- The workshop should leave attendees feeling they can log in, submit jobs, inspect results, fix common failures, and know where to go next.
