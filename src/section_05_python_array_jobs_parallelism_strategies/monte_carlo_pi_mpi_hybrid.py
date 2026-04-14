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

# %%
from __future__ import annotations

import time

import numpy as np
from mpi4py import MPI
from numba import get_num_threads, njit, prange, set_num_threads

try:
    from .monte_carlo_pi_common import (
        ExperimentConfig,
        ExperimentResult,
        chunk_lengths,
        parse_config,
        print_results,
        summarise_result,
    )
except ImportError:
    from monte_carlo_pi_common import (  # type: ignore
        ExperimentConfig,
        ExperimentResult,
        chunk_lengths,
        parse_config,
        print_results,
        summarise_result,
    )

VARIANT_NAME = "mpi-hybrid"
_WARMED_DIMENSIONS: set[int] = set()


@njit(cache=True, parallel=True)
def count_hits_kernel(points: np.ndarray) -> int:
    hits = 0
    for i in prange(points.shape[0]):
        radius_sq = 0.0
        for j in range(points.shape[1]):
            radius_sq += points[i, j] * points[i, j]
        if radius_sq <= 1.0:
            hits += 1
    return hits


def warm_kernel(d: int) -> None:
    if d in _WARMED_DIMENSIONS:
        return
    count_hits_kernel(np.zeros((1, d), dtype=np.float64))
    _WARMED_DIMENSIONS.add(d)


def count_local_hits(local_n: int, config: ExperimentConfig, seed: int) -> int:
    set_num_threads(config.num_threads)
    warm_kernel(config.d)
    rng = np.random.default_rng(seed)
    hits = 0
    for length in chunk_lengths(local_n, config.chunk_size):
        points = rng.uniform(-1.0, 1.0, size=(length, config.d))
        hits += int(count_hits_kernel(points))
    return hits


def run_experiment(config: ExperimentConfig) -> ExperimentResult | None:
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    local_n = config.n // size
    if rank < (config.n % size):
        local_n += 1

    local_seed = config.seed + 10_000 * rank

    comm.Barrier()
    start = time.perf_counter()
    local_hits = count_local_hits(local_n, config, local_seed)
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
    config = parse_config("Monte Carlo Pi using hybrid MPI and threaded Numba.")
    result = run_experiment(config)
    if result is not None:
        print_results(config, [result])


if __name__ == "__main__":
    main()
