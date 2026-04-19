# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Monte Carlo Pi: Hybrid MPI + Threaded Numba
#
# This version distributes the work across MPI ranks and uses the threaded
# Numba kernel within each rank.
#
# Seed strategy mirrors the C version: each (rank, thread) pair gets a unique
# stream index `rank * nthreads + tid`, so `base_seed + rank * nthreads` is
# passed to `count_hits_parallel`, which internally adds `tid`.

# %%
from __future__ import annotations

import time

from mpi4py import MPI
from numba import get_num_threads, set_num_threads

from .monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    build_parser,
    print_results,
    summarise_result,
)
from .monte_carlo_pi_numba_parallel import count_hits_parallel

VARIANT_NAME = "mpi-hybrid"


def count_local_hits(local_n: int, config: ExperimentConfig, rank: int) -> int:
    set_num_threads(config.num_threads)
    nthreads = config.num_threads
    # stream = rank * nthreads + tid; pass rank-offset base so count_hits_parallel
    # adds tid to get unique per-(rank,thread) streams.
    rank_base_seed = config.seed + rank * nthreads
    return int(count_hits_parallel(local_n, config.d, rank_base_seed, nthreads))


def run_experiment(config: ExperimentConfig) -> ExperimentResult | None:
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    local_n = config.n // size
    if rank < (config.n % size):
        local_n += 1

    comm.Barrier()
    start = time.perf_counter()
    local_hits = count_local_hits(local_n, config, rank)
    local_elapsed_s = time.perf_counter() - start

    total_hits = comm.reduce(local_hits, op=MPI.SUM, root=0)
    total_n = comm.reduce(local_n, op=MPI.SUM, root=0)
    elapsed_s = comm.reduce(local_elapsed_s, op=MPI.MAX, root=0)

    if rank != 0:
        return None

    return summarise_result(
        variant=VARIANT_NAME,
        hits=total_hits,
        n=total_n,
        d=config.d,
        elapsed_s=elapsed_s,
        num_threads=get_num_threads(),
        mpi_processes=size,
    )


def main() -> None:
    comm = MPI.COMM_WORLD
    size = comm.Get_size()
    # -n is samples PER THREAD (matching the C convention).
    # Total samples = MPI ranks × threads × n.
    args = build_parser(
        "Monte Carlo Pi using hybrid MPI and threaded Numba.\n"
        "-n sets samples per thread; total = MPI ranks × threads × n."
    ).parse_args()
    config = ExperimentConfig(
        d=args.d,
        n=args.n * args.num_threads * size,
        num_threads=args.num_threads,
        seed=args.seed,
        chunk_size=args.chunk_size,
    )
    result = run_experiment(config)
    if result is not None:
        print_results(config, [result])


if __name__ == "__main__":
    main()
