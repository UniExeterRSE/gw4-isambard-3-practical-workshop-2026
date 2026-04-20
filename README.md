# Isambard 3 Practical Workshop

A 2.5-hour hands-on workshop on GW4 Isambard 3 covering logging in, submitting batch jobs, installing software,
parallelising Python workflows, and debugging failed jobs.

- **Date:** Tuesday 21 April 2026, 10:00am–12:30pm
- **Location:** Artificial Intelligence (AI) Arena, SWIoT, Exeter
- **Audience:** New, beginner, and intermediate HPC users

This workshop follows the HPC Showcase on 20 April. See [MAINTAINER.md](MAINTAINER.md) for presenter and maintainer
notes.

## Schedule

| \#  | Section                                                    | Type    | Duration | Time        |
|-----|------------------------------------------------------------|---------|----------|-------------|
| –   | Doors open: tea, coffee, optional account-setup support    | –       | 30 min   | 09:30–10:00 |
| 1   | BriCS Intro (by BriCS) + Welcome + Login + System Overview | Passive | 15 min   | 10:00–10:15 |
| 2   | Login Checkpoint + First Commands                          | Active  | 5 min    | 10:15–10:20 |
| 3   | First Batch Job (Slurm)                                    | Active  | 25 min   | 10:20–10:45 |
| 4   | Installing Software                                        | Active  | 30 min   | 10:45–11:15 |
|     | Break                                                      | –       | 10 min   | 11:15–11:25 |
| 5   | Python Example + Array Jobs + Parallelism Strategies       | Active  | 35 min   | 11:25–12:00 |
| 6   | Debugging Failed Jobs                                      | Active  | 15 min   | 12:00–12:15 |
| 7   | Tips, Help, Wrap-Up, Q&A & Feedback                        | Passive | 15 min   | 12:15–12:30 |

## Pre-Workshop Setup

Complete these three steps before arriving:

1.  Follow the initial setup tutorial: <https://docs.isambard.ac.uk/user-documentation/tutorials/setup/>
2.  Set up Clifton for SSH access: <https://docs.isambard.ac.uk/user-documentation/guides/login/>
3.  Install the VS Code CLI — “Install VS Code CLI” subsection only:
    <https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli>

Bring a laptop that can open a terminal and a web browser. Advanced users may use desktop VS Code, vim, or another
editor instead of the browser-based VS Code path, but should bring it set up in advance.

Doors open at **09:30** for tea, coffee, and optional account-setup support. Workshop teaching starts at **10:00**. If
you have completed setup, you do not need to arrive before 10:00; otherwise come from 09:30.

If your project invitation has not arrived, reply to the pre-workshop email ahead of time so organisers can help before
the day.

## Repository Structure

    src/
        section_01_welcome_login_overview/                      # System overview, login
        section_02_login_checkpoint_first_commands/             # First commands, storage areas
        section_03_first_batch_job_slurm/                       # Batch job exercises
        section_04_installing_software/                         # Software installation
        section_05_python_array_jobs_parallelism_strategies/    # Python, arrays, parallelism
        section_06_debugging_failed_jobs/                       # Debugging exercises (7 scenarios)
        section_07_tips/                                        # Tips and wrap-up
    bootstrap/                                                  # Software bootstrap scripts
    bin/                                                        # Repo tooling

Each section directory contains a `README.md` with presenter notes, exercise walkthroughs, example scripts, and slide
source (`*.markdown`).

## Support

- **BriCS helpdesk:** <https://support.isambard.ac.uk/>
- **UoE RSE follow-up:** `isambard-support@exeter.ac.uk`
