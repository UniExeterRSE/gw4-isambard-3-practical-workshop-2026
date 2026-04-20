"""race_condition_numba.py

Demonstrates a data race in Numba: accumulating into a shared NumPy array
element from a parallel prange loop.

Numba handles scalar reductions in prange automatically, but writing to a
shared array element is NOT protected — it is a data race.

Expected: N * M // 3
Actual:   non-deterministic, usually wrong

Fix: use a scalar accumulator  hits = np.int64(0)  and let prange handle
the reduction, rather than indexing into a shared array.
"""

from __future__ import annotations

import os
import sys

import numpy as np
from numba import njit, prange, set_num_threads


@njit(parallel=True, cache=True)
def count_divisible_wrong(n: int, m: int) -> int:
    """Count integers in [0,n) x [0,m) divisible by 3 — BUG: shared array element."""
    counts = np.zeros(1, dtype=np.int64)  # shared array — race condition
    for i in prange(n):
        row_hits = np.int64(0)
        for j in range(m):
            if (i * m + j) % 3 == 0:
                row_hits += 1
        counts[0] += row_hits  # BUG: multiple threads write to counts[0]
    return int(counts[0])


def main() -> None:
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 4000
    m = int(sys.argv[2]) if len(sys.argv) > 2 else 4000

    nthreads = int(os.environ.get("NUMBA_NUM_THREADS", "4"))
    set_num_threads(nthreads)

    # Warm-up JIT compile
    count_divisible_wrong(10, 10)

    expected = n * m // 3
    for run in range(1, 4):
        result = count_divisible_wrong(n, m)
        correct = "yes" if result == expected else "NO — race condition detected!"
        print(f"Run {run}: threads={nthreads}  expected\u2248{expected}  got={result}  correct? {correct}")


if __name__ == "__main__":
    main()
