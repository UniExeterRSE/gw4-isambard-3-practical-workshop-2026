"""Monte Carlo Pi using Python multiprocessing.

Following NERSC guidance:
- Use spawn start method (avoids forking MPI/numba state).
- Query available CPUs with os.sched_getaffinity(0) (respects Slurm cgroup).
- Partition the affinity mask into fixed-width worker slots so tasks do not
  overlap when each worker runs a multithreaded Numba kernel.
- Pool.map distributes tasks across workers.
"""

from __future__ import annotations

import argparse
import math
import os
import time

_WORKER_NUM_THREADS = 1


def _partition_cpus(available_cpus: list[int], n_workers: int, num_threads: int) -> list[tuple[int, ...]]:
    needed = n_workers * num_threads
    if needed > len(available_cpus):
        raise ValueError(
            f"Requested {n_workers} workers x {num_threads} threads = {needed} CPUs, "
            f"but only {len(available_cpus)} CPUs are available in the Slurm affinity mask."
        )
    return [tuple(available_cpus[start : start + num_threads]) for start in range(0, needed, num_threads)]


def _init_worker(
    cpu_slots: list[tuple[int, ...]],
    worker_counter,
    worker_lock,
    num_threads: int,
) -> None:
    global _WORKER_NUM_THREADS

    with worker_lock:
        worker_index = worker_counter.value
        worker_counter.value += 1

    os.sched_setaffinity(0, cpu_slots[worker_index])
    os.environ["OMP_NUM_THREADS"] = str(num_threads)
    os.environ["NUMBA_NUM_THREADS"] = str(num_threads)

    import numba

    numba.set_num_threads(num_threads)
    _WORKER_NUM_THREADS = num_threads


def _worker(args: tuple[int, int, int]) -> tuple[int, int]:
    """Run one MC task in a worker process. Returns (hits, n)."""
    n, d, seed = args
    from section_05_python_array_jobs_parallelism_strategies.ex01_monte_carlo_pi.monte_carlo_pi_numba_parallel import (
        count_hits_parallel,
    )

    hits = int(count_hits_parallel(n, d, seed, _WORKER_NUM_THREADS))
    return hits, n


def main() -> None:
    import multiprocessing as mp

    ctx = mp.get_context("spawn")

    parser = argparse.ArgumentParser(
        description=(
            "Monte Carlo Pi using Python multiprocessing.\n"
            "Worker count is derived from the Slurm affinity mask and threads per worker."
        )
    )
    parser.add_argument("-d", "--dimension", dest="d", type=int, default=2)
    parser.add_argument("-n", "--num-samples", dest="n", type=int, default=2**20, help="Samples per thread.")
    parser.add_argument("-t", "--num-threads", dest="num_threads", type=int, default=1, help="Threads per worker.")
    parser.add_argument("-s", "--seed", dest="seed", type=int, default=20260421)
    parser.add_argument("--tasks", dest="n_tasks", type=int, default=None, help="Number of tasks (default: n_workers).")
    parser.add_argument(
        "--workers",
        dest="n_workers",
        type=int,
        default=None,
        help="Worker count (default: CPUs in affinity mask divided by threads per worker).",
    )
    args = parser.parse_args()

    if args.num_threads < 1:
        raise ValueError("num_threads must be a positive integer.")

    available_cpus = sorted(os.sched_getaffinity(0))
    default_workers = len(available_cpus) // args.num_threads
    n_workers = args.n_workers or default_workers
    n_tasks = args.n_tasks or n_workers
    if n_workers < 1:
        raise ValueError("n_workers must be a positive integer and fit within the Slurm affinity mask.")
    if n_tasks < 1:
        raise ValueError("n_tasks must be a positive integer.")
    cpu_slots = _partition_cpus(available_cpus, n_workers, args.num_threads)
    task_n = args.n * args.num_threads

    task_args = [(task_n, args.d, args.seed + task_id) for task_id in range(n_tasks)]
    worker_counter = ctx.Value("i", 0)
    worker_lock = ctx.Lock()

    print(f"Workers: {n_workers}  Tasks: {n_tasks}  Samples/thread: {args.n:,}  Threads/worker: {args.num_threads}")

    start = time.perf_counter()
    with ctx.Pool(
        processes=n_workers,
        initializer=_init_worker,
        initargs=(cpu_slots, worker_counter, worker_lock, args.num_threads),
    ) as pool:
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
