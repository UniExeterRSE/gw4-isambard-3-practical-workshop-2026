# Section 3: First Batch Job with Slurm

**Section type: Active.** Rhythm: Present → Demo (walk through the script live) → Hands-on → Discussion.

25 minutes. Core taught path is `01` + `02`. `03` and `04` are stretch / fast-finisher material — bring them in only if
the room is moving fast, or skip and signpost as post-workshop reading.

**Core path (taught):**

- `01-hello-world.md` + `hello_world.sh` — first `sbatch` / `squeue --me` / read output / `scancel`. The script also
  dumps `hostname`, `date`, `free -h`, `lscpu`, and the `SLURM_*` env, so one submission also tells attendees what a
  compute node looks like.
- `02-multi-task.md` + `multi_task.sh` — extend to `--ntasks=4` with `srun`; first look at `sacct`.

**Stretch:**

- `03-interactive.md` — starting an interactive session with `srun --pty bash` when batch feels too slow for a quick
  check.
- `04-matmul.md` + `matmul.c` + `makefile` + `matmul.sh` — compile a tiny BLAS matmul via the Cray `cc` wrapper under
  `PrgEnv-gnu` and run it under Slurm. Framed as “run something non-trivial end-to-end”; the GFLOPS number exists but we
  do not dissect it here. Revisited later if there is time.

All examples here are CPU-only and suitable for Isambard 3.
