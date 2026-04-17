# Single-Node C Matmul (stretch)

A slightly meatier job so you have something non-trivial running end-to-end: compile a small C program that calls
`cblas_dgemm`, run it on a compute node, and see a wall-time and a GFLOPS number come out.

We are **not** dissecting the performance here. The point is the round trip — load the programming environment, build
with `make`, submit under Slurm, read output — which is the same shape as nearly every compiled HPC workflow. We will
revisit what the numbers mean (scaling, precision, LibSci threading) later in the workshop.

## Files

- `matmul.c` — calls `cblas_dgemm` (or `cblas_sgemm` with `-DUSE_SGEMM`) and times the GEMM call with `clock_gettime`.
- `makefile` — builds `matmul_dgemm` and `matmul_sgemm` with the Cray C wrapper `cc`. LibSci is linked automatically
  under `PrgEnv-gnu`, no explicit `-lblas` needed.
- `matmul.sh` — loads `PrgEnv-gnu`, runs `make`, runs `./matmul_dgemm 1024`.

## Build and submit

``` bash
sbatch matmul.sh
```

The job script handles `module load PrgEnv-gnu` and `make` before running the binary.

## Read the output

``` bash
cat matmul.out
```

You should see something like:

    matmul routine=cblas_dgemm (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0421 gflops=51.02 checksum=1.234567e+08

Exact numbers vary; the point is that you got a number out at all. We will come back to what it means.
