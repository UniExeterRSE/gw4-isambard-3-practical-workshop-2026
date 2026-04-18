/*
 * monte_carlo_pi_mpi_hybrid.c
 *
 * Monte Carlo estimation of pi via the volume ratio of a unit d-sphere to
 * its enclosing d-cube [-1, 1]^d. MPI distributes independent samples
 * across ranks; OpenMP parallelises within each rank.
 *
 * CLI convention
 *   -n sets samples PER OpenMP THREAD.
 *   Total samples = MPI ranks * (OMP threads) * n.
 *   Thread count is read from OMP_NUM_THREADS via omp_get_max_threads();
 *   the MPI rank count is omp-independent, taken from MPI_Comm_size.
 *
 * RNG
 *   xoshiro256+ lives in rng.h / rng.c. Each (rank, thread) pair is
 *   seeded with the same base seed and advanced `stream * 2^128` steps
 *   where `stream = rank * threads_per_rank + tid`, so no two threads
 *   ever share a sample.
 *
 * Build
 *   mpicc -O3 -mcpu=neoverse-v2 -fopenmp -std=c11 \
 *         monte_carlo_pi_mpi_hybrid.c rng.c -o monte_carlo_pi_mpi_hybrid -lm
 */

/* M_PI and tgamma are POSIX/GNU extensions not in strict C11. */
#define _GNU_SOURCE

#include <getopt.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "rng.h"

/* ── analytic closed forms ──────────────────────────────────────────── */

/* Hit probability p = Vol(d-sphere) / Vol(d-cube) = pi^(d/2) / (Gamma(d/2+1) * 2^d). */
static double analytic_p(int d)
{
    return pow(M_PI, d * 0.5) / (tgamma(d * 0.5 + 1.0) * pow(2.0, d));
}

/* Invert p -> pi estimate: pi = (2^d * Gamma(d/2+1) * p)^(2/d). */
static double p_to_pi(double p, int d)
{
    return pow(pow(2.0, d) * tgamma(d * 0.5 + 1.0) * p, 2.0 / d);
}

/* ── per-thread kernel ──────────────────────────────────────────────── */

/*
 * Draw `n` uniform points in [-1, 1]^d with `rng` and return the count
 * that fall inside the unit d-sphere. The inner double loop is fused —
 * every sample stays in registers, no intermediate buffer.
 */
static long long count_hits(long long n, int d, Rng* rng)
{
    long long hits = 0;
    for (long long i = 0; i < n; i++) {
        double rsq = 0.0;
        for (int j = 0; j < d; j++) {
            double x = rng_uniform(rng);
            rsq += x * x;
        }
        hits += (rsq <= 1.0);
    }
    return hits;
}

/* ── per-rank driver ────────────────────────────────────────────────── */

/*
 * Run `n_per_thread` samples on each OpenMP thread and return the
 * rank-local hit count. Each thread gets an independent xoshiro256+
 * stream via `rng_init(&rng, seed, rank * nthreads + tid)`.
 */
static long long count_local_hits(long long n_per_thread, int d, uint64_t seed, int rank)
{
    long long hits = 0;

#pragma omp parallel reduction(+ : hits)
    {
        int tid = omp_get_thread_num();
        int nthreads = omp_get_num_threads();
        int stream = rank * nthreads + tid;

        Rng rng;
        rng_init(&rng, seed, stream);
        hits += count_hits(n_per_thread, d, &rng);
    }

    return hits;
}

/* ── CLI ────────────────────────────────────────────────────────────── */

typedef struct {
    long long n_per_thread;
    int d;
    uint64_t seed;
} Config;

static void usage(const char* prog)
{
    fprintf(stderr,
        "Usage: %s [options]\n"
        "  -n <samples>   samples PER OpenMP thread  (default 1000000)\n"
        "  -d <dims>      sphere/cube dimension       (default 2)\n"
        "  -s <seed>      RNG base seed               (default 20260421)\n"
        "  -h             show this help\n"
        "\n"
        "Total samples = MPI ranks * OMP threads * n.\n"
        "Thread count is read from OMP_NUM_THREADS (or 1 if unset).\n",
        prog);
}

static int parse_args(int argc, char* argv[], Config* cfg)
{
    cfg->n_per_thread = 1000000LL;
    cfg->d = 2;
    cfg->seed = 20260421ULL;

    int opt;
    while ((opt = getopt(argc, argv, "n:d:s:h")) != -1) {
        switch (opt) {
        case 'n':
            cfg->n_per_thread = atoll(optarg);
            break;
        case 'd':
            cfg->d = atoi(optarg);
            break;
        case 's':
            cfg->seed = (uint64_t)atoll(optarg);
            break;
        case 'h':
            usage(argv[0]);
            return 1;
        default:
            usage(argv[0]);
            return 2;
        }
    }

    if (cfg->n_per_thread < 1 || cfg->d < 1) {
        fprintf(stderr, "-n and -d must be >= 1\n");
        return 2;
    }
    return 0;
}

/* ── main ───────────────────────────────────────────────────────────── */

int main(int argc, char* argv[])
{
    int provided;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_FUNNELED, &provided);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    Config cfg;
    int rc = parse_args(argc, argv, &cfg);
    if (rc != 0) {
        MPI_Finalize();
        return (rc == 1) ? 0 : 1;
    }

    int num_threads = omp_get_max_threads();
    long long total_n = cfg.n_per_thread * (long long)num_threads * (long long)size;

    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();

    long long local_hits = count_local_hits(cfg.n_per_thread, cfg.d, cfg.seed, rank);

    double elapsed = MPI_Wtime() - t0;

    long long total_hits = 0;
    double max_elapsed = 0.0;
    MPI_Reduce(&local_hits, &total_hits, 1, MPI_LONG_LONG_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        double p_hat = (double)total_hits / (double)total_n;
        double p_true = analytic_p(cfg.d);
        double sigma_p = sqrt(p_true * (1.0 - p_true) / (double)total_n);
        double pi_hat = p_to_pi(p_hat, cfg.d);
        /* Delta method: |d(pi)/d(p)| * sigma_p = (2/d) * pi/p * sigma_p */
        double sigma_pi = (2.0 / cfg.d) * (M_PI / p_true) * sigma_p;

        printf("d=%d N=%lld num_threads=%d seed=%llu mpi_ranks=%d\n",
            cfg.d, total_n, num_threads,
            (unsigned long long)cfg.seed, size);

        const char* hdr = "variant             hits      p_hat     p_true    sigma_p"
                          "     pi_hat   sigma_pi   thr ranks    time[s]";
        printf("%s\n", hdr);
        for (int i = 0; hdr[i]; i++)
            putchar('-');
        putchar('\n');

        printf("%-16s %12lld %10.6f %10.6f %10.6f %10.6f %10.6f %5d %5d %10.4f\n",
            "c-mpi-omp",
            total_hits,
            p_hat,
            p_true,
            sigma_p,
            pi_hat,
            sigma_pi,
            num_threads,
            size,
            max_elapsed);
    }

    MPI_Finalize();
    return 0;
}
