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
# # Monte Carlo Pi: Numba
#
# This version JIT-compiles the entire kernel with Numba, including inline RNG.
# An explicit type signature triggers eager compilation at import time, so no
# warm-up call is needed. Points are generated and consumed immediately inside
# the loop — no intermediate array is allocated.

# %%
from __future__ import annotations

import numpy as np
from numba import njit

from .monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    parse_config,
    print_results,
    summarise_result,
    timed_count,
)

VARIANT_NAME = "numba"


# Explicit signature → eager compilation at module import; no warm-up call needed.
# np.random.seed / np.random.uniform are supported in numba nopython mode and use
# a thread-local state, matching the xoshiro per-stream pattern in the C version.
@njit("i8(i8, i8, i8)", cache=True)
def count_hits_kernel(n: int, d: int, seed: int) -> int:
    np.random.seed(seed)
    hits = np.int64(0)
    for _ in range(n):
        rsq = 0.0
        for _ in range(d):
            x = np.random.uniform(-1.0, 1.0)
            rsq += x * x
        if rsq <= 1.0:
            hits += 1
    return hits


def count_hits(config: ExperimentConfig) -> int:
    return int(count_hits_kernel(config.n, config.d, config.seed))


def run_experiment(config: ExperimentConfig) -> ExperimentResult:
    hits, elapsed_s = timed_count(count_hits, config)
    return summarise_result(
        variant=VARIANT_NAME,
        hits=hits,
        n=config.n,
        d=config.d,
        elapsed_s=elapsed_s,
        num_threads=1,
        mpi_processes=1,
    )


def main() -> None:
    config = parse_config("Monte Carlo Pi using a Numba JIT kernel.")
    print_results(config, [run_experiment(config)])


if __name__ == "__main__":
    main()
