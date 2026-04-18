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

- `make.sh` — loads `PrgEnv-gnu` and runs `make` to build all four binaries. Run this on a login node first.

- `sbatch_matmul.sh` — Slurm job script: loads `PrgEnv-gnu`, sets `OMP_NUM_THREADS=144`, and runs all four binaries at
  N=16384 using `command time -v` for timing.

## Build and submit

``` bash
bash make.sh
sbatch sbatch_matmul.sh
```

Build on the login node with `make.sh`, then submit the job with `sbatch`. The job script handles the module load and
runs each binary in turn.

## Read the output

``` bash
cat matmul.out
```

You should see four blocks, something like:

    === Running matmul_sgemm... ===
    matmul routine=cblas_sgemm (float) N=16384 OMP_NUM_THREADS=144
    elapsed_s=0.0631 gflops=277.43 checksum=...
    === Running matmul_dgemm... ===
    matmul routine=cblas_dgemm (double) N=16384 OMP_NUM_THREADS=144
    elapsed_s=0.1124 gflops=156.03 checksum=...
    === Running matmul_naive_flt... ===
    matmul routine=naive ikj triple loop (float) N=16384 OMP_NUM_THREADS=144
    elapsed_s=... gflops=... checksum=...
    === Running matmul_naive... ===
    matmul routine=naive ikj triple loop (double) N=16384 OMP_NUM_THREADS=144
    elapsed_s=... gflops=... checksum=...

Exact numbers vary — the point is the gaps. Same machine, same `N`, same arithmetic: the BLAS versions are substantially
faster than the naive loops, and single precision is roughly 2× faster than double (half the memory bandwidth, wider
SIMD). Notice the checksums: naive-float and sgemm agree with each other but differ slightly from the double results due
to lower precision. We will come back to *why* (cache blocking, vectorisation, LibSci) later in the workshop.
