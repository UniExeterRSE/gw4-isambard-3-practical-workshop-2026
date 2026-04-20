"""Combine per-task Monte Carlo Pi result files into a single estimate.

Each input file contains a single line: ``hits n``
written by the ``--save`` flag of ``monte-carlo-pi-numba-parallel``.

Usage::

    reduce-mc-pi-results results/mc_pi_*.txt
    python -m section_05_python_array_jobs_parallelism_strategies.ex03_job_array.reduce_results results/mc_pi_*.txt
"""

from __future__ import annotations

import math
import sys
from pathlib import Path


def _invert_probability_to_pi(probability: float, d: int) -> float:
    prefactor = (2.0**d) * math.gamma(d / 2.0 + 1.0)
    return (prefactor * probability) ** (2.0 / d)


def main() -> None:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <result_file> [...]", file=sys.stderr)
        sys.exit(1)

    total_hits = 0
    total_n = 0

    print("Per-task results:")
    for path in sorted(sys.argv[1:]):
        hits, n = map(int, Path(path).read_text().split())
        total_hits += hits
        total_n += n
        print(f"  {path}: hits={hits:>12d}  n={n:>12d}  pi_hat={_invert_probability_to_pi(hits / n, d=2):.6f}")

    if total_n == 0:
        print("No samples found.", file=sys.stderr)
        sys.exit(1)

    p_hat = total_hits / total_n
    pi_hat = _invert_probability_to_pi(p_hat, d=2)
    print(f"\nReduced total: hits={total_hits}  n={total_n}")
    print(f"  p_hat  = {p_hat:.8f}")
    print(f"  pi_hat = {pi_hat:.8f}  (true pi = {math.pi:.8f})")
    print(f"  error  = {abs(pi_hat - math.pi):.2e}")


if __name__ == "__main__":
    main()
