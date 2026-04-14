# Monte Carlo Pi Parallel Strategies

This walkthrough uses one Monte Carlo problem to compare several implementation styles:

- pure Python loops
- NumPy vectorisation
- Numba JIT compilation
- Numba with `parallel=True` and `prange`
- hybrid MPI + threaded Numba

Each entry script uses Jupytext percent format so it can be paired with a notebook if needed.

The files are intentionally kept close to each other in structure so that a diff focuses on the implementation change
being taught. For example:

``` bash
diff -u monte_carlo_pi_numba.py monte_carlo_pi_numba_parallel.py
```

shows the change from `range` to `prange` and the `parallel=True` decorator change clearly.

## Problem setup

Draw a random point uniformly from the `d`-dimensional cube `[-1, 1]^d`.

Count it as a hit when the point lies inside the unit `d`-sphere:

``` text
x_1^2 + x_2^2 + ... + x_d^2 <= 1
```

After `N` samples:

- hits = number of accepted points
- `p_hat = hits / N` is the unbiased estimator for the hit probability

The analytic hit probability is:

``` text
p_d = pi^(d/2) / (2^d Gamma(d/2 + 1))
```

Inverting that relation gives an estimator for `pi`:

``` text
pi_hat = (p_hat 2^d Gamma(d/2 + 1))^(2/d)
```

The script also reports:

- the analytic standard deviation of `p_hat`
- a delta-method standard deviation for `pi_hat`

## Hyper-parameters

- `d`: sphere dimension
- `N`: number of Monte Carlo samples
- `NUM_THREADS`: thread count for the threaded Numba variants
- MPI process count: only relevant for the hybrid case, controlled by `mpiexec -n`

See `hybrid-MPI.md` for the environment variables that are commonly set before threaded or hybrid runs.

## Set up the local environment

From the repository root:

``` bash
pixi install
```

The root `pyproject.toml` installs the numerical dependencies through Pixi and also installs the project itself as an
editable local package via `[tool.pixi.pypi-dependencies]`.

The root `pyproject.toml` now carries both the standard Python packaging metadata and the Pixi configuration under
`[tool.pixi.*]`. The scripts keep a fallback import path so you can still run them directly from this section directory
with `python monte_carlo_pi_numpy.py` if that is more convenient for the workshop flow.

## Files

- `monte_carlo_pi_pure_python.py`
- `monte_carlo_pi_numpy.py`
- `monte_carlo_pi_numba.py`
- `monte_carlo_pi_numba_parallel.py`
- `monte_carlo_pi_mpi_hybrid.py`
- `monte_carlo_pi_parallel_strategies.py` - summary runner for the non-MPI variants, with the hybrid result appended
  when launched under `mpiexec`
- `monte_carlo_pi_common.py` - shared maths, CLI parsing, and table formatting

## Run the single-process variants

Run the summary script from the repository root:

``` bash
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_parallel_strategies -d 2 -n 200000 -t 4
```

That summary runner imports the four non-MPI variants and prints one table. If you launch the same script under
`mpiexec`, it appends the hybrid MPI result as well.

Or run one implementation explicitly:

``` bash
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_pure_python -d 2 -n 50000
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_numpy -d 2 -n 200000
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_numba -d 2 -n 200000
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_numba_parallel -d 2 -n 200000 -t 4
```

## Run the hybrid MPI variant

Set the thread-related environment first, following `hybrid-MPI.md`, then launch multiple MPI ranks:

``` bash
export NUM_THREADS=4
export NUMBA_NUM_THREADS=${NUM_THREADS}

pixi run mpiexec -n 4 python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_mpi_hybrid \
  -d 2 \
  -n 2000000 \
  -t ${NUM_THREADS}
```

In this hybrid setup:

- MPI distributes the total number of samples across ranks
- each rank generates its own random points
- each rank uses the threaded Numba kernel locally
- MPI reduces the local hit counts into a global result

## Jupytext pairing

Create a notebook from one of the percent scripts:

``` bash
pixi run python -m jupytext --to ipynb src/section_06_python_array_jobs_parallelism_strategies/monte_carlo_pi_numba_parallel.py
```

After both files exist, keep them synchronised with:

``` bash
pixi run python -m jupytext --sync \
  src/section_06_python_array_jobs_parallelism_strategies/monte_carlo_pi_numba_parallel.ipynb \
  src/section_06_python_array_jobs_parallelism_strategies/monte_carlo_pi_numba_parallel.py
```

## Array jobs hook

For a Slurm array job, use the task ID as a per-run seed:

``` bash
pixi run python -m section_06_python_array_jobs_parallelism_strategies.monte_carlo_pi_numpy \
  -d 2 \
  -n 200000 \
  -s "${SLURM_ARRAY_TASK_ID}"
```

That keeps the Monte Carlo runs independent while reusing the same script.
