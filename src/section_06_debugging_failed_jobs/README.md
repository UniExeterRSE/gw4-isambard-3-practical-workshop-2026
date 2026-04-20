# Section 6 — Debugging Failed Jobs

**Duration:** 20 min \| **Format:** Active (hands-on exercises)

## Goal

Hands-on practice diagnosing and fixing broken Slurm job scripts. Each exercise presents a deliberately broken script;
your job is to read the error, form a hypothesis, fix it, and verify.

**You do not need to do all exercises.** Pick the ones most relevant to your work and move at your own pace. Helpers are
in the room — raise a hand if you get stuck.

## Exercises

| Exercise                                | Description                                                             |
|-----------------------------------------|-------------------------------------------------------------------------|
| **ex01** `ex01_oversubscription/`       | Oversubscription — `srun` launches more threads than CPUs allocated     |
| **ex02** `ex02_wrong_env_module/`       | Wrong env (module) — `module load PrgEnv-gnu` missing from batch script |
| **ex03** `ex03_wrong_env_pixi_missing/` | Wrong env (pixi missing) — pixi not activated on compute node           |
| **ex04** `ex04_wrong_env_pixi_wrong/`   | Wrong env (pixi wrong) — `default` env used instead of `hpc`            |
| **ex05** `ex05_oom_matmul/`             | OOM — large matrix with 1 CPU allocated; job killed by OOM killer       |
| **ex06** `ex06_mpi_topology/`           | MPI topology — uneven rank distribution across nodes causes stalls      |
| **ex07** `ex07_race_condition/`         | Race condition — missing OpenMP reduction clause (C and Numba)          |

## Debugging checklist

When a job fails, work through this list in order:

1.  **Read `.out` and `.err` first.** The error message is almost always there. Look for the last few lines before the
    job ends.

2.  **Run `sacct`** to get the scheduler’s view of the job:

    ``` bash
    sacct --format=JobID,State,ExitCode,MaxRSS -j <jobid>
    ```

    - `State` tells you whether the job was cancelled, failed, or hit a timeout.
    - `ExitCode` is the shell exit code (non-zero = something went wrong).
    - `MaxRSS` is the peak resident memory — compare it to your `--mem` or `--mem-per-cpu` request.

3.  **Check `squeue` states** for jobs that are not progressing:

    - `PD` — pending; waiting for resources or a dependency.
    - `R` — running.
    - `CG` — completing; winding down after the main script finished.

4.  **Pending too long?** Use `squeue --start` to see when Slurm estimates the job will start:

    ``` bash
    squeue --start --me
    ```

5.  **Form a hypothesis** before touching the script. Write down what you expect to be wrong, then check whether the
    output confirms it. Blind edits waste time.

## Etiquette note

Do not hammer the scheduler with rapid-fire polling. Running `squeue` or `sinfo` in a tight loop or with `watch -n 1`
puts unnecessary load on a shared system. Use `watch -n 15` at most, or just run `squeue --me` manually every minute or
so. The scheduler is shared by everyone on the system.
