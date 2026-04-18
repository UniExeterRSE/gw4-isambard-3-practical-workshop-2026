# Single-Node C Matmul (stretch)

A slightly meatier job so you have something non-trivial running end-to-end: compile a small C program that calls
`cblas_dgemm`, run it on a compute node, and see a wall-time and a GFLOPS number come out.

We are **not** dissecting the performance here. The point is the round trip — load the programming environment, build
with `make`, submit under Slurm, read output — which is the same shape as nearly every compiled HPC workflow. We will
revisit what the numbers mean (scaling, precision, LibSci threading) later in the workshop.

## Files

Four self-contained source files, each a direct variant of the others — compare them side-by-side to see exactly what
changes between precision and implementation:

- `matmul_dgemm.c` → `cblas_dgemm` (double precision BLAS)

- `matmul_sgemm.c` → `cblas_sgemm` (single precision BLAS)

- `matmul_naive.c` → hand-rolled `ikj` triple-loop (double precision, no BLAS)

- `matmul_naive_flt.c` → hand-rolled `ikj` triple-loop (single precision, no BLAS)

- `makefile` — builds all four binaries with the Cray C wrapper `cc`. LibSci is linked automatically under `PrgEnv-gnu`,
  no explicit `-lblas` needed.

- `make.sh` — loads `PrgEnv-gnu`, runs `make`, then runs all four binaries at N=1024.

## Build and submit

``` bash
make.sh
# TODO
sbatch ...
```

The job script handles `module load PrgEnv-gnu` and `make` before running the binary.

## Read the output

``` bash
cat matmul.out
```

You should see four blocks, something like:

    matmul routine=naive ikj triple loop (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=1.8321 gflops=1.17 checksum=1.234567e+08
    matmul routine=naive ikj triple loop (float) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=1.6102 gflops=1.33 checksum=1.234568e+08
    matmul routine=cblas_dgemm (double) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0421 gflops=51.02 checksum=1.234567e+08
    matmul routine=cblas_sgemm (float) N=1024 OMP_NUM_THREADS=(unset)
    elapsed_s=0.0218 gflops=98.53 checksum=1.234568e+08

Exact numbers vary — the point is the gaps. Same machine, same `N`, same arithmetic: the BLAS versions are ~40× faster
than the naive loops, and single precision is roughly 2× faster than double (half the memory bandwidth, wider SIMD).
Notice the checksums: naive-float and sgemm agree with each other but differ slightly from the double results due to
lower precision. We will come back to *why* (cache blocking, vectorisation, LibSci) later in the workshop.
