# Isambard 3 Practical Workshop

- **Date:** Tuesday 21 April 2026, 10:00am–12:30pm
- **Location:** Artificial Intelligence (AI) Arena, SWIoT, Exeter
- **Capacity:** 40 attendees
- **Audience:** New, beginner, and intermediate HPC users wanting practical guidance on GW4 Isambard 3

This workshop follows the HPC Showcase on 20 April.

## Purpose of this document

This README is a planning blueprint for developing the workshop materials, slides, exercises, and communications.

Core design principles:

- Keep the core path accessible to genuine beginners.
- Preserve stretch goals for faster and more experienced attendees.
- Prioritise login, first-job workflows, parallelism patterns for serial work, debugging, and practical software setup
  over broad coverage.
- Avoid going deep on participants’ own custom software stacks during the session.
- Treat anything outside the prepared exercises as follow-up support rather than in-room troubleshooting.
- Unify novice and advanced material within each section rather than running two tracks. Put the simpler content first
  and let later parts go deeper; novices focus on the earlier parts while faster attendees stretch into the rest. Avoid
  explicit two-track splits that would fragment the room.
- Active sections follow this four-step rhythm: (1) **Present** — brief framing of the topic; (2) **Demo** — presenter
  demonstrates the workflow live, if applicable; (3) **Hands-on** — all participants try it themselves while helpers
  circulate and answer questions; (4) **Discussion** — open questions from participants (invite others to answer first),
  comments, anything interesting to share, and a brief conclusion if needed. Skip this rhythm only for sections that are
  obviously not suited to interactive work (passive sections).

## Section types

Sections are classified as one of two kinds:

- **Passive** — presenter-led, no dedicated hands-on try-time. Appropriate for introductions, overviews, and closing
  wrap-ups.
- **Active** — follows the four-step Present → Demo → Hands-on → Discussion rhythm. Most hands-on sections are active.

## Registration snapshot (as of 2026-04-14)

- **21 of 40** registered, one week before the workshop.
- **Experience mix:** 3 completely new, 7 beginner, 7 intermediate, 4 advanced. Split roughly 10 novice / 11 confident —
  the “novice-leaning” framing is real but the advanced contingent is non-trivial.
- **Domains:** life and biomedical sciences are well represented (≈8 of 21, including Clinical & Biomedical Sciences,
  DCBS, Biosciences, Health and Life Sciences). Also Water Systems, Engineering, Computer Science, RSA / Research IT /
  Research Software, Mathematics and Statistics, Business Economics, and EI CDT.
- **Learning goals (ranked by share of registrants):** system architecture 21/21 (100%), job submission 16/21 (76%),
  login / access 14/21 (67%), using the portal 12/21 (57%), debugging jobs 11/21 (52%).
- **Accessibility requests:** none flagged.

Named signals worth baking into delivery:

- A DCBS attendee (multiplex imaging, 130 cases) is a textbook parameter-sweep / many-independent-tasks case; use this
  framing in Section 5 where it helps.
- An intermediate attendee explicitly asked whether VS Code can be used — the VS Code browser-tunnel answer belongs in
  the pre-workshop email and in Section 1 / Section 2 signposting, not discovered live.

## Pre-workshop setup (settled)

The access gap between registration and a working login is a known constraint. The plan below is what we can do within
it. **Do not re-raise this as an open planning concern.**

- The workshop project is being created by organisers; invitations go out to registered attendees shortly. Account
  provisioning is not a planning concern.
- The [Pre-Workshop Email](#pre-workshop-email) is sent on the Tuesday or Wednesday one week before the workshop (the
  earliest the organisers can send it). It links the minimal setup steps we expect every attendee to complete.
- Doors open at **09:30** for tea, coffee, and optional account-setup support. A single on-screen slide shows the setup
  steps so attendees can self-serve while helpers circulate. Workshop teaching starts at 10:00.
- The 09:30–10:00 window is a buffer, not a dedicated setup session. It is functionally the same process as the
  pre-workshop email steps — the only difference is that helpers are present in the room. Attendees who have already
  completed setup do not need to arrive before 10:00. Attendees who have not should come from 09:30. The pre-workshop
  email makes this explicit and asks attendees to reply early if the project invitation has not arrived.

