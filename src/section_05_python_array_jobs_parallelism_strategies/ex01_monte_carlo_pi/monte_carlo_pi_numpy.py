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
# # Monte Carlo Pi: NumPy
#
# This version draws points in array batches with NumPy and counts hits with
# vectorised operations.

# %%
from __future__ import annotations

import numpy as np

from .monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    chunk_lengths,
    parse_config,
    print_results,
    summarise_result,
    timed_count,
)

VARIANT_NAME = "numpy"


def count_hits(config: ExperimentConfig) -> int:
    rng = np.random.default_rng(config.seed)
    hits = 0
    for length in chunk_lengths(config.n, config.chunk_size):
        points = rng.uniform(-1.0, 1.0, size=(length, config.d))
        squared_radius = np.sum(points * points, axis=1)
        hits += int(np.count_nonzero(squared_radius <= 1.0))
    return hits


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
    config = parse_config("Monte Carlo Pi using NumPy vectorisation.")
    print_results(config, [run_experiment(config)])


if __name__ == "__main__":
    main()
