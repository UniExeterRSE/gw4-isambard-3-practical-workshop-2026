#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef _OPENMP
#include <omp.h>
#endif

static double wall_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? atoi(argv[1]) : 1024;
    if (n <= 0) {
        fprintf(stderr, "usage: %s [N]   (N > 0)\n", argv[0]);
        return 1;
    }

    size_t elems = (size_t)n * (size_t)n;
    double *A = malloc(elems * sizeof(double));
    double *B = malloc(elems * sizeof(double));
    double *C = malloc(elems * sizeof(double));
    if (!A || !B || !C) {
        fprintf(stderr, "allocation failed for N=%d\n", n);
        return 1;
    }

    for (size_t i = 0; i < elems; i++) {
        A[i] = (double)(i % 100) / 100.0;
        B[i] = (double)((i * 7u) % 100) / 100.0;
    }
    memset(C, 0, elems * sizeof(double));

    int nthreads = 1;
#ifdef _OPENMP
    nthreads = omp_get_max_threads();
#endif
    printf("matmul N=%d threads=%d\n", n, nthreads);

    double t0 = wall_seconds();

#ifdef _OPENMP
#pragma omp parallel for
#endif
    for (int i = 0; i < n; i++) {
        for (int k = 0; k < n; k++) {
            double aik = A[(size_t)i * n + k];
            for (int j = 0; j < n; j++) {
                C[(size_t)i * n + j] += aik * B[(size_t)k * n + j];
            }
        }
    }

    double elapsed = wall_seconds() - t0;
    double flops = 2.0 * (double)n * (double)n * (double)n;
    double gflops = flops / elapsed / 1e9;

    double checksum = 0.0;
    for (size_t i = 0; i < elems; i++) {
        checksum += C[i];
    }

    printf("elapsed_s=%.4f gflops=%.2f checksum=%.6e\n", elapsed, gflops, checksum);

    free(A);
    free(B);
    free(C);
    return 0;
}
