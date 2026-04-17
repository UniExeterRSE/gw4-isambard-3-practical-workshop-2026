# Section 3: First Batch Job with Slurm

**Section type: Active.** Rhythm: Present → Demo (walk through the script live) → Hands-on → Discussion.

This section adapts the Slurm parts of the source tutorial into beginner-friendly Isambard 3 exercises.

Files in this section:

- `01-hello-world.md` - first batch job walkthrough
- `02-multi-task.md` - extend the job to multiple tasks
- `03-sysinfo.md` - single-core job that inspects the compute node (`date`, `free`, `lscpu`, Slurm env)
- `04-interactive.md` - starting an interactive session with `srun --pty bash`
- `05-matmul.md` - compile and run a small C matmul under Slurm; measure GFLOPS
- `hello_world.sh` - starter script
- `multi_task.sh` - multi-task script using `srun`
- `sysinfo.sh` - single-core system-info batch script
- `matmul.c` - dense matrix-multiply with timing and GFLOPS output
- `makefile` - builds `matmul` (serial) or `matmul_omp` (OpenMP stretch) with `gcc-native`
- `matmul.sh` - batch script that loads `gcc-native`, builds, and runs `matmul`

All examples here are CPU-only and suitable for Isambard 3.
