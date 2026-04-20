# Wrong Environment — Missing Module Load

A batch job that compiles and links fine on the login node but fails immediately on the compute node because the
required runtime libraries are not in `LD_LIBRARY_PATH`.

## Prerequisite

You must have already built `monte_carlo_pi_mpi_hybrid` from the Section 5 exercise. If you have not done that yet, do
it now:

``` bash
cd src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/
bash make.sh
cd -
```

The build succeeds because `make.sh` loads `PrgEnv-gnu` before calling `make`. The resulting binary is dynamically
linked against GNU OpenMP (`libgomp`) and the Cray MPI runtime.

## The scenario

You compiled the binary on the login node. The build succeeded. Now you submit a batch job — but the job script only
calls `module reset` and does **not** reload `PrgEnv-gnu`.

## Submit it

From the directory containing the binary (or after copying / symlinking it):

``` bash
sbatch sbatch_wrong_env_module.sh
```

The job requests only 3 MPI/thread configurations instead of the usual 15, so it should fail within seconds.

## What do you see?

Read the output file once the job finishes:

``` bash
cat wrong_env_module_<jobid>.out
```

The job fails on the very first `srun`. Look for a line like:

    error while loading shared libraries: libgomp.so.1: cannot open shared object file: No such file or directory

or an MPI launcher error along the lines of:

    srun: error: ... failed to load ...

The key signal is a `.so` file that cannot be opened — the dynamic linker cannot find a shared library that the binary
needs at runtime.

## Questions

1.  The binary compiled fine on the login node. Why does it fail at runtime on the compute node?
2.  What does `module reset` do? What state does it leave the environment in?
3.  Why is `module load PrgEnv-gnu` needed both at compile time **and** at runtime?

## Key insight

Modules control environment variables: `PATH`, `LD_LIBRARY_PATH`, `MANPATH`, and compiler/linker wrappers. When you
compile with `PrgEnv-gnu` loaded, the binary is dynamically linked against GNU’s runtime libraries (`libgomp.so`) and
the Cray MPI libraries. Those `.so` files must be findable at runtime too — and they are found via `LD_LIBRARY_PATH`,
which is set by the module.

`module reset` removes all user-loaded modules and resets the environment to a minimal baseline. That clears
`LD_LIBRARY_PATH`, so `libgomp.so.1` is no longer on the search path when the compute node tries to start the binary.

The rule of thumb: **load the same modules at runtime as you loaded at compile time.**

## How to fix

Add `module load PrgEnv-gnu` after `module reset` in the sbatch script:

``` bash
module reset
module load PrgEnv-gnu   # <-- add this line
```

The correct pattern is already in the Section 5 reference script:

    src/section_05_python_array_jobs_parallelism_strategies/ex02_monte_carlo_pi_c/sbatch_monte_carlo_pi_mpi_hybrid_c.sh

## Notes

On Cray systems, the default Cray PE loaded after `module reset` may provide some Cray libraries, but it does **not**
provide the GNU OpenMP runtime (`libgomp`). `PrgEnv-gnu` is needed specifically because the binary was compiled with
GCC’s OpenMP support. If you had compiled with `PrgEnv-cray` or `PrgEnv-aocc`, you would need to load the corresponding
environment instead.
