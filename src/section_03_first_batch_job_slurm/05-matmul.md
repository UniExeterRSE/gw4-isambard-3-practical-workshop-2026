# Single-Node C Matmul with Timing and GFLOPS

A slightly meatier job: compile a small C program that does a dense matrix multiply, time it, and compute a GFLOPS
rate. Still one node, still one minute of walltime, still no MPI.

The purpose is not to teach dense linear algebra — it is to show the full round trip: load a compiler module, build
something with `make`, run it under Slurm, read a timing result back. That is the shape of almost every HPC workflow
for compiled code.

## Files

- `matmul.c` — naive IKJ triple-loop dense matrix multiply, times itself with `clock_gettime`, prints
  `elapsed_s`, `gflops`, and a checksum.
- `makefile` — builds the serial binary (`make`) or an OpenMP binary (`make openmp`). Uses `-O3 -mcpu=neoverse-v2` for
  the Grace CPU; targets the `gcc-native` module.
- `matmul.sh` — Slurm batch script that loads `gcc-native`, builds, and runs `./matmul 1024`.

## Build and submit

``` bash
sbatch matmul.sh
```

The job script takes care of `module load gcc-native` and `make matmul` before running the binary, so you do not need
to compile separately.

## Read the output

``` bash
cat matmul.out
```

You should see something like:

```
matmul N=1024 threads=1
elapsed_s=0.7123 gflops=3.01 checksum=1.234567e+08
```

The exact GFLOPS number depends on the node and how the compiler vectorises; the shape is what matters.

## Questions

1.  What GFLOPS rate did you measure?
2.  Double the matrix size (`./matmul 2048`). Did the wall time go up roughly 8×? (Work scales as N³.)
3.  What compiler flag in the `makefile` tells the compiler to target Grace? (Hint: `-mcpu=…`.)
4.  Is your job still finishing within the one-minute walltime? What happens if you raise N enough that it does not?

## Stretch: OpenMP scaling

Build an OpenMP version and run it with more cores. This is a small taste of *strong scaling* — fixed problem size,
more threads.

Edit the batch script to request more cores and set `OMP_NUM_THREADS`:

``` bash
#SBATCH --cpus-per-task=4
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
make openmp
./matmul_omp 2048
```

Try `--cpus-per-task=` values of 1, 2, 4, 8 and record the GFLOPS rate for each. Plot (or just eyeball) GFLOPS vs
threads.

For a weak-scaling sketch instead, keep the work per thread constant: double N roughly every time you double the
threads (N³ grows fast, so in practice bump N by ∛2 ≈ 1.26× per doubling of cores).

Do not chase peak performance here. The point is to see that more cores help, that scaling is not perfect, and that
the submit–build–run–time loop is the same as for the serial case.
