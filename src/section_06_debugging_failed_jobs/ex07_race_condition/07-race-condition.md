# Exercise 7 — Race Condition: Missing OpenMP Reduction (C and Numba)

------------------------------------------------------------------------------------------------------------------------

## The scenario

You write a parallel loop to count matching elements. The code looks correct — the outer loop is parallelized, and you
accumulate results locally before adding to the total. But the results are wrong and change between runs.

This exercise shows the same bug in two languages: C with OpenMP and Python with Numba.

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

### Questions

1.  Look at `race_condition.c`. Where is `hits` modified? Is it a private or shared variable across threads?

2.  What does “data race” mean? What can happen when two threads read, modify, and write the same variable
    simultaneously without synchronisation?

3.  Why is the result *usually* too low rather than too high? Think about what happens when two threads both read
    `hits`, add their `row_hits`, and write back — whose update survives?

4.  What is an OpenMP `reduction` clause, and how does it eliminate the race?

### How to fix it

Add `reduction(+:hits)` to the `#pragma omp parallel for` directive:

``` c
/* Fixed */
#pragma omp parallel for schedule(static) reduction(+:hits)
```

With `reduction(+:hits)`, each thread gets its own **private** copy of `hits`, initialised to 0. At the end of the
parallel region, OpenMP sums all private copies into the shared `hits`. No two threads ever write to the same variable
at the same time.

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

### Questions

1.  In `race_condition_numba.py`, why is `counts = np.zeros(1, dtype=np.int64)` a problem? What makes it different from
    a plain scalar variable?

2.  Numba *does* handle scalar reductions in `prange` automatically — so why doesn’t that help here? (Hint: look at what
    `counts[0] += row_hits` compiles to versus `hits += row_hits` where `hits` is a scalar.)

3.  What would the correct scalar accumulation pattern look like?

### How to fix it

Replace the shared array with a scalar accumulator and let Numba handle the `prange` reduction:

``` python
@njit(parallel=True, cache=True)
def count_divisible_correct(n: int, m: int) -> int:
    hits = np.int64(0)           # scalar — Numba handles prange reduction automatically
    for i in prange(n):
        row_hits = np.int64(0)
        for j in range(m):
            if (i * m + j) % 3 == 0:
                row_hits += 1
        hits += row_hits          # Numba correctly reduces this in prange
    return int(hits)
```

Numba’s parallel transform recognises `hits += row_hits` as a reduction on a scalar and inserts the necessary
thread-local copies and final summation — exactly what `reduction(+:hits)` does in OpenMP.

------------------------------------------------------------------------------------------------------------------------

## Notes

Data races are one of the most common correctness bugs in parallel code. They are especially insidious because:

1.  Results are wrong but *plausible* — not a crash or an exception.
2.  The bug may not appear at all with a single thread; it only surfaces under parallelism.
3.  Results are non-deterministic — the same binary, the same input, different answers on every run.

Always verify your parallel results against a single-threaded reference before trusting them.
