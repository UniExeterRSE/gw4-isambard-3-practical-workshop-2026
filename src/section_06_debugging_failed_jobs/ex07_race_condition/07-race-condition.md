# A Job That Gives Wrong Answers

Two programs exit with code 0, no errors, no crashes — yet the results are wrong and change between runs. This exercise
asks you to find out why.

------------------------------------------------------------------------------------------------------------------------

## Part A: C OpenMP

### Build

On the login node, compile the demo binary from this directory:

``` bash
cd src/section_06_debugging_failed_jobs/ex07_race_condition
bash make.sh
```

### Submit

``` bash
sbatch sbatch_race_condition.sh
```

Monitor with:

``` bash
squeue --me
```

Once finished, inspect the output:

``` bash
cat race_condition_<JOBID>.out
```

### What do you see?

The job runs `./race_condition` three times with 8 OpenMP threads. The expected answer is N × M / 3 ≈ 5,333,333. A
correct result would print `correct? yes` for every run.

Instead you will see output like:

    threads=8  N=4000  M=4000
    expected ≈ 5333333
    got        4821107
    correct?   NO — race condition detected!

    threads=8  N=4000  M=4000
    expected ≈ 5333333
    got        5102984
    correct?   NO — race condition detected!

    threads=8  N=4000  M=4000
    expected ≈ 5333333
    got        4956621
    correct?   NO — race condition detected!

Three runs, three different wrong answers — all lower than expected.

### Investigate

- Is the result consistent between runs? What does inconsistency tell you about what is happening during execution?
- Where in `race_condition.c` is `hits` updated? Can multiple threads reach that line simultaneously?
- OpenMP variables are either **shared** (one copy, visible to all threads) or **private** (one copy per thread). Which
  is `hits` here?
- Run `OMP_NUM_THREADS=1 ./race_condition`. Does the answer become correct? What does that tell you?

### Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Search for “OpenMP reduction clause” in the OpenMP 5.x spec or any tutorial. What problem does it solve?
- The `#pragma omp parallel for` directive accepts optional clauses. Which clause makes a variable thread-private and
  then combines the per-thread values at the end of the parallel region?
- Compare the parallel loop in `race_condition.c` to the one in
  `src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/monte_carlo_pi_mpi_hybrid.c` — what
  clause is present there that is missing here?

------------------------------------------------------------------------------------------------------------------------

## Part B: Python Numba

### Submit

``` bash
sbatch sbatch_race_condition_numba.sh
```

Once finished, inspect the output:

``` bash
cat race_condition_numba_<JOBID>.out
```

### What do you see?

The same non-deterministic wrong results, this time in Python:

    Run 1: threads=8  expected≈5333333  got=4901234  correct? NO — race condition detected!
    Run 2: threads=8  expected≈5333333  got=5198456  correct? NO — race condition detected!
    Run 3: threads=8  expected≈5333333  got=4823901  correct? NO — race condition detected!

### Investigate

- Is the result consistent between runs?
- In `race_condition_numba.py`, `counts` is a NumPy array. When multiple threads execute `counts[0] += row_hits`, what
  individual operations are involved under the hood — read, add, write? What can go wrong when two threads do this
  simultaneously?
- Run `NUMBA_NUM_THREADS=1 python race_condition_numba.py`. Does the answer become correct?
- Numba handles `prange` scalar reductions automatically. Is `counts[0]` a scalar?

### Hints

> Try to debug it yourself first. Come back here if you’re stuck.

- Read the Numba documentation on `prange` reductions: what patterns does Numba reduce automatically?
- What is the difference between accumulating into a scalar (`hits = np.int64(0); hits += x`) versus an array element
  (`counts[0] += x`) inside a `prange` loop?
- If you changed `counts = np.zeros(1, dtype=np.int64)` to a plain scalar variable, would the race disappear? Try it.

------------------------------------------------------------------------------------------------------------------------

## Notes

Data races are one of the most common correctness bugs in parallel code. They are especially insidious because:

1.  Results are wrong but *plausible* — not a crash or an exception.
2.  The bug may not appear at all with a single thread; it only surfaces under parallelism.
3.  Results are non-deterministic — the same binary, the same input, different answers on every run.

Always verify your parallel results against a single-threaded reference before trusting them.
