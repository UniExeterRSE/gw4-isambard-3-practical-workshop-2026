# Section 3: First Batch Job with Slurm

**Section type: Active.** Rhythm: Present → Demo (walk through the script live) → Hands-on → Discussion.

25 minutes. Core taught path is `01` + `02`. `03` and `04` are stretch / fast-finisher material — bring them in only if
the room is moving fast, or skip and signpost as post-workshop reading.

**Core path (taught):**

- `ex01_hello_world/01-hello-world.md` + `ex01_hello_world/hello_world.sh` — first `sbatch` / `squeue --me` / read
  output / `scancel`. The script also dumps `hostname`, `date`, `free -h`, `lscpu`, and the `SLURM_*` env, so one
  submission also tells attendees what a compute node looks like.
- `ex02_multi_task/02-multi-task.md` + `ex02_multi_task/multi_task.sh` — extend to `--ntasks=4` with `srun`; first look
  at `sacct`.

**Stretch:**

- `ex03_interactive/03-interactive.md` — starting an interactive session with `srun --pty bash` when batch feels too
  slow for a quick check.
- `ex04_matmul/04-matmul.md` + `ex04_matmul/matmul.c` + `ex04_matmul/makefile` + `ex04_matmul/make.sh` — compile a tiny
  BLAS matmul via the Cray `cc` wrapper under `PrgEnv-gnu` and run it under Slurm. Framed as “run something non-trivial
  end-to-end”; the GFLOPS number exists but we do not dissect it here. Revisited later if there is time.

All examples here are CPU-only and suitable for Isambard 3.
