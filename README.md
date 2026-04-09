# Isambard 3 Practical Workshop

- **Date:** Tuesday 21 April 2026, 10:00am–12:30pm
- **Location:** Artificial Intelligence (AI) Arena, SWIoT, Exeter
- **Capacity:** 40 attendees
- **Audience:** New and intermediate HPC users wanting practical guidance on GW4 Isambard 3

This workshop follows the HPC Showcase on 20 April.

## Schedule

| #   | Section                                                  | Duration | Time        |
| --- | -------------------------------------------------------- | -------- | ----------- |
| 1   | Welcome + Start Login + System Architecture (overlapped) | 25 min   | 10:00–10:25 |
| 2   | Login Checkpoint + First Commands                        | 10 min   | 10:25–10:35 |
| 3   | First Batch Job (Slurm)                                  | 25 min   | 10:35–11:00 |
| 4   | Break                                                    | 15 min   | 11:00–11:15 |
| 5   | Installing Software                                      | 15 min   | 11:15–11:30 |
| 6   | Python Example + Array Jobs + Parallelism Strategies     | 25 min   | 11:30–11:55 |
| 7   | Debugging Failed Jobs                                    | 15 min   | 11:55–12:10 |
| 8   | Tips & Tricks                                            | 10 min   | 12:10–12:20 |
| 9   | Wrap-Up, Q&A & Feedback                                  | 10 min   | 12:20–12:30 |

## Section Details

### 1. Welcome + Start Login + System Architecture (25 min)

Login and the architecture talk run in parallel: attendees start the Clifton
login process (install, `clifton auth`, `ssh`) then the presenter pivots to the
system overview while helpers circulate to assist. This absorbs login friction
into passive listening time and means latecomers can catch up without missing
hands-on content.

Architecture overview covers: 384 Grace CPU Superchip nodes (Arm/aarch64),
storage tiers (home/scratch), Slurm scheduler, where Isambard 3 sits in the
UK HPC landscape. Keep slides low-demand (big diagrams, few words) since some
attendees' attention will be split.

### 2. Login Checkpoint + First Commands (10 min)

Quick check everyone is logged in, helpers mop up stragglers. Then guided
exploration: `whoami`, `hostname`, `module avail | head`, directory structure
(home vs. project vs. scratch).

### 3. First Batch Job — Slurm (25 min)

Two iterations:

1. **Hello World** — walk through a job script line by line,
   submit with `sbatch`, monitor with `squeue -u $USER`, read the output file.
   Show `scancel`.
2. **Multi-task** — modify to `--ntasks=4`, add `srun`, re-submit, compare
   output. Introduce `sacct` for job history.

Stretch goals for fast finishers: change partition, walltime, number of nodes,
add `--mail-type=END`.

### 4. Break (15 min)

### 5. Installing Software (15 min)

- **Modules**: `module spider`, `module load`, `module list` — the first thing
  to try.
- **conda/mamba/pixi**: creating a conda env on scratch.
- **Arm (aarch64) gotchas**: not every packages has an Arm build; what to do
  when it fails.
- **Containers**: brief mention of Podman-HPC / Singularity as an escape hatch
  — plant the idea, don't go deep.

### 6. Python Example + Array Jobs + Parallelism Strategies (25 min)

**Part A — Single job (~8 min):** Pre-written Monte Carlo Pi script from
`/projects/workshop/`. Write a job script that loads a Python module and runs
it. Submit and check results.

**Part B — Array jobs (~7 min):** Add `--array=1-10`, script reads
`$SLURM_ARRAY_TASK_ID` as the seed. Submit, watch fan-out, check per-task
output files.

**Part C — "Three ways to run many serial jobs" (~10 min):** Compare:

| Approach                   | How                     | Good for                        | Watch out                                    |
| -------------------------- | ----------------------- | ------------------------------- | -------------------------------------------- |
| GNU Parallel (single node) | `module load parallel`  | Hundreds of short tasks         | Bound to 1 node                              |
| Slurm job arrays           | `--array=1-N`           | Moderate independent tasks      | Floods scheduler if N large; use `%throttle` |
| MPI parallelism            | `mpi4py` / compiled MPI | Multi-node, communicating tasks | Requires MPI-aware code                      |

### 7. Debugging Failed Jobs (15 min)

**Hands-on (10 min):** Pre-written broken job scripts:

1. Wrong module name → check `.err` file
2. Walltime too short → `sacct` shows `TIMEOUT`
3. Write to non-existent directory → non-zero exit code

Users submit, diagnose, fix, and resubmit.

**Debugging flowchart (5 min):** `squeue` states (PD, R, CG),
`squeue --start`, `sacct --format=JobID,State,ExitCode,MaxRSS`. Common failure
modes: walltime exceeded, OOM, module/path not found. This flowchart goes on
the cheat sheet.

### 8. Tips & Tricks (10 min)

- **File transfer**: `scp`/`rsync` one-liners
- **Getting help**: docs site, support tickets, Slack

### 9. Wrap-Up, Q&A & Feedback (10 min)

Recap, "where to go next" slide with links, open Q&A, feedback form QR code.

## Pre-Workshop Email

Send ~1 week before. Ask attendees to:

- Set their UNIX short name via the portal
- Check they have an SSH key pair (or generate one)
- Optionally install Clifton ahead of time

## TODOs

- [ ] Pre-workshop email draft
- [ ] Broken job scripts for debugging exercise (3 scripts)
- [ ] GNU Parallel example job script
- [ ] Monte Carlo Pi Python script
- [ ] Stretch goals for each hands-on section
- [ ] Slack channel + QR code / join link
- [ ] Prepare all materials
- [ ] Confirm partition names, module names, project ID format
- [ ] Account provisioning plan (majority of registrants don't have access yet)

## Notes

- **No JupyterHub** on Isambard 3 (only Isambard AI) — portal section was cut.
- **No tmux/screen** — persistent sessions on login nodes are against Isambard 3 security policy; login nodes are randomly assigned so reconnection isn't possible anyway.
- **Audience skews intermediate** (early registration data: 4 intermediate, 3 beginner, 2 advanced, 1 completely new out of 10). Keep core path accessible but include stretch goals for faster participants.
- **Debugging** was requested by 6/10 early registrants — hence its own dedicated section.
- **System architecture** was requested by 10/10 — enriched with Arm context and clear diagrams.
- **Biomedical sciences** well represented (4/10 from CBS) — mention image processing and parameter sweeps as example use cases where relevant.
- Fallback for anyone who can't log in: follow along on the projector.
- Slack for live Q&A and post-workshop follow-up.
