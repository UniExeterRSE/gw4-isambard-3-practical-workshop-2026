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
# # Monte Carlo Pi: Pure Python
#
# This version uses Python loops and the standard-library `random` module.

# %%
from __future__ import annotations

import random

from .monte_carlo_pi_common import (
    ExperimentConfig,
    ExperimentResult,
    parse_config,
    print_results,
    summarise_result,
    timed_count,
)

VARIANT_NAME = "pure-python"


def count_hits(config: ExperimentConfig) -> int:
    rng = random.Random(config.seed)
    hits = 0
    for _ in range(config.n):
        rsq = sum(rng.uniform(-1.0, 1.0) ** 2 for _ in range(config.d))
        if rsq <= 1.0:
            hits += 1
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
    config = parse_config("Monte Carlo Pi using pure Python loops.")
    print_results(config, [run_experiment(config)])


if __name__ == "__main__":
    main()
