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
# Two-level structure mirrors the C MPI/OpenMP hybrid:
#
# - `count_hits_kernel` — single-thread kernel; seeds its own RNG from a stream
#   index so no two threads share samples (analogous to `count_hits` in the C
#   version).
# - `count_hits_parallel` — `prange` wrapper that dispatches one `count_hits_kernel`
#   call per thread (analogous to `count_local_hits` in the C version).
#
# Explicit type signatures trigger eager compilation at import time; no warm-up
# call is needed.  Points are generated inline — no intermediate array is allocated.

# %%
from __future__ import annotations

import numpy as np
from numba import get_num_threads, njit, prange, set_num_threads

from .monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    parse_config,
    print_results,
    save_raw_result,
    summarise_result,
    timed_count,
)
from .monte_carlo_pi_numba import count_hits_kernel

VARIANT_NAME = "numba-parallel"


@njit("i8(i8, i8, i8, i8)", cache=True, parallel=True)
def count_hits_parallel(n: int, d: int, base_seed: int, nthreads: int) -> int:
    """Distribute n samples across nthreads; each thread gets an independent RNG stream."""
    hits = np.int64(0)
    q = n // nthreads
    r = n % nthreads
    for tid in prange(nthreads):
        # Ceiling-distribute remainder to the first r threads.
        n_this = q + (1 if tid < r else 0)
        hits += count_hits_kernel(n_this, d, base_seed + tid)
    return hits


def count_hits(config: ExperimentConfig) -> int:
    set_num_threads(config.num_threads)
    return int(count_hits_parallel(config.n, config.d, config.seed, config.num_threads))


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
    result = run_experiment(config)
    print_results(config, [result])
    if config.save:
        save_raw_result(result, config.save)


if __name__ == "__main__":
    main()
