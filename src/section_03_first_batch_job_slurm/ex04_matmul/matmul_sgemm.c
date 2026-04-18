/* matmul_sgemm.c — matrix multiply using cblas_sgemm (single precision BLAS) */
#define _POSIX_C_SOURCE 200809L

#include <cblas.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef float real_t; /* single precision: 4 bytes per element (half the memory of double) */

static double wall_seconds(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

int main(int argc, char** argv)
{
    int n = (argc > 1) ? atoi(argv[1]) : 1024;
    if (n <= 0) {
        fprintf(stderr, "usage: %s [N]   (N > 0)\n", argv[0]);
        return 1;
    }

    size_t elems = (size_t)n * (size_t)n;
    real_t* A = malloc(elems * sizeof(real_t));
    real_t* B = malloc(elems * sizeof(real_t));
    real_t* C = malloc(elems * sizeof(real_t));
    if (!A || !B || !C) {
        fprintf(stderr, "allocation failed for N=%d\n", n);
        free(A);
        free(B);
        free(C);
        return 1;
    }

#pragma omp parallel for schedule(static)
    for (size_t i = 0; i < elems; i++) {
        A[i] = (real_t)((double)(i % 100) / 100.0);
        B[i] = (real_t)((double)((i * 7u) % 100) / 100.0);
    }
    memset(C, 0, elems * sizeof(real_t));

    printf("matmul routine=cblas_sgemm (float) N=%d omp_threads=%d\n", n, omp_get_max_threads());

    double t0 = wall_seconds();
    /* BLAS level-3: C = 1*A*B + 0*C, row-major, no transpose */
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, n, n, n,
        1.0f, A, n, B, n, 0.0f, C, n);
    double elapsed = wall_seconds() - t0;

    double flops = 2.0 * (double)n * (double)n * (double)n;
    double gflops = flops / elapsed / 1e9;

    double checksum = 0.0;
    for (size_t i = 0; i < elems; i++) {
        checksum += (double)C[i];
    }

    printf("elapsed_s=%.4f gflops=%.2f checksum=%.6e\n", elapsed, gflops, checksum);

    free(A);
    free(B);
    free(C);
    return 0;
}
