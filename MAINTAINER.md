# Maintainer Notes — Isambard 3 Practical Workshop

This document is for future presenters and maintainers of these workshop materials. For participant-facing information
see [README.md](README.md). For tooling and build commands see [AGENTS.md](AGENTS.md).

## Design Principles

- Keep the core path accessible to genuine beginners; preserve stretch goals for faster attendees.
- Prioritise login, first-job workflows, parallelism patterns for serial work, debugging, and practical software setup
  over broad coverage.
- Avoid going deep on participants’ own custom software stacks during the session. Treat anything outside the prepared
  exercises as follow-up support.
- Unify novice and advanced material within each section: simpler content first, later parts go deeper. Novices focus on
  the earlier parts; faster attendees stretch into the rest. Avoid explicit two-track splits that fragment the room.
- Active sections follow this four-step rhythm: (1) **Present** — brief framing; (2) **Demo** — presenter demonstrates
  live, if applicable; (3) **Hands-on** — all participants try it; (4) **Discussion** — open questions, invite others to
  answer first, brief conclusion. Skip this rhythm only for sections that are obviously passive.
- When in doubt, optimise for momentum. If many people are behind, keep the room together and trim optional depth. If
  the room is moving fast, use stretch goals rather than introducing new topics. If someone’s personal environment issue
  becomes bespoke, stop early and redirect to docs/support after the session.

## Section Types

- **Passive** — presenter-led, no dedicated hands-on try-time. Appropriate for introductions, overviews, and closing
  wrap-ups.
- **Active** — follows the four-step Present → Demo → Hands-on → Discussion rhythm.

## Audience Profile (2026 cohort)

Recorded here for calibrating future runs:

- **21 of 40** registered by one week before. Experience mix: 3 new, 7 beginner, 7 intermediate, 4 advanced. Roughly 10
  novice / 11 confident — novice-leaning but with a non-trivial advanced contingent.
- **Domains:** life and biomedical sciences well represented (≈8/21: Clinical & Biomedical Sciences, DCBS, Biosciences,
  Health and Life Sciences). Also Water Systems, Engineering, Computer Science, RSA/Research IT/Research Software,
  Mathematics and Statistics, Business Economics, EI CDT.
- **Top learning goals:** system architecture (100%), job submission (76%), login/access (67%), using the portal (57%),
  debugging jobs (52%).
- A DCBS attendee (multiplex imaging, 130 cases) is a textbook parameter-sweep / many-independent-tasks case; use this
  framing in Section 5 where it helps.
- An intermediate attendee asked explicitly whether VS Code can be used — keep the VS Code browser-tunnel answer in the
  pre-workshop email and in Sections 1 and 2, not discovered live.

## Pre-Workshop Logistics

- The access gap between registration and a working login is a known constraint. The workshop project is created by
  organisers; invitations go to registered attendees. Account provisioning is not a per-run concern.
- Send the pre-workshop email on the Tuesday or Wednesday one week before (the earliest organisers can send it).
- Doors open at **09:30** for tea, coffee, and account-setup support. A single on-screen slide shows the setup steps so
  attendees self-serve while helpers circulate. Teaching starts at **10:00**.
- The 09:30–10:00 window is a buffer, not a dedicated setup session. The only difference from the email steps is that
  helpers are present. Attendees who have completed setup need not arrive before 10:00.
- Ask attendees to reply to the pre-workshop email ahead of time if their project invitation has not arrived.

## Pre-Workshop Email Template

Sent on the Tuesday or Wednesday one week before the workshop.

------------------------------------------------------------------------------------------------------------------------

**Minimal setup we expect every participant to complete before arrival:**

1.  Follow the initial setup tutorial: <https://docs.isambard.ac.uk/user-documentation/tutorials/setup/>
2.  Set up Clifton for SSH access: <https://docs.isambard.ac.uk/user-documentation/guides/login/>
3.  Install the VS Code CLI — “Install VS Code CLI” subsection only:
    <https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli>

Advanced users are welcome to bootstrap their own environment and text editor (desktop VS Code, vim, etc.) before the
workshop instead of the browser-based VS Code path.

In addition:

