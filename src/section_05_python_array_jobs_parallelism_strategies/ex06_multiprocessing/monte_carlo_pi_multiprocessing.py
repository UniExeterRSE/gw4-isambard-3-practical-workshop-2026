"""Monte Carlo Pi using Python multiprocessing.

Following NERSC guidance:
- Use spawn start method (avoids forking MPI/numba state).
- Query available CPUs with os.sched_getaffinity(0) (respects Slurm cgroup).
- Set OMP_NUM_THREADS=1 / NUMBA_NUM_THREADS=1 before spawning workers to
  prevent nested threading (each worker IS the thread).
- Pool.map distributes tasks across workers.
"""

from __future__ import annotations

import argparse
import math
import os
import time


def _worker(args: tuple[int, int, int]) -> tuple[int, int]:
    """Run one MC task in a worker process. Returns (hits, n)."""
    n, d, seed = args
    from section_05_python_array_jobs_parallelism_strategies.ex01_monte_carlo_pi.monte_carlo_pi_numba import (
        count_hits_kernel,
    )

    hits = int(count_hits_kernel(n, d, seed))
    return hits, n


def main() -> None:
    import multiprocessing as mp

    mp.set_start_method("spawn")

    parser = argparse.ArgumentParser(
        description=(
            "Monte Carlo Pi using Python multiprocessing.\n"
            "Worker count is read from Slurm-assigned CPUs via os.sched_getaffinity."
        )
    )
    parser.add_argument("-d", "--dimension", dest="d", type=int, default=2)
    parser.add_argument("-n", "--num-samples", dest="n", type=int, default=1_048_576, help="Samples per task.")
    parser.add_argument("-s", "--seed", dest="seed", type=int, default=20260421)
    parser.add_argument("--tasks", dest="n_tasks", type=int, default=None, help="Number of tasks (default: n_workers).")
    parser.add_argument(
        "--workers", dest="n_workers", type=int, default=None, help="Worker count (default: CPUs in affinity mask)."
    )
    args = parser.parse_args()

    # Respect Slurm's CPU allocation; do not use os.cpu_count() which counts all cores.
    n_workers = args.n_workers or len(os.sched_getaffinity(0))
    n_tasks = args.n_tasks or n_workers

    # Prevent nested threading: each worker process runs single-threaded Numba.
    os.environ["OMP_NUM_THREADS"] = "1"
    os.environ["NUMBA_NUM_THREADS"] = "1"

    task_args = [(args.n, args.d, args.seed + task_id) for task_id in range(n_tasks)]

    print(f"Workers: {n_workers}  Tasks: {n_tasks}  Samples/task: {args.n:,}")

    start = time.perf_counter()
    with mp.Pool(processes=n_workers) as pool:
        results = pool.map(_worker, task_args)
    elapsed_s = time.perf_counter() - start

    total_hits = sum(r[0] for r in results)
    total_n = sum(r[1] for r in results)

    p_hat = total_hits / total_n
    prefactor = (2.0**args.d) * math.gamma(args.d / 2.0 + 1.0)
    pi_estimate = (prefactor * p_hat) ** (2.0 / args.d)
    error = abs(pi_estimate - math.pi)
    print(f"total_n={total_n:,}  hits={total_hits:,}")
    print(f"pi_estimate={pi_estimate:.8f}  error={error:.2e}  time={elapsed_s:.3f}s")


if __name__ == "__main__":
    main()
