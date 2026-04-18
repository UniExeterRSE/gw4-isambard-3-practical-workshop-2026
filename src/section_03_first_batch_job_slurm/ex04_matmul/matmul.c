#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef USE_NAIVE
typedef double real_t;
#define GEMM_NAME "naive ikj triple loop (double)"
#else
#include <cblas.h>
#ifdef USE_SGEMM
typedef float real_t;
#define GEMM cblas_sgemm
#define GEMM_NAME "cblas_sgemm (float)"
#else
typedef double real_t;
#define GEMM cblas_dgemm
#define GEMM_NAME "cblas_dgemm (double)"
#endif
#endif

static double wall_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

#ifdef USE_NAIVE
static void naive_gemm(const real_t *A, const real_t *B, real_t *C, int n) {
    for (int i = 0; i < n; i++) {
        for (int k = 0; k < n; k++) {
            real_t a = A[(size_t)i * n + k];
            for (int j = 0; j < n; j++) {
                C[(size_t)i * n + j] += a * B[(size_t)k * n + j];
            }
        }
    }
}
#endif

int main(int argc, char **argv) {
    int n = (argc > 1) ? atoi(argv[1]) : 1024;
    if (n <= 0) {
        fprintf(stderr, "usage: %s [N]   (N > 0)\n", argv[0]);
        return 1;
    }

    size_t elems = (size_t)n * (size_t)n;
    real_t *A = malloc(elems * sizeof(real_t));
    real_t *B = malloc(elems * sizeof(real_t));
    real_t *C = malloc(elems * sizeof(real_t));
    if (!A || !B || !C) {
        fprintf(stderr, "allocation failed for N=%d\n", n);
        free(A);
        free(B);
        free(C);
        return 1;
    }

    for (size_t i = 0; i < elems; i++) {
        A[i] = (real_t)((double)(i % 100) / 100.0);
        B[i] = (real_t)((double)((i * 7u) % 100) / 100.0);
    }
    memset(C, 0, elems * sizeof(real_t));

    const char *threads_env = getenv("OMP_NUM_THREADS");
    printf("matmul routine=%s N=%d OMP_NUM_THREADS=%s\n", GEMM_NAME, n, threads_env ? threads_env : "(unset)");

    double t0 = wall_seconds();
#ifdef USE_NAIVE
    naive_gemm(A, B, C, n);
#else
    GEMM(CblasRowMajor, CblasNoTrans, CblasNoTrans, n, n, n, (real_t)1.0, A, n, B, n, (real_t)0.0, C, n);
#endif
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