## Schedule

| \#  | Section                                                    | Type    | Duration | Time        |
|-----|------------------------------------------------------------|---------|----------|-------------|
| –   | Doors open: tea, coffee, optional account-setup support    | –       | 30 min   | 09:30–10:00 |
| 1   | BriCS Intro (by BriCS) + Welcome + Login + System Overview | Passive | 30 min   | 10:00–10:30 |
| 2   | Login Checkpoint + First Commands                          | Active  | 10 min   | 10:30–10:40 |
| 3   | First Batch Job (Slurm)                                    | Active  | 25 min   | 10:40–11:05 |
|     | Break                                                      | –       | 10 min   | 11:05–11:15 |
| 4   | Installing Software                                        | Active  | 15 min   | 11:15–11:30 |
| 5   | Python Example + Array Jobs + Parallelism Strategies       | Active  | 25 min   | 11:30–11:55 |
| 6   | Debugging Failed Jobs                                      | Active  | 20 min   | 11:55–12:15 |
| 7   | Tips, Help, Wrap-Up, Q&A & Feedback                        | Passive | 15 min   | 12:15–12:30 |

## Section Details

### 1. BriCS Intro + Welcome + Login + System Overview (30 min) — Passive

The section opens with a 10-minute introduction to BriCS/Isambard 3 delivered by BriCS staff. Login and the system
overview then run in parallel: attendees begin the Clifton login process (`clifton auth`, then `ssh`) while the
presenter gives a lightweight system overview and helpers circulate.

