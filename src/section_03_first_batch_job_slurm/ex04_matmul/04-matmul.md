# Single-Node C Matmul (stretch)

A slightly meatier job so you have something non-trivial running end-to-end: compile a small C program that calls
`cblas_dgemm`, run it on a compute node, and see a wall-time and a GFLOPS number come out.

We are **not** dissecting the performance here. The point is the round trip — load the programming environment, build
with `make`, submit under Slurm, read output — which is the same shape as nearly every compiled HPC workflow. We will
revisit what the numbers mean (scaling, precision, LibSci threading) later in the workshop.

## Files

- `matmul.c` — one source file, three builds:
  - default → `cblas_dgemm` (double precision BLAS)
  - `-DUSE_SGEMM` → `cblas_sgemm` (single precision BLAS)
  - `-DUSE_NAIVE` → a hand-rolled `ikj` triple-loop (double precision, no BLAS)
- `makefile` — builds `matmul_dgemm`, `matmul_sgemm`, and `matmul_naive` with the Cray C wrapper `cc`. LibSci is linked
  automatically under `PrgEnv-gnu`, no explicit `-lblas` needed.
- `matmul.sh` — loads `PrgEnv-gnu`, runs `make`, runs `./matmul_naive 1024` then `./matmul_dgemm 1024`.

## Build and submit

``` bash
sbatch matmul.sh
```

The job script handles `module load PrgEnv-gnu` and `make` before running the binary.

## Read the output

``` bash
cat matmul.out
```

You should see two blocks, something like:

    matmul routine=naive ikj triple loop (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=1.8321 gflops=1.17 checksum=1.234567e+08
    matmul routine=cblas_dgemm (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0421 gflops=51.02 checksum=1.234567e+08

Exact numbers vary — the point is the gap. Same machine, same `N`, same arithmetic, and one version is ~40× faster than
the other. Notice it, sit with it, and we will come back to *why* (cache blocking, vectorisation, LibSci) later in the
workshop.