- Bring a laptop that can open a terminal and a web browser.
- Arrive from 09:30 for tea, coffee, and optional account-setup support — workshop teaching starts at 10:00.
- Reply to this email ahead of time if the project invitation has not arrived or anything has gone wrong, so organisers
  can help before the day.

------------------------------------------------------------------------------------------------------------------------

## Section Notes

### Section 1 — BriCS Intro + Welcome + Login + System Overview (15 min, Passive)

Opens with a 10-minute BriCS/Isambard 3 introduction by BriCS staff, followed by a 5-minute Grace CPU Superchip overview
while attendees log in and helpers circulate.

- Default editor path: VS Code via the browser-based tunnel workflow from the BriCS documentation. Treat as the standard
  taught route unless an attendee deliberately chooses an alternative.
- Keep the system overview deliberately light: Grace CPU nodes / Arm/aarch64 at a high level, Slurm as the scheduler,
  just enough context to situate the machine before the hands-on sections. Do **not** spend time on
  architecture-specific software discussion — keep that for Section 4.
- **Compiler guidance:** The correct flag for targeting the Grace CPU is `-mcpu=neoverse-v2`, not `-march` (an x86
  convention). This matches the [official Isambard 3 modules
  documentation](https://docs.isambard.ac.uk/user-documentation/guides/modules/). The only taught compiler is **GNU**
  (`PrgEnv-gnu` / `gcc-native`). Do **not** recommend the NVIDIA compiler (NVHPC / `nvc`): causes compilation errors for
  many workloads in practice, no meaningful performance advantage, not the happy path. LLVM/Clang is not in the official
  docs and should not be mentioned.
- Slides should stay low-demand: large diagrams, minimal text, clear signposting.
- Use only a small subset of the Section 1 material live. Login issues should be resolved in parallel by participants
  and helpers; if unresolved, continue into Section 2 without holding the room.
- Keep a passive follow-along contingency in reserve for the rare attendee who still has an access problem on the day,
  but treat this as an edge case.

Key files:

- [src/section_01_welcome_login_overview/01-system-overview.markdown](src/section_01_welcome_login_overview/01-system-overview.markdown)
- [src/section_01_welcome_login_overview/02-grace-cpu-superchip.markdown](src/section_01_welcome_login_overview/02-grace-cpu-superchip.markdown)
- [src/section_01_welcome_login_overview/README.md](src/section_01_welcome_login_overview/README.md)

### Section 2 — Login Checkpoint + First Commands (5 min, Active)

Rapid checkpoint that everyone is in or has helper support already in progress. Bridge into Section 3, not a full
orientation block.

- Teaching point: not just naming directories, but *what goes where*: `$HOME` for config, scripts, and small outputs;
  `$PROJECTDIR` for shared project material; `$SCRATCHDIR` for working data and temporary job data.
- Remind attendees that storage is working storage (not archival), scratch is temporary, and filling `$HOME` causes
  avoidable problems.
- Include a short VS Code tunnel signpost. Participants who prefer another editor can use it but should have it set up.
- Do **not** spend workshop time on the portal beyond what is strictly necessary for account setup.

Key files:

- [src/section_02_login_checkpoint_first_commands/01-login-first-commands.markdown](src/section_02_login_checkpoint_first_commands/01-login-first-commands.markdown)
- [src/section_02_login_checkpoint_first_commands/README.md](src/section_02_login_checkpoint_first_commands/README.md)

### Section 3 — First Batch Job: Slurm (25 min, Active)

Two quick wins: first successful batch submission, then a small extension to multiple tasks. Teaching emphasis is the
submit–check–read-output loop, not Slurm feature breadth.

Beginner path: `sbatch` → `squeue --me` → inspect output files → `scancel` → multi-task `srun` → first look at `sacct`.

Stretch goals for fast finishers: change walltime, job name, output filename, `--ntasks`, add a `sleep` to observe queue
and running states.

Do **not** include partition changes in the beginner path. Do **not** include `--mail-type=END` as a stretch goal.

Key files:

- [src/section_03_first_batch_job_slurm/ex01_hello_world/](src/section_03_first_batch_job_slurm/ex01_hello_world/)
- [src/section_03_first_batch_job_slurm/ex02_multi_task/](src/section_03_first_batch_job_slurm/ex02_multi_task/)
- [src/section_03_first_batch_job_slurm/ex03_interactive/](src/section_03_first_batch_job_slurm/ex03_interactive/)
  (stretch)
- [src/section_03_first_batch_job_slurm/ex04_matmul/](src/section_03_first_batch_job_slurm/ex04_matmul/) (stretch)
- [src/section_03_first_batch_job_slurm/first_batch_job_slurm.markdown](src/section_03_first_batch_job_slurm/first_batch_job_slurm.markdown)
- [src/section_03_first_batch_job_slurm/README.md](src/section_03_first_batch_job_slurm/README.md)

### Section 4 — Installing Software (30 min, Active)

This is the critical completion gate for the rest of the workshop. Everyone should finish the mandatory setup path here
before the room moves on — later sections assume those stacks are already working.

Core story: try modules first, then use a prepared user-managed environment route if needed. Do not turn this into
open-ended custom environment debugging.

- Teach only the decision order, the modules preview, and the mandatory prepared user-managed environment route.
- Fork/clone choice, dotfiles, and broader tooling details: treat as presenter demo or take-home reference, not core
  in-room hands-on.
- Containers: mention briefly as a follow-up route only. Do **not** teach hands-on.
- Keep VS Code and other remote-development tooling out of the taught path. If raised in Q&A, answer briefly and move
  on.
- If a participant’s own stack does not fit the prepared path, point them to support and follow-up documentation.
- The module demo example uses `module load brics/emacs` — confirm this is still a real, loadable module before each
  run.

Key files:

- [src/section_04_installing_software/installing_software.markdown](src/section_04_installing_software/installing_software.markdown)
- [src/section_04_installing_software/MAINTAINER.md](src/section_04_installing_software/MAINTAINER.md)
- [bootstrap/conda/](bootstrap/conda/) — conda environment files for the taught path

### Section 5 — Python Example + Array Jobs + Parallelism Strategies (35 min, Active)

Main conceptual block after software setup.

**Part A — Single job (~8 min):** Use `ex01_monte_carlo_pi/` with `sbatch_monte_carlo_pi_single.sh`. Goals: load the
right software path, submit a realistic Python job, inspect the timing table, confirm attendees can run repo-native
Python material on Isambard 3.

**Part B — Hybrid MPI demo (~10 min):** Demo the hybrid MPI case live to establish the process/thread hierarchy and the
distinction between shared-memory and distributed-memory parallelism. Presenter-led concept demo — not a requirement
that every attendee runs the full sweep in-room.

**Part C — Pipeline patterns (~17 min):** Use `ex03_job_array/` and `ex04_gnu_parallel/` to show the map → run → reduce
pattern for many independent tasks. The DCBS multiplex-imaging framing (130 independent cases) works well here. Keep
`mpi4py.futures`, multiprocessing, and compiled C/OpenMP material comparative or take-home unless the room is moving
unusually fast.

Key files:

- [src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/](src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/)
- [src/section_05_python_array_jobs_parallelism_strategies/ex03_job_array/](src/section_05_python_array_jobs_parallelism_strategies/ex03_job_array/)
- [src/section_05_python_array_jobs_parallelism_strategies/ex04_gnu_parallel/](src/section_05_python_array_jobs_parallelism_strategies/ex04_gnu_parallel/)
- [src/section_05_python_array_jobs_parallelism_strategies/README.md](src/section_05_python_array_jobs_parallelism_strategies/README.md)

### Section 6 — Debugging Failed Jobs (15 min, Active)

Intentionally an exercise buffet, not a complete walkthrough. Introduce the debugging flow, point attendees at the menu,
let them start one exercise, and explicitly invite them to continue after the workshop.

The workshop project expires the day after the workshop — use the remaining access time to encourage attendees to return
to unfinished exercises once the formal session ends.

**Broken scripts exercise (~7 min in-room, continue after):**

Seven distinct failure modes — participants self-select the one closest to their own likely failure mode, diagnose, fix,
and resubmit. Finishing the whole set is **not** the goal during the live session.

1.  Oversubscription (`ex01_oversubscription/`)
2.  Missing `PrgEnv-gnu` (`ex02_wrong_env_module/`)
3.  Pixi environment missing on the compute node (`ex03_wrong_env_pixi_missing/`)
4.  Wrong pixi environment for MPI (`ex04_wrong_env_pixi_wrong/`)
5.  Out-of-memory failure (`ex05_oom_matmul/`)
6.  Uneven MPI topology across nodes (`ex06_mpi_topology/`)
7.  Race condition / wrong answers (`ex07_race_condition/`)

**Debugging flowchart (~8 min):** Walk through:

- `squeue` states: `PD`, `R`, `CG`; `squeue --start`
- `sacct --format=JobID,State,ExitCode,MaxRSS`
- `.out` and `.err` first; module/path errors; time limit exceeded; memory issues; wrong path / missing directory
- Etiquette: do not aggressively poll `squeue`/`sinfo`; avoid `watch`-style hammering of scheduler commands

Key files:

- [src/section_06_debugging_failed_jobs/](src/section_06_debugging_failed_jobs/)

### Section 7 — Tips, Help, Wrap-Up, Q&A & Feedback (15 min, Passive)

Flexible closing block. Contents:

- Slurm tips: separating stdout/stderr, checking CPU usage with `sacct`, useful directives to look up
- Slurm cheatsheet: `sinfo`, `scontrol`, `sacctmgr`, `squeue`, `sacct`
- File transfer one-liners: `scp`, `rsync`
- Troubleshooting: terminal emulator compatibility
- Where to look next in the docs
- Support routes: BriCS helpdesk and UoE RSE follow-up
- Feedback: announce survey will be sent by email after the workshop (no QR code)
- Open Q&A

Make the distinction clear: workshop questions after the session go to the docs/help route; official BriCS support
issues go through the helpdesk.

Key files:

- [src/section_07_tips/README.md](src/section_07_tips/README.md)

## Scope Boundaries

These topics may be mentioned briefly but are not teaching goals:

- Deep container workflows
- Bespoke package compilation/debugging for attendees’ own research stacks
- Interactive notebooks / JupyterHub workflows (no JupyterHub on Isambard 3)
- Advanced multi-node MPI implementation details
- Long discussion of architecture-specific optimisation
- Extended portal walkthroughs — the portal only shows project membership and account balance; it gets a single slide,
  not teaching time

Do not plan around persistent login sessions — long-running work should live in Slurm jobs, not on login nodes.

## Workshop Identifiers

These live-system values appear throughout scripts and slides — confirm they are still correct before each run:

- Project: `exeter-workshop-260421`
- Account: `e6c`
- QOS: `brics.e6c_qos`

## Materials Inventory

| Item | Location |
|----|----|
| Section slide decks | `src/section_NN_*/` (`*.markdown` → compiled to `*.html`) |
| Presenter/helper run-of-show notes | each section `README.md` |
| Arrival / minimal-setup slide | `src/section_01_welcome_login_overview/` |
| NVIDIA Grace CPU imagery | `src/media/NVidia/Grace-CPU-Superchip/` |
| First Slurm job script | `src/section_03_first_batch_job_slurm/ex01_hello_world/` |
| Multi-task Slurm job script | `src/section_03_first_batch_job_slurm/ex02_multi_task/` |
| Monte Carlo Pi Python script | `src/section_05_python_array_jobs_parallelism_strategies/ex01_monte_carlo_pi/` |
| Array job variant (`--save` + `reduce_results.py`) | `src/section_05_python_array_jobs_parallelism_strategies/ex03_job_array/` |
| GNU Parallel example (`generate_tasks.py` + batch script) | `src/section_05_python_array_jobs_parallelism_strategies/ex04_gnu_parallel/` |
| Debugging exercise suite (7 scenarios) | `src/section_06_debugging_failed_jobs/` |
| Conda environment files | `bootstrap/conda/` |
| Repo tooling | `bin/` |

## Build and Formatting

See [AGENTS.md](AGENTS.md) for all tooling details. Key commands:

- `pixi run format` — run all formatters (required before committing; CI enforces idempotency via
  `git diff --exit-code`)
- `pixi run docs` — build reveal.js HTML slides
- `pixi run serve` — build then serve on `http://127.0.0.1:8001`
- `pixi run sync` — sync paired `*.ipynb` / `*.py` files via jupytext
