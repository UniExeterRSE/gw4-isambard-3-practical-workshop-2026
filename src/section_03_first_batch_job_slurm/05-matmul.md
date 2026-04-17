# Single-Node C Matmul with BLAS and GFLOPS

A slightly meatier job: compile a small C program that calls a BLAS matrix multiply (`cblas_dgemm` / `cblas_sgemm`),
time it, and compute a GFLOPS rate. Still one node, still one minute of walltime, still no MPI.

The purpose is not to teach dense linear algebra — it is to show the full round trip: load the programming environment,
build something with `make` using the Cray compiler wrapper, run it under Slurm, read a timing result back. That is the
shape of almost every HPC workflow for compiled code.

## Files

- `matmul.c` — calls `cblas_dgemm` by default, or `cblas_sgemm` when built with `-DUSE_SGEMM`. Times the GEMM call with
  `clock_gettime` and prints `elapsed_s`, `gflops`, and a checksum.
- `makefile` — builds `matmul_dgemm` (double) and `matmul_sgemm` (float) using the Cray C wrapper `cc` with
  `-O3 -mcpu=neoverse-v2`. No explicit `-lblas` — the `cc` wrapper with `PrgEnv-gnu` links Cray LibSci automatically.
- `matmul.sh` — Slurm batch script that loads `PrgEnv-gnu`, runs `make`, and runs `./matmul_dgemm 1024`.

## Build and submit

``` bash
sbatch matmul.sh
```

The job script takes care of `module load PrgEnv-gnu` and `make` before running the binary, so you do not need to
compile separately.

## Read the output

``` bash
cat matmul.out
```

You should see something like:

    matmul routine=cblas_dgemm (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0421 gflops=51.02 checksum=1.234567e+08

The exact GFLOPS number depends on the node and on how many threads LibSci decides to use; the shape is what matters.

## Questions

1.  What GFLOPS rate did you measure for `cblas_dgemm` at N=1024?
2.  Double the matrix size (`./matmul_dgemm 2048`). Did the wall time go up roughly 8×? (Work scales as N³.)
3.  Which compiler driver did you use, and what does the `cc` wrapper add on top of plain `gcc`?
4.  Is your job still finishing within the one-minute walltime? What happens if you raise N enough that it does not?

## Stretch 1: single vs double precision

Swap `./matmul_dgemm` for `./matmul_sgemm` in the batch script (or run both in the same job) and compare:

- How much faster is `sgemm` than `dgemm` at the same N?
- How does the checksum differ? (Expect some rounding at single precision.)

## Stretch 2: LibSci threading (strong scaling)

Cray LibSci is multithreaded via OpenMP. No code changes needed — just give the job more cores and set
`OMP_NUM_THREADS`. Edit the batch script:

``` bash
#SBATCH --cpus-per-task=4
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
./matmul_dgemm 4096
```

Try `--cpus-per-task=` values of 1, 2, 4, 8, 16 and record the GFLOPS rate for each. Plot (or just eyeball) GFLOPS vs
threads.

For a weak-scaling sketch instead, keep the work per thread roughly constant: grow N by ∛2 ≈ 1.26× per doubling of cores
(because GEMM work is N³).

Do not chase peak performance here. The point is to see that more cores help, that scaling is not perfect, and that the
submit–build–run–time loop is the same regardless of precision or thread count.
