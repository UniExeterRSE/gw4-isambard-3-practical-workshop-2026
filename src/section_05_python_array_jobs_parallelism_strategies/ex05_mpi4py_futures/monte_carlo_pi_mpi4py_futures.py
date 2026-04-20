"""Monte Carlo Pi using mpi4py.futures MPIPoolExecutor.

Launched via:
    mpiexec -n N python -m mpi4py.futures monte_carlo_pi_mpi4py_futures.py ...

Rank 0 acts as the controller: it submits tasks, collects results, and reduces
them. Ranks 1..N-1 are workers. With N MPI processes you get N-1 workers.
"""

from __future__ import annotations

import argparse
import time


def _worker(args: tuple[int, int, int, int]) -> tuple[int, int]:
    """Run one MC task in a worker rank. Returns (hits, n)."""
    n, d, seed, num_threads = args
    import numba

    numba.set_num_threads(num_threads)
    from section_05_python_array_jobs_parallelism_strategies.ex01_monte_carlo_pi.monte_carlo_pi_numba import (
        count_hits_kernel,
    )

    hits = int(count_hits_kernel(n, d, seed))
    return hits, n


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Monte Carlo Pi using mpi4py.futures MPIPoolExecutor.\n"
            "Rank 0 controls; ranks 1..N-1 are workers.\n"
            "Launch with: mpiexec -n N python -m mpi4py.futures <script> ..."
        )
    )
    parser.add_argument("-d", "--dimension", dest="d", type=int, default=2)
    parser.add_argument("-n", "--num-samples", dest="n", type=int, default=1_048_576, help="Samples per task.")
    parser.add_argument(
        "-t", "--num-threads", dest="num_threads", type=int, default=1, help="Numba threads per worker."
    )
    parser.add_argument("-s", "--seed", dest="seed", type=int, default=20260421)
    parser.add_argument(
        "--tasks",
        dest="n_tasks",
        type=int,
        default=None,
        help="Number of tasks to submit (default: number of workers).",
    )
    args = parser.parse_args()

    from mpi4py import MPI
    from mpi4py.futures import MPIPoolExecutor

    n_workers = MPI.COMM_WORLD.Get_size() - 1
    if n_workers < 1:
        raise RuntimeError("Need at least 2 MPI processes (1 controller + 1+ workers).")

    n_tasks = args.n_tasks if args.n_tasks is not None else n_workers

    task_args = [(args.n, args.d, args.seed + task_id, args.num_threads) for task_id in range(n_tasks)]

    print(f"Controller: {n_workers} workers, {n_tasks} tasks, {args.n} samples/task")

    start = time.perf_counter()
    with MPIPoolExecutor() as executor:
        results = list(executor.map(_worker, task_args))
    elapsed_s = time.perf_counter() - start

    total_hits = sum(r[0] for r in results)
    total_n = sum(r[1] for r in results)

    import math

    pi_estimate = 4.0 * total_hits / total_n
    error = abs(pi_estimate - math.pi)
    print(f"total_n={total_n:,}  hits={total_hits:,}")
    print(f"pi_estimate={pi_estimate:.8f}  error={error:.2e}  time={elapsed_s:.3f}s")


if __name__ == "__main__":
    main()
