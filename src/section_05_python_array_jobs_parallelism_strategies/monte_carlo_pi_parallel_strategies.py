# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.19.1
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Monte Carlo Pi: Summary Runner
#
# This script imports the per-variant entry points and prints a single summary
# table so the implementation differences remain in separate files.

# %%
from __future__ import annotations

try:
    from mpi4py import MPI

    COMM = MPI.COMM_WORLD
except ImportError:
    MPI = None
    COMM = None

try:
    from .monte_carlo_pi_common import parse_config, print_results
    from .monte_carlo_pi_mpi_hybrid import run_experiment as run_mpi_hybrid
    from .monte_carlo_pi_numba import run_experiment as run_numba
    from .monte_carlo_pi_numba_parallel import run_experiment as run_numba_parallel
    from .monte_carlo_pi_numpy import run_experiment as run_numpy
    from .monte_carlo_pi_pure_python import run_experiment as run_pure_python
except ImportError:
    from monte_carlo_pi_common import parse_config, print_results  # type: ignore
    from monte_carlo_pi_mpi_hybrid import run_experiment as run_mpi_hybrid  # type: ignore
    from monte_carlo_pi_numba import run_experiment as run_numba  # type: ignore
    from monte_carlo_pi_numba_parallel import (  # type: ignore
        run_experiment as run_numba_parallel,
    )
    from monte_carlo_pi_numpy import run_experiment as run_numpy  # type: ignore
    from monte_carlo_pi_pure_python import run_experiment as run_pure_python  # type: ignore


def main() -> None:
    config = parse_config(
        "Compare the separate Monte Carlo Pi variant scripts and print one summary table.",
    )

    rank = 0 if COMM is None else COMM.Get_rank()
    size = 1 if COMM is None else COMM.Get_size()
    results = []

    if rank == 0:
        results.append(run_pure_python(config))
        results.append(run_numpy(config))
        results.append(run_numba(config))
        results.append(run_numba_parallel(config))
    if size > 1:
        COMM.Barrier()
        hybrid_result = run_mpi_hybrid(config)
    else:
        hybrid_result = None

    if rank == 0 and hybrid_result is not None:
        results.append(hybrid_result)
    if rank == 0:
        print_results(config, results)


if __name__ == "__main__":
    main()
