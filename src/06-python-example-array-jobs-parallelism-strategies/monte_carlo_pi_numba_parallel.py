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
# # Monte Carlo Pi: Numba Parallel
#
# This version changes the Numba kernel to `parallel=True` and switches the
# outer loop to `prange`.

# %%
from __future__ import annotations

import numpy as np
from numba import get_num_threads, njit, prange, set_num_threads

from monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    chunk_lengths,
    parse_config,
    print_results,
    summarise_result,
    timed_count,
)

VARIANT_NAME = "numba-parallel"
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


def count_hits(config: ExperimentConfig) -> int:
    set_num_threads(config.num_threads)
    warm_kernel(config.d)
    rng = np.random.default_rng(config.seed)
    hits = 0
    for length in chunk_lengths(config.n, config.chunk_size):
        points = rng.uniform(-1.0, 1.0, size=(length, config.d))
        hits += int(count_hits_kernel(points))
    return hits


def run_experiment(config: ExperimentConfig) -> ExperimentResult:
    hits, elapsed_s = timed_count(count_hits, config)
    return summarise_result(
        variant=VARIANT_NAME,
        hits=hits,
        n=config.n,
        d=config.d,
        elapsed_s=elapsed_s,
        num_threads=get_num_threads(),
        mpi_processes=1,
    )


def main() -> None:
    config = parse_config("Monte Carlo Pi using Numba with parallel prange.")
    print_results(config, [run_experiment(config)])


if __name__ == "__main__":
    main()
