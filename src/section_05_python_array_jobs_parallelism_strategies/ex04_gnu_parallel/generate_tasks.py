"""Print one monte-carlo-pi-numba-parallel command per line for GNU parallel.

Each line pins itself to a disjoint set of cores using ``$PARALLEL_JOBSLOT``,
which GNU parallel exports to every spawned process. With N_CONCURRENT slots
and N_THREADS per task, slot k occupies cores (k-1)*N_THREADS … k*N_THREADS-1.
This eliminates oversubscription when N_CONCURRENT * N_THREADS == total cores.

``/usr/bin/time -v`` wraps each command so wall-clock time and peak memory
appear in the per-task output alongside the pi estimate; ``2>&1`` merges that
diagnostic stderr into stdout so a single log file captures everything.

N_CONCURRENT is set in sbatch_gnu_parallel.sh and must equal N_TASKS when
all tasks are to run simultaneously, or be set to total_cores // N_THREADS for
a full-node run.

Usage::

    python generate_tasks.py > tasks.txt
    python -m section_05_python_array_jobs_parallelism_strategies.ex04_gnu_parallel.generate_tasks > tasks.txt
"""

from __future__ import annotations

import argparse

DEFAULT_TASKS = 36
DEFAULT_SAMPLES_PER_THREAD = 2**29
DEFAULT_THREADS = 4
DEFAULT_DIMENSION = 2


def task_command(*, seed: int, samples_per_thread: int, threads: int, dimension: int, core_spec: str) -> str:
    result_file = f"results/mc_pi_gnu_{seed}.txt"
    return (
        f"taskset -c {core_spec}"
        f" env NUMBA_NUM_THREADS={threads}"
        f" OMP_PLACES=threads OMP_PROC_BIND=spread OMP_DYNAMIC=FALSE"
        f" /usr/bin/time -v"
        f" monte-carlo-pi-numba-parallel"
        f" -d {dimension} -n {samples_per_thread} -t {threads}"
        f" -s {seed} --save {result_file}"
        f" 2>&1"
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tasks", type=int, default=DEFAULT_TASKS, help="Number of task lines to print.")
    parser.add_argument(
        "--samples-per-thread",
        type=int,
        default=DEFAULT_SAMPLES_PER_THREAD,
        help="Monte Carlo samples per thread in each task.",
    )
    parser.add_argument("--threads", type=int, default=DEFAULT_THREADS, help="Threads used by each task.")
    parser.add_argument("--dimension", type=int, default=DEFAULT_DIMENSION, help="Problem dimension.")
    parser.add_argument(
        "--preview-slot",
        type=int,
        default=None,
        help="Print one concrete slot-bound command instead of the full tasks.txt contents.",
    )
    parser.add_argument(
        "--preview-seed",
        type=int,
        default=1,
        help="Seed used for --preview-slot output.",
    )
    return parser


def main() -> None:
    args = build_parser().parse_args()
    if args.preview_slot is not None:
        if args.preview_slot < 1:
            raise ValueError("preview_slot must be a positive integer.")
        first_cpu = (args.preview_slot - 1) * args.threads
        last_cpu = args.preview_slot * args.threads - 1
        print(
            task_command(
                seed=args.preview_seed,
                samples_per_thread=args.samples_per_thread,
                threads=args.threads,
                dimension=args.dimension,
                core_spec=f"{first_cpu}-{last_cpu}",
            )
        )
        return

    for seed in range(1, args.tasks + 1):
        # PARALLEL_JOBSLOT is exported by GNU parallel (1-based slot cycling up to --jobs N).
        # Shell arithmetic $(( )) is evaluated by the subshell parallel spawns, so the
        # literal string $PARALLEL_JOBSLOT is safe to embed here.
        print(
            task_command(
                seed=seed,
                samples_per_thread=args.samples_per_thread,
                threads=args.threads,
                dimension=args.dimension,
                core_spec=f"$(( (PARALLEL_JOBSLOT-1)*{args.threads} ))-$(( PARALLEL_JOBSLOT*{args.threads}-1 ))",
            )
        )


if __name__ == "__main__":
    main()