**Planning assumption: attendees follow the minimal setup steps in the [Pre-Workshop Email](#pre-workshop-email) before
arrival** — initial setup, Clifton/SSH, and the VS Code CLI. The 09:30 doors-open window (see [Pre-workshop setup
(settled)](#pre-workshop-setup-settled)) is a buffer for final setup, not a dedicated setup session.

Default editor path for the workshop: use VS Code via the browser-based tunnel workflow described in the BriCS
documentation. Treat this as the standard taught route so participants are all following the same setup unless they
deliberately choose an alternative editor.

Keep the system overview deliberately light and focused on what attendees need immediately: what Isambard 3 is, where it
sits in the UK HPC landscape, Grace CPU nodes / Arm/aarch64 at a high level, Slurm as the scheduler, and the main
storage areas they will use in the workshop.

Do **not** spend long here on architecture-specific software discussion. Keep that for the software section when it is
directly relevant.

**Compiler guidance (for the Grace CPU Superchip slide deck and any compiler discussion):** The correct flag for
targeting the Grace CPU is `-mcpu=neoverse-v2`, not `-march` (which is an x86 convention). This matches the [official
Isambard 3 modules documentation](https://docs.isambard.ac.uk/user-documentation/guides/modules/). The recommended and
only taught compiler is **GNU** (`PrgEnv-gnu` / `gcc-native`). Do **not** recommend the NVIDIA compiler (NVHPC / `nvc`):
in practice it causes compilation errors for many workloads, does not offer a meaningful performance advantage, and is
not the happy path for workshop attendees. LLVM/Clang and other compilers are not called out in the official docs and
should not be mentioned in the taught path.

Slides should stay low-demand: large diagrams, minimal text, clear signposting.

Keep a passive follow-along contingency in reserve for the rare attendee who still has an access problem on the day
despite completing pre-event setup, but treat this as an edge case.

TODOs:

- [x] Create presenter-facing system overview notes covering what Isambard 3 is, Arm/aarch64, CPU-only positioning,
  Slurm, and storage areas in
  [src/section_01_welcome_login_overview/01-system-overview.markdown](src/section_01_welcome_login_overview/01-system-overview.markdown)
- [x] Create a short attendee storage exercise in
  [src/section_01_welcome_login_overview/02-storage-worksheet.md](src/section_01_welcome_login_overview/02-storage-worksheet.md)
- [x] Add a section README in
  [src/section_01_welcome_login_overview/README.md](src/section_01_welcome_login_overview/README.md)
- [ ] Coordinate with BriCS staff on the 10-minute Introduction to BriCS/Isambard 3 (content, speaker, slides)
- [ ] Turn the overview notes into actual slide deck content
- [x] Add exact presenter wording for the Clifton login start and helper choreography
- [x] Add the VS Code browser-tunnel signposting that will be said live in the room
- [x] Document the passive follow-along contingency for the rare attendee with an access problem on the day
- [x] Create the single arrival/setup instructions slide (displayed on screen 09:30–10:00, covering the minimal setup
  steps from the pre-workshop email)
- [ ] Find and embed an NVIDIA Grace CPU image on a single CPU-architecture slide (one slide, within the system
  overview)
- [x] Add a single portal slide covering the portal’s purpose (project dashboard, usage and NHR per project) — attendees
  have already seen it in pre-workshop setup Step 1, so the slide is a recap rather than new material

### 2. Login Checkpoint + First Commands (10 min) — Active

Quick checkpoint that everyone is in. Helpers mop up stragglers.

This section should be a short guided orientation around shell basics, the main storage variables, and the idea that
modules are part of the normal workflow on Isambard 3.

Key teaching point here is not just naming directories, but *what goes where*: `$HOME` for config, scripts, and small
outputs, `$PROJECTDIR` for shared project material, and `$SCRATCHDIR` for working data and temporary job data.

Also remind attendees that storage is working storage, not archival, scratch is temporary, and filling `$HOME` can cause
avoidable problems.

Do **not** spend workshop time on the portal beyond whatever is strictly necessary for account setup before the event.
For many attendees it will add little value because they may not yet have a project, and even those who do are likely to
have only one.

Include a short signpost that the workshop editing workflow will follow the BriCS VS Code tunnel guide. Participants who
prefer another editor, including desktop VS Code, can use it instead but should bring it set up in advance.

TODOs:

- [x] Create the section 2 slide deck covering login checkpoint, storage orientation (`$HOME`/`$PROJECTDIR`/
  `$SCRATCHDIR`), modules preview, a consolidated “try these now” commands slide, and a Q&A slide in
  [src/section_02_login_checkpoint_first_commands/01-login-first-commands.markdown](src/section_02_login_checkpoint_first_commands/01-login-first-commands.markdown)
- [x] Add a section README in
  [src/section_02_login_checkpoint_first_commands/README.md](src/section_02_login_checkpoint_first_commands/README.md)
- [ ] Add exact live-teaching prompts for the login checkpoint and helper mop-up (speaker notes on slide 1)
- [ ] Tighten the spoken VS Code tunnel signpost on slide 1 for attendees following the browser-based editor path

### 3. First Batch Job — Slurm (25 min) — Active

This section should give attendees two quick wins: a first successful batch submission, then a small extension to
multiple tasks. The teaching emphasis is the submit-check-read-output loop, not Slurm feature breadth.

The beginner path should stay narrow: submit with `sbatch`, monitor with `squeue --me`, inspect output files, use
`scancel` when needed, then compare that with a simple multi-task `srun` example and a first look at `sacct`.

Stretch goals for fast finishers can include changing walltime, changing the job name or output filename, changing
`--ntasks`, and adding a small `sleep` so they can observe queue and running states more clearly.

Do **not** include partition changes in the beginner path.

Do **not** include `--mail-type=END` as a stretch goal.

TODOs:

- [x] Create a hello-world walkthrough in
  [src/section_03_first_batch_job_slurm/ex01_hello_world/01-hello-world.md](src/section_03_first_batch_job_slurm/ex01_hello_world/01-hello-world.md)
- [x] Create a starter batch script in
  [src/section_03_first_batch_job_slurm/ex01_hello_world/sbatch_hello_world.sh](src/section_03_first_batch_job_slurm/ex01_hello_world/sbatch_hello_world.sh)
- [x] Create a multi-task walkthrough in
  [src/section_03_first_batch_job_slurm/ex02_multi_task/02-multi-task.md](src/section_03_first_batch_job_slurm/ex02_multi_task/02-multi-task.md)
- [x] Create a multi-task `srun` example in
  [src/section_03_first_batch_job_slurm/ex02_multi_task/sbatch_multi_task.sh](src/section_03_first_batch_job_slurm/ex02_multi_task/sbatch_multi_task.sh)
- [x] Add a section README in
  [src/section_03_first_batch_job_slurm/README.md](src/section_03_first_batch_job_slurm/README.md)
- [ ] Add presenter notes for walking through the first script line by line
- [ ] Confirm whether the example output filenames and shell choices match local workshop conventions
- [x] Add explicit fast-finisher prompts for walltime, job naming, output naming, and `sleep`
- [x] Keep the beginner path free of partition changes and `--mail-type=END`
- [x] Simple single core job: env, date, free, lscpu, etc. (folded into `sbatch_hello_world.sh`)
- [x] Interactive job: try a few commands (`ex03_interactive/03-interactive.md` — stretch)
- [x] Simple single node 1 minute wall clock time (no mpi yet): simple c program with matmul and timing and show flops
  (`ex04_matmul/04-matmul.md` — stretch; strong/weak scaling deferred to later in the workshop)
- [x] Section 3 slide deck in
  [src/section_03_first_batch_job_slurm/first_batch_job_slurm.markdown](src/section_03_first_batch_job_slurm/first_batch_job_slurm.markdown)

### 4. Installing Software (15 min) — Active

Keep this section tightly scoped.

The core story is simple: try modules first, then use a prepared user-managed environment route if needed, and avoid
turning the workshop into open-ended custom environment debugging.

This section should help attendees understand the decision order without trying to teach every possible tool. If a
participant’s own stack does not fit the prepared path, point them to support and follow-up documentation after the
workshop.

Containers should only be mentioned briefly as a follow-up route and should not be taught hands-on in this session.

Keep VS Code and other remote-development tooling out of the taught path for this section. If raised in Q&A, answer
briefly and move on.

TODOs:

- [x] Create the section 4 slide deck in
  [src/section_04_installing_software/installing_software.markdown](src/section_04_installing_software/installing_software.markdown)
  covering software landscape, modules commands, conda vocabulary, hands-on environment creation, Pixi/direnv context,
  and other routes (Spack, containers) as follow-up only
- [x] Add conda environment files for the taught path (in `bootstrap/conda/`, e.g. `py314_linux-aarch64.yml`)
- [x] Confirm the preferred conda/mamba initialisation method for interactive and batch use on Isambard 3 (bootstrap
  scripts via miniforge; taught in slides)
- [x] Decide whether the root `pyproject.toml` Pixi workflow and editable `src/` package route should be mentioned in
  the taught path or left out to keep the section tighter (decided: brief context slide only, not core path)
- [x] Add the exact support/docs signposting for cases where attendee environments become bespoke (“Other routes” slide
  with docs links and explicit helper-redirect wording)
- [x] Keep containers as follow-up only and out of the core hands-on path
- [x] Confirm the module demo example (`module load brics/emacs`) is a real, loadable module on Isambard 3

### 5. Python Example + Array Jobs + Parallelism Strategies (25 min) — Active

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

| Approach | How | Good for | Watch out |
|----|----|----|----|
| GNU Parallel (single node) | One-node launcher pattern | Hundreds of short tasks on one node | Bound to one node; confirm module availability in prep |
| Slurm job arrays | `--array=1-N` | Moderate independent tasks | Large arrays can place extra strain on the scheduler; use throttling |
| MPI parallelism | `mpi4py` / compiled MPI | Multi-node communicating tasks | Requires MPI-aware code |

This part should remain comparative and practical rather than deep.

### 6. Debugging Failed Jobs (20 min) — Active

This should stay hands-on and explicitly problem-solving focused.

#### Broken scripts exercise (~12 min)

Prepared broken examples:

1.  Wrong module name → inspect `.err`
2.  Walltime too short → inspect `sacct`, see `TIMEOUT`
3.  Write to non-existent directory → inspect exit code / error output

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

### 7. Tips, Help, Wrap-Up, Q&A & Feedback (15 min) — Passive

Use this as a flexible closing block.

Suggested contents:

- file transfer one-liners: `scp`, `rsync`
- where to look next in the docs
- support route
- feedback QR code
- open Q&A

Important distinction to make clear:

- workshop questions after the session can be redirected to the relevant docs/help route
- official BriCS support issues should go through the helpdesk

## Pre-Workshop Email

Sent on the Tuesday or Wednesday one week before the workshop (the earliest the organisers can send it).

**Minimal setup we expect every participant to complete before arrival:**

1.  Follow the initial setup tutorial: <https://docs.isambard.ac.uk/user-documentation/tutorials/setup/>
2.  Set up Clifton for SSH access: <https://docs.isambard.ac.uk/user-documentation/guides/login/>
3.  Install the VS Code CLI and launch VS Code in the browser — just the “Install VS Code CLI” subsection:
    <https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli>

Advanced users are welcome to bootstrap their own environment and text editor (desktop VS Code, vim, etc.) before the
workshop instead of the browser-based VS Code path.

In addition, ask attendees to:

- bring a laptop that can open a terminal and a web browser
- arrive from 09:30 for tea, coffee, and optional account-setup support — workshop teaching starts at 10:00
- reply to the pre-workshop email ahead of time if the project invitation has not arrived or anything else has gone
  wrong, so organisers can help before the day

## Workshop Material Design Notes

### Prepared materials to create

- slide deck
- onboarding/run-of-show notes for presenter and helpers
- arrival / minimal-setup slide for 09:30–10:00
- single CPU-architecture slide (NVIDIA Grace image)
- single portal slide
- first Slurm job script
- multi-task Slurm job script
- Monte Carlo Pi Python script
- array job variant
- three broken debugging scripts
- software setup mini-walkthrough
- file transfer slide
- wrap-up slide with links and QR codes

## TODOs

- [x] Pre-workshop email draft
- [ ] Slide deck outline
- [ ] Broken job scripts for debugging exercise (3 scripts)
- [x] First Slurm job script
- [x] Multi-task Slurm job script
- [x] Monte Carlo Pi Python script
- [ ] Array job version of the Python example
- [ ] GNU Parallel example or confirm whether to keep it conceptual only
- [ ] Stretch goals for each hands-on section
- [ ] Confirm module names used in exercises
- [ ] Confirm project ID format shown in examples
- [ ] Confirm path for workshop materials
- [x] Confirm workshop account provisioning timeline with BriCS (project being created; invitations going out to
  registered attendees shortly)
- [ ] Set up a project on the portal for the workshop
- [ ] Put a reservation in place on Isambard 3 for the workshop duration
- [ ] Confirm if there are any remote participants
- [ ] Final room/helper plan for login support
- [ ] Follow the whole workshop end-to-end with an empty user directory from scratch

## Notes

- **No JupyterHub on Isambard 3** — keep portal/JupyterHub content out of scope for this session.
- **Do not plan around persistent login sessions** — long-running work should live in Slurm jobs, not on login nodes.
- **Audience is mixed but novice-leaning** — keep the core route beginner-safe, but preserve stretch goals.
- **Debugging is high demand** — this is why it has a dedicated section and should not be squeezed.
- **System architecture is also high demand** — include it, but keep it lightweight and relevant.
- **Biomedical sciences are well represented** — use examples like image processing, parameter sweeps, and
  many-small-job workflows where useful.
- **Fallback for anyone who cannot log in:** follow along on the projector. Setup is required before the event, so this
  should be rare.

## Out of Scope for this workshop

These may be mentioned briefly, but are not teaching goals for this session:

- deep container workflows
- bespoke package compilation/debugging for attendees’ own research stacks
- interactive notebooks / JupyterHub workflows
- advanced multi-node MPI implementation details
- long discussion of architecture-specific optimisation
- extended portal walkthroughs — the portal only shows project membership and account balance, so it gets a single slide
  rather than teaching time

## Instructor Guidance

When in doubt, optimise for momentum.

- If many people are behind, keep the room together and trim optional depth.
- If the room is moving fast, use stretch goals rather than introducing new topics.
- If someone’s personal environment issue becomes bespoke, stop early and redirect to docs/support after the session.
- The workshop should leave attendees feeling they can log in, submit jobs, inspect results, fix common failures, and
  know where to go next.
